# HabitForge

**RPG-style habit tracker built with Flutter + Go.**

HabitForge is a mobile-first habit tracker that turns your real-life tasks into an RPG character growth loop. Complete tasks, earn EXP and gold, level up your character, and unlock cosmetic items in the Forge.

This repository is a **full-stack monorepo**:

- `app/` — Flutter client (GetX, Hive, Firebase Auth)
- `server/` — Go backend (go-kratos, GORM, PostgreSQL, Wire DI)
- `proto/` — shared API contract directory (planned evolution)
- `docs/` — product, design, and development docs

> **Status:** MVP. The Flutter app is local-first and playable; the Go backend is a go-kratos skeleton with all route interfaces defined (auth, user, character, task, shop, achievement, stats) — implementations are pending. See [Roadmap](docs/roadmap.md).

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
| Backend | Go, go-kratos, GORM, PostgreSQL, Wire |
| Shared contract | proto (planned) |
| Infra | Docker Compose |

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
├── server/               # Go backend
│   ├── api/              # proto contracts + generated code (auth/user/character/task/shop/achievement/stats)
│   ├── cmd/              # entrypoint + Wire
│   ├── configs/          # config reference
│   └── internal/         # conf / data / biz / service / server / middleware / model
├── proto/                # shared API contracts (planned)
├── docs/                 # PRD, design docs, architecture
├── docker-compose.yml    # PostgreSQL for local development
└── Makefile              # common developer commands
```

## Quick Start

### 1. Start the backend dependencies

```bash
docker compose up -d
```

### 2. Run the Go backend

```bash
cd server
go mod download
go run ./cmd/server/
```

The server listens on `http://localhost:8080`.

### 3. Run the Flutter app

```bash
cd app
flutter pub get
flutter run --dart-define-from-file=env/hive.json
```

> The app supports three data-storage modes, selected via the `env/` config file: **hive** (local on-device, default, no backend needed), **firebase** (Firebase storage + auth), and **server** (self-hosted backend). See the [app README](app/README.md) for details.

For Firebase mode, see [Firebase setup](app/docs/firebase-setup.md); for the self-hosted backend, see the [Backend API](#backend-api) section.

## Backend API

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/health` | No | Health check |
| POST | `/api/v1/auth/register` | No | Email register |
| POST | `/api/v1/auth/login` | No | Email login |
| POST | `/api/v1/auth/oauth` | No | Google/Apple login |
| GET | `/api/v1/me` | Yes | Current user |

## Development

Common commands:

```bash
make server        # run Go backend
make app           # run Flutter app in test mode
make test          # run backend and Flutter tests
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## Roadmap

- [x] Flutter MVP core loop: tasks, character, forge, achievements
- [x] Go auth backend
- [ ] Move core game logic to the Go backend
- [ ] Introduce Kratos + gRPC + shared proto contracts
- [ ] Cloud sync and multi-device support
- [ ] Vue/React admin dashboard
- [ ] iOS release

See [docs/roadmap.md](docs/roadmap.md).

## License

[MIT](LICENSE)

## Acknowledgements

- Inspired by Habitica, but implemented independently with a modern native/local-first approach.
- Third-party components retain their own licenses; see `app/thirdpart/` and asset notices.
