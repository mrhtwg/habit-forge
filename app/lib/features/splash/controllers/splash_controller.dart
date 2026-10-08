import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/i18n/app_locale.dart';
import 'package:habit_forge_app/core/network/hive/shop_config.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/audio_service.dart';
import 'package:habit_forge_app/core/services/death_recovery_service.dart';
import 'package:habit_forge_app/core/services/entitlement_service.dart';
import 'package:habit_forge_app/core/services/firebase_auth_service.dart';
import 'package:habit_forge_app/core/services/firebase_session.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/core/services/subscription_service.dart';
import 'package:habit_forge_app/core/services/rewarded_ad_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/features/auth/controllers/auth_controller.dart';
import 'package:habit_forge_app/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

class SplashController extends GetxController {
  static const _minimumDisplayTime = Duration(milliseconds: 800);
  bool _isInitializing = false;

  Future<void> loadAndRouteEntry() async {
    if (_isInitializing) return;
    _isInitializing = true;
    final startedAt = DateTime.now();

    await _initializeApp();

    // Local-first: no anonymous Auth / Firestore on cold start.
    // Cloud restore only if the user previously signed in from Settings.
    await FirebaseSession.bootstrapAtSplash();

    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < _minimumDisplayTime) {
      await Future<void>.delayed(_minimumDisplayTime - elapsed);
    }

    await UserService.to.loadUserPrefs();
    await UserService.to.loadCharacter();

    // Login gate (cloud builds): a fresh install with no account and nothing to
    // resume lands on the sign-in screen, so a returning player reaches their save
    // in one tap instead of digging into Settings. Deliberately not a login
    // *wall*: a guest who already has progress goes straight into the game and
    // gets the in-app "bind an account" banner instead.
    if (_needsLoginGate()) {
      Get.offAllNamed(Routers.login);
      return;
    }

    if (UserService.to.character.value == null) {
      Get.offAllNamed(Routers.boarding);
    } else {
      Get.offAllNamed(Routers.main);
    }
  }

  Future<void> _initializeApp() async {
    await SpUtils.init();
    await UserService.to.init();

    final locale = AppLocale.resolve(AppLocale.current()) ?? const Locale('en');
    await Get.updateLocale(locale);

    Get.put(AudioService(), permanent: true);
    Get.put(HapticService(), permanent: true);
    Get.put(EntitlementService(), permanent: true);

    final firebaseAuth = FirebaseAuthService();
    Get.put(firebaseAuth, permanent: true);

    final subscription = SubscriptionService();
    Get.put(subscription, permanent: true);
    final rewardedAds = RewardedAdService();
    Get.put(rewardedAds, permanent: true);

    await Future.wait<void>([
      initializeDateFormatting('zh', null),
      initializeDateFormatting('en', null),
      ShopConfig.load(),
      _initializeFirebase(firebaseAuth),
      subscription.init(),
      rewardedAds.init(),
    ]);

    // Auth state must be inspected only after Firebase initialization finishes.
    Get.put(AuthController(), permanent: true);
    Get.put(DeathRecoveryService(), permanent: true);
  }

  Future<void> _initializeFirebase(FirebaseAuthService firebaseAuth) async {
    try {
      if (!DefaultFirebaseOptions.isConfigured) {
        throw StateError(
          'Firebase options missing. Fill apiKey/appId/messagingSenderId/'
          'projectId/storageBucket in env/firebase.json',
        );
      }
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(FirebaseSession.networkTimeout);
      await firebaseAuth.initGoogleSignIn(serverClientId: DefaultFirebaseOptions.googleServerClientId);
      firebaseAuth.markAvailable();
      Log.d('Firebase SDK initialized (auth deferred to Settings)');
    } catch (e) {
      Log.d('Firebase not configured ($e). Local Hive will be used until sign-in.');
    }
  }

  /// Whether to show the sign-in gate instead of resuming into the game.
  bool _needsLoginGate() {
    if (Get.isRegistered<AuthController>() && AuthController.to.hasCloudIdentity) return false;
    return UserService.to.character.value == null;
  }

  @override
  void onInit() {
    super.onInit();
    loadAndRouteEntry();
  }
}
