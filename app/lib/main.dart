import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/app.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/di/injection_container.dart';
import 'package:habit_forge_app/core/network/network_bootstrap.dart';
import 'package:habit_forge_app/core/services/audio_service.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
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
  // Get.put(ServerAuthService());
  Get.put(UserService(), permanent: true);
  await UserService.to.init();

  // Always register FirebaseAuthService so AuthController can find it.
  // Firebase initialization only happens in firebase storage/auth mode.
  // final firebaseAuth = FirebaseAuthService();

  // if (EnvConstants.isFirebase()) {
  //   try {
  //     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //     firebaseAuth.markAvailable();
  //     await firebaseAuth.initGoogleSignIn();
  //     debugPrint('Firebase initialized successfully');
  //   } catch (e) {
  //     debugPrint('Firebase not configured ($e). Auth will use local mock.');
  //   }
  // } else {
  //   debugPrint('Non-Firebase mode: Firebase auth skipped (local or backend auth).');
  // }

  // Get.put(firebaseAuth);

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
