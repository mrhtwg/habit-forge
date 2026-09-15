import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/app.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/di/injection_container.dart';
import 'package:habit_forge_app/core/network/hive/shop_config.dart';
import 'package:habit_forge_app/core/network/network_bootstrap.dart';
import 'package:habit_forge_app/core/services/audio_service.dart';
import 'package:habit_forge_app/core/services/firebase_auth_service.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/core/services/server_auth_service.dart';
import 'package:habit_forge_app/core/services/subscription_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/features/auth/controllers/auth_controller.dart';
import 'package:habit_forge_app/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Must come first: SpUtils.init() and any plugin channel call require an
  // initialized binding.
  WidgetsFlutterBinding.ensureInitialized();

  // App-wide logging (only in debug builds by default).
  Log.init();

  // Register the GetIt service locator (SpUtils and friends).
  configureDependencies();

  registerNetworkMode(EnvConstants.networkMode);

  await SpUtils.init();

  // Load date symbols for localized date formatting (zh is not built-in).
  await initializeDateFormatting('zh', null);
  await initializeDateFormatting('en', null);

  // await Hive.initFlutter();
  // Open userBox early so the persisted language can be read synchronously
  // when the MaterialApp is built (AppLocale.initialLocale).
  // await Hive.openBox('userBox');

  Get.put(AudioService());
  Get.put(HapticService());
  Get.put(UserService(), permanent: true);
  await UserService.to.init();
  await ShopConfig.load();

  final subscription = SubscriptionService();
  Get.put(subscription, permanent: true);
  await subscription.init();

  final firebaseAuth = FirebaseAuthService();
  // Firebase mode: initialize the SDK only (needed later for Settings sign-in).
  // Do NOT create anonymous sessions or hit Firestore here — that happens after
  // explicit Settings login (see FirebaseSession / SplashController).
  if (EnvConstants.isFirebase() || EnvConstants.isAuthFirebase()) {
    try {
      if (!DefaultFirebaseOptions.isConfigured) {
        throw StateError(
          'Firebase options missing. Fill apiKey/appId/messagingSenderId/'
          'projectId/storageBucket in env/firebase.json',
        );
      }
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).timeout(const Duration(seconds: 8));
      firebaseAuth.markAvailable();
      await firebaseAuth.initGoogleSignIn();
      debugPrint('Firebase SDK initialized (auth deferred to Settings)');
    } catch (e) {
      debugPrint('Firebase not configured ($e). Local Hive will be used until sign-in.');
    }
  }
  Get.put(firebaseAuth);
  // After Firebase so AuthController.onInit can safely inspect cloud identity.
  Get.put(AuthController(), permanent: true);
  if (EnvConstants.isAuthServer()) {
    Get.put(ServerAuthService());
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const HabitForgeApp());
}
