# HabitForge App (Flutter)

> RPG-style habit tracker — the Flutter client of the HabitForge repository (`app/`).

HabitForge turns real-life tasks into an RPG character growth loop: complete tasks to earn **EXP** and **gold**, level up your character, spend gold on cosmetics in the **Forge**, and keep your streaks alive.

The app is **local-first**: all game data lives in Hive on-device. Firebase Auth + Firestore are optional and enabled in `firebase` mode. There is no server component in the MVP. See the repository [root README](../README.md) for the proto contracts and the product & design docs.

## Features

### Task management

- Three task types — **Habit**, **Daily**, **ToDo** — with weekday repeat for dailies and due dates for todos
- Difficulty levels (`easy` / `medium` / `hard`) that drive EXP & gold rewards
- Tags, priority, streak tracking, HP penalty, and postpone / skip actions
- Swipeable task list (complete / postpone / skip / delete) via `flutter_slidable`

### RPG character loop

- Pick a class — **Warrior**, **Mage**, or **Ranger** — each rendered with a PNG frame-sequence idle animation (62 / 62 / 50 frames; the Ranger export duplicated its first 21 frames at the tail, which were trimmed for a seamless loop)
- Earn EXP and gold from completed tasks; base rewards scale with difficulty and streaks apply a multiplier (up to ×2.0)
- Level up to **max level 50** with a progressive EXP curve; spend stat points on six attributes — **INT** +1% EXP/point, **STR** +1% gold/point, **VIT** +2 HP cap/point, **DEF** −1 HP damage/point (AGI / LUK effects pending)
- HP system: skipped or overdue tasks cost HP; at 0 HP the character dies and recovers after **30 minutes** with partial HP

### Forge & economy

- Shop with items categorized by rarity, priced in **gold** (plus a **gems** currency)
- **Daily deal**: a rotating discounted item with an expiry timestamp
- Owned items persist and show up on the character page (weapon / helmet / armor / accessory slots)

### Progress & profile

- **Achievements** with unlock thresholds and gem rewards
- **Statistics** page with time-segment bar charts and streak leaderboards
- Profile page with quick links; settings for sound, haptics, and notifications

### Onboarding & auth

- 4-step onboarding: Welcome → Class → Habit → Ready
- The app uses Firebase for cloud identity and signed-in saves
- Guest play remains local-first in Hive until the player links a Google account

### Freemium & subscription

- Free: 3 habit slots, Warrior only, week stats, ads allowed, no legendary gear
- Premium monthly / yearly / lifetime unlock unlimited habits, all classes, advanced stats, exclusive gear, no ads (see `docs/subscription.md`)
- Play Billing via `in_app_purchase`; paid access is enabled only after server-side purchase verification

## Tech Stack

| Area                 | Choice                                                                                                    |
| -------------------- | --------------------------------------------------------------------------------------------------------- |
| Framework            | Flutter (`.fvmrc` pins 3.41.6)                                                                            |
| State / DI / Routing | GetX                                                                                                      |
| Local storage        | Hive + hive_flutter                                                                                       |
| Auth (prod)          | firebase_auth, google_sign_in, sign_in_with_apple                                                         |
| UI                   | flutter_screenutil (393×852 design size), phosphor_flutter icons, custom fonts (Baloo2 / Nunito / Caveat) |
| i18n                 | GetX translations + flutter_localizations (English / 中文)                                                |
| Effects              | Lottie, audioplayers, haptics service, frame-sequence PNG animation player                                |
| Other                | uuid, intl, flutter_slidable, carousel_slider                                                             |

## Getting Started

```bash
cd app
flutter pub get
flutter run --dart-define-from-file=env/firebase.json
```

### Data storage

Firebase is the only cloud backend. Signed-out guest progress stays in on-device Hive and can be merged into a Firebase account later. Weak networks cannot block entering the app because cloud restore times out and falls back to the local guest save.

#### `env/firebase.json` (required keys, gitignored)

```bash
cp env/firebase.json.example env/firebase.json
```

```json
{
  "apiKey": "YOUR_ANDROID_API_KEY",
  "appId": "YOUR_ANDROID_APP_ID",
  "messagingSenderId": "YOUR_PROJECT_NUMBER",
  "projectId": "YOUR_PROJECT_ID",
  "storageBucket": "YOUR_PROJECT_ID.appspot.com"
}
```

Replace every `YOUR_*` value from Firebase Console (or `google-services.json`). `lib/firebase_options.dart` reads these via `--dart-define-from-file`. Do **not** commit the filled `env/firebase.json`, `google-services.json`, or Android signing files — see root `.gitignore` and `docs/firebase-setup.md`.

## Project Layout

```text
app/
├── lib/
│   ├── main.dart                 # entry: services, Firebase, runApp
│   ├── app.dart                  # HabitForgeApp: GetMaterialApp, theme, routes
│   ├── core/
│   │   ├── common/               # frame-sequence animation player
│   │   ├── constants/            # app / game constants
│   │   ├── extensions/           # date helpers
│   │   ├── routes/               # GetX route table
│   │   ├── services/             # audio, haptics, Hive, Firebase auth
│   │   └── theme/                # colors, spacing, typography, app theme
│   ├── features/                 # feature-first modules (bindings / controllers / pages)
│   │   ├── splash / auth / boarding / main
│   │   ├── home / quests / forge / profile
│   │   ├── character / achievements / statistics / settings / rewards
│   ├── models/                   # task, character, shop, achievement, user prefs
│   ├── generated/                # assets.dart (generated — do not edit)
│   └── widgets/                  # shared UI widgets
├── assets/
│   ├── animations/               # knight_idle / mage_idle / ranger_idle frame sequences
│   ├── fonts/                    # Baloo2, Nunito, Caveat
│   └── images/                   # characters, home, shared
├── env/                          # hive.json / server.json + firebase.json.example (local firebase.json is gitignored)
├── tool/
│   └── generate_assets.dart      # regenerates lib/generated/assets.dart
├── thirdpart/                    # vendored packages (svgaplayer_flutter)
├── docs/
│   └── firebase-setup.md
├── build_habit_android.sh        # Android release build helper
└── pubspec.yaml
```

## Internationalization

The app supports **English** and **中文** (Simplified Chinese):

- Keys are defined as an enum in `lib/core/i18n/lan_key.dart` and used as `LanKey.save.tr` (with `trParams(...)` for placeholders).
- Per-language copy lives in `lib/core/i18n/en_us.dart` and `lib/core/i18n/zh_cn.dart`; `lib/core/i18n/app_translations.dart` wires them into GetX.
- Data-driven lookups use enum helpers: `LanKey.difficultyFor(value)`, `LanKey.taskType(type)`, `LanKey.characterClass(name)`, `LanKey.achievementTitle(id)`.
- The active language (English by default; 中文 selectable) is persisted in Hive and can be changed in **Settings → Language** — see `lib/core/i18n/app_locale.dart`.
- Dates are formatted with the active locale through `intl` (`DateFormat(..., AppLocale.languageCode())`, date symbols initialized in `main()`).
- Code comments and TODOs intentionally stay in English.

## Assets

Assets are declared in `pubspec.yaml`, and constant paths are generated into `lib/generated/assets.dart` (an `Assets` class plus a `FontFamily` class). After adding or removing assets, regenerate:

```bash
cd app
dart run tool/generate_assets.dart
```

The generator scans `assets/` and skips folders listed in `_excludeAssetDirs` (by default the large animation frame sequences — `assets/animations/knight_idle`, `mage_idle`, `ranger_idle`). Add new exclusions to that list in `tool/generate_assets.dart`.

## Build (Android release)

```bash
./build_habit_android.sh --env hive --build-name 1.0.0 --build-number 1 --type apk
```

Options: `--env hive|firebase|server`, `--build-name`, `--build-number`, `--type apk|aab`, `--verbose`.

## Test

```bash
flutter test
```

## Related

- Repository root — [../README.md](../README.md)
- Data contracts (`proto/`), product & design docs (`docs/`)
