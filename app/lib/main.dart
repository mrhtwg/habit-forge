import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/app.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/services/audio_service.dart';
import 'package:habit_forge_app/core/services/firebase_auth_service.dart';
import 'package:habit_forge_app/core/services/haptic_service.dart';
import 'package:habit_forge_app/firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Get.put(AudioService());
  Get.put(HapticService());

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
