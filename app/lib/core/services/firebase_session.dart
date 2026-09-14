import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/network_firebase_impl.dart';
import 'package:habit_forge_app/core/network/network_hive_impl.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/services/firebase_auth_service.dart';
import 'package:habit_forge_app/core/services/user_service.dart';
import 'package:habit_forge_app/generated/protos/auth/v1/auth.pb.dart';

/// Firebase-mode session routing: local Hive until the user explicitly signs
/// in from Settings; Firestore only after a non-anonymous cloud identity.
class FirebaseSession {
  FirebaseSession._();

  static const networkTimeout = Duration(seconds: 8);

  /// Google / email account (not anonymous guest).
  static bool get hasLinkedCloudUser {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && !user.isAnonymous;
  }

  /// Play offline / before Settings auth — no Firestore, no anonymous login.
  static Future<void> useLocalBackend() async {
    await _dropAnonymousIfAny();
    NetworkRegistry.register(NetworkHiveImpl());
    await NetworkRegistry.ins.init();
    if (!UserService.to.isLoggedIn()) {
      await NetworkRegistry.ins.login('guest');
    }
  }

  /// After Settings Google/email success (or splash restore of a linked user).
  static Future<ApiResponse<LoginReply>> useCloudBackend({String provider = 'google'}) async {
    NetworkRegistry.register(NetworkFirebaseImpl());
    await NetworkRegistry.ins.init();
    return NetworkRegistry.ins.login(provider);
  }

  /// Splash helper: restore cloud only when already signed in; otherwise local.
  /// Network failures fall back to Hive so a bad connection cannot block entry.
  static Future<void> bootstrapAtSplash() async {
    final available = Get.isRegistered<FirebaseAuthService>() && FirebaseAuthService.to.isAvailable;
    if (!available) {
      await useLocalBackend();
      return;
    }

    if (!hasLinkedCloudUser) {
      await useLocalBackend();
      return;
    }

    try {
      final result = await useCloudBackend().timeout(networkTimeout);
      if (result.isFailure) {
        Log.w('Cloud restore failed (${result.message}), using local backend');
        await useLocalBackend();
      }
    } catch (e) {
      Log.w('Cloud restore timed out / error ($e), using local backend');
      await useLocalBackend();
    }
  }

  static Future<void> _dropAnonymousIfAny() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !user.isAnonymous) return;
    try {
      if (Get.isRegistered<FirebaseAuthService>()) {
        await FirebaseAuthService.to.signOut();
      } else {
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      Log.w('Failed to clear anonymous session: $e');
    }
  }
}
