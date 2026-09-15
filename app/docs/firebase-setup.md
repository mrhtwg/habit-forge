# Firebase Configuration

## You need to replace all placeholder values with your real Firebase project values.

**Do not commit** local secrets or project binding files. Git ignores:

- `android/key.properties`, `android/jks/*.jks`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `env/firebase.json` (copy from `env/firebase.json.example`)

Committed templates: `*.example` only.

### Step 1: Get values from Firebase Console

1. Go to https://console.firebase.google.com
2. Select your project
3. Project Settings → General → Your apps → Add app → Android
4. Package name: `com.habitforge.habitforge`
5. Add **your** signing key SHA-1 (see Step 5b) — never commit the keystore itself
6. Download `google-services.json`
7. Place it at `android/app/google-services.json` (gitignored; see `google-services.json.example`)

### Step 2: Fill `env/firebase.json`

```bash
cp env/firebase.json.example env/firebase.json
# then edit env/firebase.json with your project values
```

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

- Register the SHA-1 of the keystore that signs your debug/release APK in Firebase Console → Project Settings → Your Android app
- Keep `android/app/google-services.json` in sync with the same project

### Step 4: iOS — Add app in Firebase Console

1. Firebase Console → Project Settings → Add app → iOS
2. Bundle ID: `com.habitforge.habitforge`
3. Download `GoogleService-Info.plist` → place at `ios/Runner/GoogleService-Info.plist` (gitignored)
4. For now Android keys in `env/firebase.json` are used as `currentPlatform`; add iOS-specific defines later if needed
5. Enable Google Sign-In: in plist, find `REVERSED_CLIENT_ID`

### Step 5: Firestore

1. Firebase Console → Build → Firestore Database → Create database
2. Start in **production** mode (or test mode briefly), then **deploy** the rules in `app/firebase/firestore.rules`.

Rules are **not** applied automatically from the repo. Until you deploy them, every read/write returns `PERMISSION_DENIED` (even for signed-in / anonymous users).

**Option A — Console paste**

1. Firebase Console → Firestore → Rules
2. Paste the contents of `app/firebase/firestore.rules`
3. Publish

**Option B — CLI**

```bash
cd app
# npm i -g firebase-tools && firebase login && firebase use <your-project-id>
firebase deploy --only firestore:rules
```

3. Authentication → Sign-in method → enable **Google** (Anonymous is **not** required; the app plays on local Hive until Settings sign-in)

> Firebase mode runs game logic on the client (same as Hive). Firestore rules only
> isolate per-user data. For server-authoritative economy / IAP verification, use
> the Go backend (or Cloud Functions) later.

### Step 5b: Fix `DEVELOPER_ERROR` / Google Sign-In on device

`ConnectionResult{statusCode=DEVELOPER_ERROR}` almost always means the **SHA-1** of the keystore that signed your APK is missing from Firebase.

```bash
# Flutter default debug keystore:
keytool -list -v -alias androiddebugkey \
  -keystore ~/.android/debug.keystore \
  -storepass android -keypass android | grep SHA1

# Or the release/custom keystore from android/key.properties (gitignored):
keytool -list -v -alias forge \
  -keystore android/jks/habitforge.jks
```

1. Copy the `SHA1` value for **the same keystore** Gradle uses to sign the APK
2. Firebase Console → Project Settings → Your Android app → Add fingerprint
3. Download a fresh `google-services.json` into `android/app/`
4. Rebuild the app (`flutter clean && flutter run --dart-define-from-file=env/firebase.json`)

Also ensure `env/firebase.json` `projectId` / `appId` / `apiKey` match the same project as `google-services.json`.

### Step 6: Run the app in firebase mode

```bash
cd app
cp env/firebase.json.example env/firebase.json   # once
# edit env/firebase.json, then:
flutter run --dart-define-from-file=env/firebase.json
```

If placeholders are left as `YOUR_*`, startup logs `Firebase not configured` and cloud auth stays unavailable.

### Log noise you can ignore

| Log                                           | Meaning                                                             |
| --------------------------------------------- | ------------------------------------------------------------------- |
| `BillingClient ... Response code: 3`          | Play Billing unavailable on sideload/debug — OK until IAP is set up |
| `gRPC Channel initialized for localhost:9000` | Was GetIt eager-init (fixed to lazy); only needed in server mode    |
| `ProviderInstaller` / Phenotype warnings      | Common GMS noise on some devices; not fatal if Auth/Firestore work  |
