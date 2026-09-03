import 'package:get/get.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/firebase_auth_service.dart';
import 'package:habit_forge_app/core/services/server_auth_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/widgets/toast_widget.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final isLoading = false.obs;
  final isLoggedIn = false.obs;

  /// Apple Sign-In
  Future<bool> loginWithApple() async {
    isLoading.value = true;
    try {
      final error = await FirebaseAuthService.to.loginWithApple();
      if (error != null) {
        Toast.error('${LanKey.appleLoginFailed.tr}: $error');
        return false;
      }
      isLoggedIn.value = true;
      _checkOnboardingAndRoute();
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Email/Password login
  /// Server mode → self-hosted backend; otherwise → Firebase (future extension).
  Future<bool> loginWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      final String? error;
      if (EnvConstants.isAuthServer()) {
        error = await ServerAuthService.to.loginWithEmail(email, password);
      } else {
        error = await FirebaseAuthService.to.loginWithEmail(email, password);
      }
      if (error != null) {
        Toast.error('${LanKey.loginFailed.tr}: $error');
        return false;
      }
      isLoggedIn.value = true;
      _checkOnboardingAndRoute();
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Google Sign-In
  Future<bool> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final error = await FirebaseAuthService.to.loginWithGoogle();
      if (error != null) {
        Toast.error('${LanKey.googleLoginFailed.tr}: $error');
        return false;
      }
      isLoggedIn.value = true;
      _checkOnboardingAndRoute();
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout
  Future<void> logout() async {
    if (EnvConstants.isAuthServer()) {
      await ServerAuthService.to.signOut();
    } else {
      await FirebaseAuthService.to.signOut();
    }
    await UserService.to.setSessionToken(null);
    isLoggedIn.value = false;
    // Hive (local) mode has no real login — return to onboarding instead of the login page.
    Get.offAllNamed(EnvConstants.isHive() ? Routers.boarding : Routers.login);
  }

  @override
  void onInit() {
    super.onInit();
    _checkLoginState();
  }

  /// Register new Email account
  /// Server mode → self-hosted backend (no email verification);
  /// otherwise → Firebase (future extension).
  Future<bool> registerWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      final String? error;
      if (EnvConstants.isAuthServer()) {
        error = await ServerAuthService.to.registerWithEmail(email, password);
      } else {
        error = await FirebaseAuthService.to.registerWithEmail(email, password);
      }
      if (error != null) {
        Toast.error('${LanKey.registrationFailed.tr}: $error');
        return false;
      }
      isLoggedIn.value = true;
      Get.offAllNamed(Routers.boarding);
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Skip login as guest
  /// Guest login: hive mode mints a local token through the auth facade.
  Future<void> skipLogin() async {
    final result = await NetworkRegistry.ins.login('guest');
    if (result.isFailure) return;
    isLoggedIn.value = true;
    Get.offAllNamed(Routers.boarding);
  }

  void _checkLoginState() {
    // Check persisted Hive state
    if (UserService.to.isLoggedIn()) {
      isLoggedIn.value = true;
    }
  }

  void _checkOnboardingAndRoute() {
    // final prefs = NetworkRegistry.ins.userPrefs.value;
    // if (prefs == null) {
    //   Get.offAllNamed(Routers.boarding);
    // } else {
    //   Get.offAllNamed(Routers.main);
    // }
  }
}
