# Firebase Configuration

## You need to replace all placeholder values with your real Firebase project values.

### Step 1: Get values from Firebase Console

1. Go to https://console.firebase.google.com
2. Select your project
3. Project Settings → General → Your apps → Add app → Android
4. Package name: `com.habitforge.habitforge`
5. SHA-1: `D7:E5:F3:3F:A2:16:04:13:AC:8B:EA:0E:8A:58:C9:9F:9D:27:9C:75`
6. Download `google-services.json`
7. Replace `android/app/google-services.json` with it

### Step 2: Fill `env/firebase.json`

Flutter reads Firebase options from this file via `--dart-define-from-file` (not from `lib/firebase_options.dart` hardcoding).

```json
{
  "env": "firebase",
  "network": "firebase",
  "auth": "firebase",
  "apiKey": "YOUR_ANDROID_API_KEY",
  "appId": "YOUR_ANDROID_APP_ID",
  "messagingSenderId": "YOUR_PROJECT_NUMBER",
  "projectId": "YOUR_PROJECT_ID",
  "storageBucket": "YOUR_PROJECT_ID.appspot.com"
}
```

| Key                 | Where to find it                                                                                                |
| ------------------- | --------------------------------------------------------------------------------------------------------------- |
| `apiKey`            | Firebase Console → Project Settings → General → Web API Key (or `google-services.json` → `api_key.current_key`) |
| `appId`             | `google-services.json` → `client[].client_info.mobilesdk_app_id`                                                |
| `messagingSenderId` | Project number / `project_number`                                                                               |
| `projectId`         | Project ID / `project_id`                                                                                       |
| `storageBucket`     | Usually `<project-id>.appspot.com` or `<project-id>.firebasestorage.app`                                        |

`lib/firebase_options.dart` only maps these defines into `FirebaseOptions` — do **not** put secrets/project ids there.

### Step 3: Google Sign-In

For Google Sign-In to work on Android:

- Add SHA-1 `D7:E5:F3:3F:A2:16:04:13:AC:8B:EA:0E:8A:58:C9:9F:9D:27:9C:75` in Firebase Console → Authentication → Sign-in method → Google
- Keep `android/app/google-services.json` in sync with the same project

### Step 4: iOS — Add app in Firebase Console

1. Firebase Console → Project Settings → Add app → iOS
2. Bundle ID: `com.habitforge.habitforge`
3. Download `GoogleService-Info.plist` → replace `ios/Runner/GoogleService-Info.plist`
4. For now Android keys in `env/firebase.json` are used as `currentPlatform`; add iOS-specific defines later if needed
5. Enable Google Sign-In: in plist, find `REVERSED_CLIENT_ID`

### Step 5: Firestore

1. Firebase Console → Build → Firestore Database → Create database
2. Start in production mode, then deploy the rules in `app/firebase/firestore.rules`:

```bash
cd app
firebase deploy --only firestore:rules
```

3. Enable Authentication → Sign-in method → Google (and Anonymous if you use guest upgrade)

> Firebase mode runs game logic on the client (same as Hive). Firestore rules only
> isolate per-user data. For server-authoritative economy / IAP verification, use
> the Go backend (or Cloud Functions) later.

### Step 6: Run the app in firebase mode

```bash
cd app
# Fill env/firebase.json first, then:
flutter run --dart-define-from-file=env/firebase.json
```

If placeholders are left as `YOUR_*`, startup logs `Firebase not configured` and cloud auth stays unavailable.
