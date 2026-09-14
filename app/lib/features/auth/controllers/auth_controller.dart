import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/sp_keys.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/cloud_login_policy.dart';
import 'package:habit_forge_app/core/services/firebase_auth_service.dart';
import 'package:habit_forge_app/core/services/server_auth_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/widgets/confirm_dialog.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  /// Bumped after sign-in / sign-out so Settings Obx rebuilds.
  final accountRevision = 0.obs;

  /// True when the player has a non-guest cloud identity (for Settings UI).
  bool get hasCloudIdentity {
    accountRevision.value; // Obx dependency
    if (EnvConstants.isHive()) return false;
    if (EnvConstants.isAuthFirebase()) {
      final u = FirebaseAuthService.to.currentUser;
      return u != null && !u.isAnonymous;
    }
    if (EnvConstants.isAuthServer()) {
      return UserService.to.isLoggedIn();
    }
    return false;
  }

  String? get cloudEmail {
    if (EnvConstants.isAuthFirebase()) {
      return FirebaseAuthService.to.currentUser?.email;
    }
    return SpUtils.ins.getString(SpKeys.linkedEmail);
  }

  @override
  void onInit() {
    super.onInit();
    if (UserService.to.isLoggedIn()) isLoggedIn.value = true;
  }

  /// Settings → Firebase: open Google account picker directly (no AuthPage).
  Future<bool> signInWithGoogleFromSettings(BuildContext context) async {
    if (!EnvConstants.isAuthFirebase()) return false;
    isLoading.value = true;
    try {
      final hasLocal = _snapshotLocalProgress();
      final link = await FirebaseAuthService.to.linkOrSignInWithGoogle();
      if (link.canceled) return false;
      if (link.error != null) {
        Toast.error('${LanKey.googleLoginFailed.tr}: ${link.error}');
        return false;
      }

      if (link.usedExistingAccount) {
        if (CloudLoginPolicy.shouldConfirmOverwrite(
          hasLocalProgress: hasLocal,
          isExistingCloudAccount: true,
        )) {
          final confirmed = await _showOverwriteDialog(context);
          if (confirmed != true) {
            await FirebaseAuthService.to.restoreAnonymousSession();
            await NetworkRegistry.ins.login('guest');
            return false;
          }
        }
      }

      final result = await NetworkRegistry.ins.login('google');
      if (result.isFailure) {
        Toast.error('${LanKey.googleLoginFailed.tr}: ${result.message}');
        return false;
      }
      await _persistLinkedEmail();
      isLoggedIn.value = true;
      accountRevision.value++;
      await _reloadAfterCloudLogin();
      Toast.success(LanKey.signInSuccess.tr);
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Email login (server or firebase). Used from Settings bottom sheet.
  Future<bool> loginWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      final ctx = Get.context;
      final hasLocal = _snapshotLocalProgress();
      final previousToken = UserService.to.token.value;

      final String? error;
      if (EnvConstants.isAuthServer()) {
        error = await ServerAuthService.to.loginWithEmail(email, password);
      } else if (EnvConstants.isAuthFirebase()) {
        error = await FirebaseAuthService.to.loginWithEmail(email, password);
      } else {
        return false; // hive: no cloud email login
      }
      if (error != null) {
        Toast.error('${LanKey.loginFailed.tr}: $error');
        return false;
      }

      // Email login always targets an existing account. Confirm before syncing.
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

      if (EnvConstants.isFirebase() || EnvConstants.isServer()) {
        final result = await NetworkRegistry.ins.login('email');
        if (result.isFailure) {
          Toast.error('${LanKey.loginFailed.tr}: ${result.message}');
          await _rollbackEmailLogin(previousToken);
          return false;
        }
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

  /// Register (new account) — never an "existing" cloud save, no overwrite dialog.
  Future<bool> registerWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      final String? error;
      if (EnvConstants.isAuthServer()) {
        error = await ServerAuthService.to.registerWithEmail(email, password);
      } else if (EnvConstants.isAuthFirebase()) {
        error = await FirebaseAuthService.to.registerWithEmail(email, password);
      } else {
        return false;
      }
      if (error != null) {
        Toast.error('${LanKey.registrationFailed.tr}: $error');
        return false;
      }

      if (EnvConstants.isFirebase() || EnvConstants.isServer()) {
        final result = await NetworkRegistry.ins.login('email');
        if (result.isFailure) {
          Toast.error('${LanKey.registrationFailed.tr}: ${result.message}');
          return false;
        }
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
    if (EnvConstants.isHive()) return;

    if (EnvConstants.isAuthServer()) {
      await ServerAuthService.to.signOut();
    } else if (Get.isRegistered<FirebaseAuthService>()) {
      await FirebaseAuthService.to.signOut();
      if (EnvConstants.isFirebase()) {
        await FirebaseAuthService.to.ensureAnonymousSession();
        await NetworkRegistry.ins.login('guest');
      }
    }
    await SpUtils.ins.remove(SpKeys.linkedEmail);
    // Keep in-memory character/tasks as "local progress" for a subsequent
    // cloud login conflict check within this session.
    if (!EnvConstants.isFirebase()) {
      await UserService.to.setSessionToken(null);
    }
    isLoggedIn.value = EnvConstants.isFirebase() && UserService.to.isLoggedIn();
    accountRevision.value++;
  }

  // ── Internals ──

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
    if (EnvConstants.isAuthFirebase()) {
      await FirebaseAuthService.to.signOut();
      await FirebaseAuthService.to.ensureAnonymousSession();
      await NetworkRegistry.ins.login('guest');
      return;
    }
    if (previousToken.isEmpty) {
      await UserService.to.setSessionToken(null);
    } else {
      await UserService.to.setSessionToken(previousToken);
    }
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
    // Refresh route if we just gained/lost a character.
    if (UserService.to.character.value == null) {
      if (Get.currentRoute != Routers.boarding) {
        Get.offAllNamed(Routers.boarding);
      }
    } else if (Get.currentRoute == Routers.boarding) {
      Get.offAllNamed(Routers.main);
    }
  }
}
