# HabitForge

**RPG-style habit tracker built with Flutter.**

HabitForge is a mobile-first habit tracker that turns real-life tasks into an RPG character growth loop. Complete tasks, earn EXP and gold, level up your character, and unlock cosmetic items in the Forge.

This repository holds the **Flutter client**:

- `app/` — Flutter client (GetX, Hive, Firebase Auth + Firestore)
- `proto/` — data contracts (protobuf source for the generated Dart models in `app/lib/generated/protos`)
- `docs/` — product, design, and development docs
- `legal/` — privacy policy and terms of service (deployed to Firebase Hosting)

> **Status:** MVP. The app ships **without any server**: it is playable in **hive** (local on-device, the default) and **firebase** (Firebase Auth + Firestore cloud sync) modes. Both modes run the game rules on the client.

## Why this project exists

HabitForge is not trying to clone Habitica. The goal is a modern, native, and **local-first** RPG habit tracker:

- Native Flutter interactions instead of a web wrapper
- Dark immersive RPG visual style
- No social pressure, guilds, or complex pet systems in the MVP
- Clear architecture that is easy to learn and extend

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter, GetX, Hive, Firebase Auth |
| Cloud (optional) | Firebase Auth + Cloud Firestore |
| Local preferences | shared_preferences |
| Data contracts | proto (protobuf, source for the Dart models in `app/lib/generated/protos`) |

## Repository Layout

```text
habit-forge/
├── app/                  # Flutter client
│   ├── lib/
│   │   ├── core/         # services, constants, routes, theme
│   │   ├── features/     # feature-first modules
│   │   ├── models/       # local data models
│   │   └── widgets/      # shared UI widgets
│   └── test/
├── proto/                # protobuf contracts for the client data models
├── docs/                 # product, design, and development docs
├── legal/                # privacy policy & terms of service
└── Makefile              # common developer commands
```

## Quick Start

```bash
cd app
flutter pub get
flutter run --dart-define-from-file=env/hive.json
```

> The app supports two data modes, selected by the `env/` config file passed through `--dart-define-from-file`: **hive** (local on-device, default — no account or network required) and **firebase** (Firebase Auth + Firestore cloud sync). See the [app README](app/README.md) for details.

For Firebase mode (Google Sign-In + cloud sync), follow the [Firebase setup](app/docs/firebase-setup.md) guide.

## Development

Common commands:

```bash
make app           # run the Flutter app in hive (local) mode
make analyze       # static analysis
make test          # run the Flutter tests
make proto         # regenerate the Dart models from proto/
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## Roadmap

- [x] Flutter MVP core loop: tasks, character, forge, achievements
- [x] Local-first Hive storage
- [x] Firebase Auth + Firestore cloud sync
- [ ] Notifications / daily reminders
- [ ] iOS release
- [ ] Admin dashboard

## License

[MIT](LICENSE)

## Acknowledgements

- Inspired by Habitica, but implemented independently with a modern native/local-first approach.
- Third-party components retain their own licenses; see `app/thirdpart/` and asset notices.
