import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/sp_keys.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/cloud_login_policy.dart';
import 'package:habit_forge_app/core/services/audio_service.dart';
import 'package:habit_forge_app/core/services/data_reset_service.dart';
import 'package:habit_forge_app/core/services/entitlement_service.dart';
import 'package:habit_forge_app/core/services/firebase_auth_service.dart';
import 'package:habit_forge_app/core/services/firebase_session.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/core/services/progress_merge_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/widgets/cloud_save_choice_dialog.dart';
import 'package:habit_forge_app/widgets/confirm_dialog.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final accountRevision = 0.obs;

  bool get hasCloudIdentity {
    accountRevision.value;
    if (!Get.isRegistered<FirebaseAuthService>() || !FirebaseAuthService.to.isAvailable) {
      return false;
    }
    return FirebaseSession.hasLinkedCloudUser;
  }

  String? get cloudEmail {
    if (!Get.isRegistered<FirebaseAuthService>() || !FirebaseAuthService.to.isAvailable) {
      return null;
    }
    return FirebaseAuthService.to.currentUser?.email;
  }

  @override
  void onInit() {
    super.onInit();
    if (hasCloudIdentity) isLoggedIn.value = true;
  }

  /// Settings → Firebase **and** the startup gate: Google picker only.
  ///
  /// Three outcomes, in this order:
  ///  1. the Google account is brand new in Firebase → the local save is merged
  ///     into it silently (there is nothing on the account to conflict with);
  ///  2. the account already has a cloud save and this device has progress → the
  ///     player chooses: use the cloud save, **merge** (nothing is lost), or
  ///     cancel;
  ///  3. nothing on this device → plain sign-in.
  Future<bool> signInWithGoogleFromSettings(BuildContext context) async {
    isLoading.value = true;
    try {
      final hasLocal = _snapshotLocalProgress();
      final link = await FirebaseAuthService.to.linkOrSignInWithGoogle();
      if (link.canceled) return false;
      if (link.error != null) {
        // Google's own account service being unreachable is the one failure the
        // player can actually fix (VPN / network), so it gets its own message
        // instead of the generic "failed: [16] Account reauth failed.".
        Toast.error(
          link.googleServicesUnreachable
              ? LanKey.googleSignInNeedsGoogle.tr
              : '${LanKey.googleLoginFailed.tr}: ${link.error}',
        );
        return false;
      }

      // The snapshot has to be taken *before* switching backends: once the cloud
      // backend is registered, `NetworkRegistry.ins` no longer reads this
      // device's local save.
      var mergeLocal = false;
      if (hasLocal) {
        if (link.usedExistingAccount) {
          final choice = await CloudSaveChoiceDialog.show(context);
          if (choice == CloudSaveChoice.cancel) {
            await FirebaseAuthService.to.signOut();
            await FirebaseSession.useLocalBackend();
            return false;
          }
          mergeLocal = choice == CloudSaveChoice.merge;
        } else {
          // New cloud account: the cloud side is empty, so merging cannot lose
          // anything and asking would only be a fake choice.
          mergeLocal = true;
        }
      }
      final localSnapshot = mergeLocal ? await ProgressMergeService.snapshotLocal() : null;

      final result = await FirebaseSession.useCloudBackend(provider: 'google').timeout(FirebaseSession.networkTimeout);
      if (result.isFailure) {
        Toast.error('${LanKey.googleLoginFailed.tr}: ${result.message}');
        await FirebaseAuthService.to.signOut();
        await FirebaseSession.useLocalBackend();
        return false;
      }
      await _persistLinkedEmail();

      var mergedOk = true;
      if (localSnapshot != null) {
        mergedOk = await ProgressMergeService.applyToCloud(localSnapshot);
      }

      isLoggedIn.value = true;
      accountRevision.value++;
      await _reloadAfterCloudLogin();
      if (localSnapshot != null) {
        // Reported after the reload so the toast is not replaced by navigation.
        if (mergedOk) {
          Toast.success(LanKey.mergeDone.tr);
        } else {
          Toast.warning(LanKey.mergeFailed.tr);
        }
      } else {
        Toast.success(LanKey.signInSuccess.tr);
      }
      return true;
    } catch (e) {
      Toast.error('${LanKey.googleLoginFailed.tr}: $e');
      await FirebaseAuthService.to.signOut();
      await FirebaseSession.useLocalBackend();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Guest path (login gate / Settings cancel): keep playing on this device.
  ///
  /// Deliberately does **not** sign in anonymously: that would write a second,
  /// unreachable cloud tree for a user who has no credential to ever claim it
  /// again (see `docs/data-ledger-plan.md` §2 and the Firebase notes in the
  /// launch todo). Guest progress stays in local storage until it is merged into
  /// a real account.
  Future<void> continueAsGuest(BuildContext context) async {
    await FirebaseSession.useLocalBackend();
    await UserService.to.loadUserPrefs();
    await UserService.to.loadCharacter();
    isLoggedIn.value = false;
    accountRevision.value++;
    if (UserService.to.character.value == null) {
      Get.offAllNamed(Routers.boarding);
    } else {
      Get.offAllNamed(Routers.main);
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      final ctx = Get.context;
      final hasLocal = _snapshotLocalProgress();
      final previousToken = UserService.to.token.value;

      final error = await FirebaseAuthService.to.loginWithEmail(email, password);
      if (error != null) {
        Toast.error('${LanKey.loginFailed.tr}: $error');
        return false;
      }

      if (ctx != null &&
          CloudLoginPolicy.shouldConfirmOverwrite(
            hasLocalProgress: hasLocal,
            isExistingCloudAccount: true,
          )) {
        final confirmed = await _showOverwriteDialog(ctx);
        if (confirmed != true) {
          await _rollbackEmailLogin(previousToken);
          return false;
        }
      }

      final result = await FirebaseSession.useCloudBackend(provider: 'email').timeout(FirebaseSession.networkTimeout);
      if (result.isFailure) {
        Toast.error('${LanKey.loginFailed.tr}: ${result.message}');
        await _rollbackEmailLogin(previousToken);
        return false;
      }

      await SpUtils.ins.putString(SpKeys.linkedEmail, email);
      isLoggedIn.value = true;
      accountRevision.value++;
      await _reloadAfterCloudLogin();
      Toast.success(LanKey.signInSuccess.tr);
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> registerWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      final error = await FirebaseAuthService.to.registerWithEmail(email, password);
      if (error != null) {
        Toast.error('${LanKey.registrationFailed.tr}: $error');
        return false;
      }

      final result = await FirebaseSession.useCloudBackend(provider: 'email').timeout(FirebaseSession.networkTimeout);
      if (result.isFailure) {
        Toast.error('${LanKey.registrationFailed.tr}: ${result.message}');
        return false;
      }

      await SpUtils.ins.putString(SpKeys.linkedEmail, email);
      isLoggedIn.value = true;
      accountRevision.value++;
      await _reloadAfterCloudLogin();
      Toast.success(LanKey.signInSuccess.tr);
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    if (Get.isRegistered<FirebaseAuthService>()) {
      await FirebaseAuthService.to.signOut();
      await SpUtils.ins.remove(SpKeys.linkedEmail);
      // Back to local-first Hive — do not create anonymous Firebase users.
      await FirebaseSession.useLocalBackend();
      await UserService.to.loadUserPrefs();
      await UserService.to.loadCharacter();
      isLoggedIn.value = false;
    }
    accountRevision.value++;
  }

  Future<bool> deleteAccount() async {
    isLoading.value = true;
    try {
      final error = await FirebaseAuthService.to.deleteAccount();
      if (error != null) {
        HapticService.to.error();
        unawaited(AudioService.to.playDestructiveWarning());
        Toast.error('${LanKey.accountDeleteFailed.tr}: $error');
        return false;
      }

      HapticService.to.success();
      unawaited(AudioService.to.playSuccessFeedback());
      await EntitlementService.to.stop();
      await DataResetService.to.resetAllData();
      await SpUtils.ins.clear();
      await UserService.to.clearData();
      await FirebaseSession.useLocalBackend();
      isLoggedIn.value = false;
      accountRevision.value++;
      Get.offAllNamed(Routers.login);
      Toast.success(LanKey.accountDeleted.tr);
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  bool _snapshotLocalProgress() {
    return CloudLoginPolicy.hasLocalProgress(
      hasCharacter: UserService.to.character.value != null,
      taskCount: UserService.to.tasks.length,
    );
  }

  Future<bool?> _showOverwriteDialog(BuildContext context) {
    return ConfirmDialog.show(
      context,
      title: LanKey.existingAccountTitle.tr,
      message: LanKey.existingAccountOverwrite.tr,
      confirmLabel: LanKey.continueLogin.tr,
      cancelLabel: LanKey.cancel.tr,
      isDestructive: true,
    );
  }

  Future<void> _rollbackEmailLogin(String previousToken) async {
    await FirebaseAuthService.to.signOut();
    await FirebaseSession.useLocalBackend();
    if (previousToken.isNotEmpty) await UserService.to.setSessionToken(previousToken);
  }

  Future<void> _persistLinkedEmail() async {
    final email = FirebaseAuthService.to.currentUser?.email;
    if (email != null && email.isNotEmpty) {
      await SpUtils.ins.putString(SpKeys.linkedEmail, email);
    }
  }

  Future<void> _reloadAfterCloudLogin() async {
    await UserService.to.loadUserPrefs();
    await UserService.to.loadCharacter();
    final tasks = await NetworkRegistry.ins.listTasks();
    if (tasks.isSuccess) {
      UserService.to.tasks.assignAll(tasks.data?.tasks ?? []);
    }
    if (UserService.to.character.value == null) {
      if (Get.currentRoute != Routers.boarding) {
        Get.offAllNamed(Routers.boarding);
      }
    } else if (Get.currentRoute == Routers.boarding) {
      Get.offAllNamed(Routers.main);
    }
  }
}
