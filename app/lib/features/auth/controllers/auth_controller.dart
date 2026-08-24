import 'package:get/get.dart';
import 'package:habit_forge_app/core/routes/app_routes.dart';
import 'package:habit_forge_app/core/services/firebase_auth_service.dart';
import 'package:habit_forge_app/core/services/hive_service.dart';

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
        Get.snackbar('Apple Login Failed', error);
        return false;
      }
      HiveService.to.setLoggedIn(true, method: 'apple');
      isLoggedIn.value = true;
      _checkOnboardingAndRoute();
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Email/Password login
  Future<bool> loginWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      final error = await FirebaseAuthService.to.loginWithEmail(email, password);
      if (error != null) {
        Get.snackbar('Login Failed', error);
        return false;
      }
      HiveService.to.setLoggedIn(true, method: 'email');
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
        Get.snackbar('Google Login Failed', error);
        return false;
      }
      HiveService.to.setLoggedIn(true, method: 'google');
      isLoggedIn.value = true;
      _checkOnboardingAndRoute();
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await FirebaseAuthService.to.signOut();
    HiveService.to.setLoggedIn(false);
    isLoggedIn.value = false;
    Get.offAllNamed(Routers.login);
  }

  @override
  void onInit() {
    super.onInit();
    _checkLoginState();
  }

  /// Register new Email account
  Future<bool> registerWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      final error = await FirebaseAuthService.to.registerWithEmail(email, password);
      if (error != null) {
        Get.snackbar('Registration Failed', error);
        return false;
      }
      HiveService.to.setLoggedIn(true, method: 'email');
      isLoggedIn.value = true;
      Get.offAllNamed(Routers.boarding);
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Skip login as guest
  void skipLogin() {
    HiveService.to.setLoggedIn(true, method: 'guest');
    isLoggedIn.value = true;
    Get.offAllNamed(Routers.boarding);
  }

  void _checkLoginState() {
    // Check persisted Hive state
    if (HiveService.to.isLoggedIn) {
      isLoggedIn.value = true;
    }
  }

  void _checkOnboardingAndRoute() {
    final prefs = HiveService.to.userPrefs.value;
    if (prefs == null || !prefs.onboardingCompleted) {
      Get.offAllNamed(Routers.boarding);
    } else {
      Get.offAllNamed(Routers.main);
    }
  }
}
