import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase options built from `env/firebase.json` (`--dart-define-from-file`).
///
/// Fill `apiKey` / `appId` / `messagingSenderId` / `projectId` / `storageBucket`
/// in `env/firebase.json` before running the app. See `docs/firebase-setup.md`.
class DefaultFirebaseOptions {
  static const String _apiKey = String.fromEnvironment('apiKey');
  static const String _appId = String.fromEnvironment('appId');
  static const String _messagingSenderId = String.fromEnvironment('messagingSenderId');
  static const String _projectId = String.fromEnvironment('projectId');
  static const String _storageBucket = String.fromEnvironment('storageBucket');

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: _apiKey,
        appId: _appId,
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
      );

  static FirebaseOptions get currentPlatform {
    // Default to Android config — works on both platforms until iOS keys are added.
    return android;
  }

  /// Whether `env/firebase.json` has non-placeholder options filled in.
  static bool get isConfigured {
    const key = _apiKey;
    const project = _projectId;
    if (key.isEmpty || project.isEmpty) return false;
    if (key.startsWith('YOUR_') || project.startsWith('YOUR_')) return false;
    return true;
  }
}
