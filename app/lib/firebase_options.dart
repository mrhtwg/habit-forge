import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:habit_forge_app/core/constants/env_constants.dart';

/// Firebase options built from `env/firebase.json` (`--dart-define-from-file`).
///
/// Fill `apiKey` / `appId` / `messagingSenderId` / `projectId` / `storageBucket`
/// in `env/firebase.json` before running firebase mode. See `docs/firebase-setup.md`.
class DefaultFirebaseOptions {
  static FirebaseOptions get android => FirebaseOptions(
        apiKey: EnvConstants.firebaseApiKey,
        appId: EnvConstants.firebaseAppId,
        messagingSenderId: EnvConstants.firebaseMessagingSenderId,
        projectId: EnvConstants.firebaseProjectId,
        storageBucket: EnvConstants.firebaseStorageBucket,
      );

  static FirebaseOptions get currentPlatform {
    // Default to Android config — works on both platforms until iOS keys are added.
    return android;
  }

  /// Whether `env/firebase.json` has non-placeholder options filled in.
  static bool get isConfigured {
    final key = EnvConstants.firebaseApiKey;
    final project = EnvConstants.firebaseProjectId;
    if (key.isEmpty || project.isEmpty) return false;
    if (key.startsWith('YOUR_') || project.startsWith('YOUR_')) return false;
    return true;
  }
}
