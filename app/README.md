# HabitForge App (Flutter)

> RPG-style habit tracker — the Flutter client of the HabitForge monorepo (`app/`).

HabitForge turns real-life tasks into an RPG character growth loop: complete tasks to earn **EXP** and **gold**, level up your character, spend gold on cosmetics in the **Forge**, and keep your streaks alive.

The app is **local-first**: all game data lives in Hive on-device. Firebase Auth is optional and enabled in `firebase` mode. See the repository [root README](../README.md) for the full monorepo (Go backend, proto contracts, product & design docs).

## Features

### Task management
- Three task types — **Habit**, **Daily**, **ToDo** — with weekday repeat for dailies and due dates for todos
- Difficulty levels (`easy` / `medium` / `hard`) that drive EXP & gold rewards
- Tags, priority, streak tracking, HP penalty, and postpone / skip actions
- Swipeable task list (complete / postpone / skip / delete) via `flutter_slidable`

### RPG character loop
- Pick a class — **Warrior**, **Mage**, or **Ranger** — each rendered with a PNG frame-sequence idle animation (62 / 62 / 72 frames)
- Earn EXP and gold from completed tasks; base rewards scale with difficulty and streaks apply a multiplier (up to ×2.0)
- Level up to **max level 50** with a progressive EXP curve; spend stat points on six attributes (STR / INT / AGI / DEF / VIT / LUK)
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
- Hive (local) mode runs with **guest/local mock auth** and no backend
- Firebase mode offers **Google Sign-In only** (email/Apple to be added later)
- Server mode offers **email/password** login with a **registration** entry (no email verification)

## Tech Stack

| Area | Choice |
|---|---|
| Framework | Flutter (`.fvmrc` pins 3.41.6) |
| State / DI / Routing | GetX |
| Local storage | Hive + hive_flutter |
| Auth (prod) | firebase_auth, google_sign_in, sign_in_with_apple |
| UI | flutter_screenutil (393×852 design size), phosphor_flutter icons, custom fonts (Baloo2 / Nunito / Caveat) |
| i18n | GetX translations + flutter_localizations (English / 中文) |
| Effects | Lottie, audioplayers, haptics service, frame-sequence PNG animation player |
| Other | uuid, intl, flutter_slidable, carousel_slider |

## Getting Started

```bash
cd app
flutter pub get
flutter run --dart-define-from-file=env/hive.json
```

### Data & backend modes

The runtime mode is selected by the `env/` config file passed via `--dart-define-from-file`. Three modes are supported:

| Mode | File | Data storage | Auth |
|---|---|---|---|
| Hive (default) | `env/hive.json` | Local on-device (Hive) | Guest / local mock |
| Firebase | `env/firebase.json` | Firebase (cloud data + auth) | Google Sign-In (only) |
| Server | `env/server.json` | Self-hosted backend (`apiUrl`) | Email/password + registration (no verification) |

- **Hive** — local-first mode, no backend required; the login page is skipped and the app enters directly (guest/local auth), Firebase is never initialized.
- **Firebase** — initializes Firebase for cloud-backed auth and data; offers **Google Sign-In only** for now (email/Apple to be added later); requires [Firebase setup](docs/firebase-setup.md) and valid platform config in `lib/firebase_options.dart`.
- **Server** — targets the self-hosted Go backend; offers **email/password login** with a **registration** entry (`POST /api/v1/auth/login` / `/api/v1/auth/register`); registration requires **no email verification**. The base URL comes from `apiUrl` in `env/server.json` (defaults to `http://localhost:8080`).

The active mode is exposed through `EnvConstants` (`lib/core/constants/env_constants.dart`) — `storageMode`, `authMode`, `apiBaseUrl`, and helpers `isHive()` / `isFirebase()` / `isServer()`.

## Project Layout

```text
app/
├── lib/
│   ├── main.dart                 # entry: Hive init, services, Firebase (prod), runApp
│   ├── app.dart                  # HabitForgeApp: GetMaterialApp, theme, routes
│   ├── core/
│   │   ├── common/               # frame-sequence animation player
│   │   ├── constants/            # app / env / game constants
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
├── env/                          # hive.json / firebase.json / server.json (--dart-define-from-file)
├── tool/
│   └── generate_assets.dart      # regenerates lib/generated/assets.dart
├── thirdpart/                    # vendored packages (svgaplayer_flutter)
├── docs/
│   └── firebase-setup.md
├── build_habit_android.sh        # Android release build helper
└── pubspec.yaml
```

## Internationalization

The app supports **English** and **中文** (Simplified Chinese), following the tata-project pattern (enum keys):

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

- Monorepo root — [../README.md](../README.md)
- Backend (`server/`), shared contracts (`proto/`), product & design docs (`docs/`)
