import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/app.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/services/audio_service.dart';
import 'package:habit_forge_app/core/services/firebase_auth_service.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/core/services/server_auth_service.dart';
import 'package:habit_forge_app/firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load date symbols for localized date formatting (zh is not built-in).
  await initializeDateFormatting('zh', null);
  await initializeDateFormatting('en', null);

  await Hive.initFlutter();
  // Open userBox early so the persisted language can be read synchronously
  // when the MaterialApp is built (AppLocale.initialLocale).
  await Hive.openBox('userBox');

  Get.put(AudioService());
  Get.put(HapticService());
  Get.put(ServerAuthService());

  // Always register FirebaseAuthService so AuthController can find it.
  // Firebase initialization only happens in firebase storage/auth mode.
  final firebaseAuth = FirebaseAuthService();

  if (EnvConstants.isFirebase()) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      firebaseAuth.markAvailable();
      await firebaseAuth.initGoogleSignIn();
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Firebase not configured ($e). Auth will use local mock.');
    }
  } else {
    debugPrint('Non-Firebase mode: Firebase auth skipped (local or backend auth).');
  }

  Get.put(firebaseAuth);
  runApp(const HabitForgeApp());
}
