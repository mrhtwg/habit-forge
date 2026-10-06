import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/app.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/di/injection_container.dart';
import 'package:habit_forge_app/core/services/user_service.dart';

void main() {
  // Must come first: SpUtils.init() and any plugin channel call require an
  // initialized binding.
  WidgetsFlutterBinding.ensureInitialized();

  // App-wide logging (only in debug builds by default).
  Log.init();

  // Register the GetIt service locator (SpUtils and friends).
  configureDependencies();

  // Splash UI reads the default character immediately; async initialization is
  // deliberately deferred to SplashController so the first frame is not blocked.
  Get.put(UserService(), permanent: true);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  runApp(const HabitForgeApp());
}
