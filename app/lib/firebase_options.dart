import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Default Firebase options for each platform.
///
/// This is a public template. Replace the values with your own Firebase project
/// configuration before running in production mode.
///
/// See `app/docs/firebase-setup.md` for detailed setup steps.
class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_PROJECT_NUMBER',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static FirebaseOptions get currentPlatform {
    // Default to Android config — works on both platforms.
    // iOS needs registration in Firebase Console first.
    return android;
  }

  /// iOS options — UNCOMMENT after registering iOS app in Firebase Console.
  /// Go to Firebase Console → Project Settings → Add app → iOS.
  /// Bundle ID: com.habitforge.habitforge
  /// Copy the values from the downloaded GoogleService-Info.plist.
  // static const FirebaseOptions ios = FirebaseOptions(
  //   apiKey: 'YOUR_IOS_API_KEY',
  //   appId: '1:YOUR_PROJECT_NUMBER:ios:YOUR_IOS_CLIENT_ID',
  //   messagingSenderId: 'YOUR_PROJECT_NUMBER',
  //   projectId: 'YOUR_PROJECT_ID',
  //   storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  //   iosClientId: 'YOUR_IOS_CLIENT_ID',
  //   iosBundleId: 'com.habitforge.habitforge',
  // );
}
