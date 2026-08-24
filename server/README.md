# HabitForge Server

Go backend for HabitForge.

- HTTP framework: Gin
- ORM: GORM
- DI: Wire
- Database: PostgreSQL
- Current scope: authentication APIs

## Quick Start

```bash
# From repository root
docker compose up -d

# From this directory
go run ./cmd/server/
```

The server listens on `http://localhost:8080`.

## API

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/health` | No | Health check |
| POST | `/api/v1/auth/register` | No | Email register |
| POST | `/api/v1/auth/login` | No | Email login |
| POST | `/api/v1/auth/oauth` | No | Google/Apple login |
| GET | `/api/v1/me` | Yes | Current user |

## Project Structure

```text
server/
├── api/              # HTTP router
├── cmd/server/       # Entry point + Wire
├── config/           # Env-based config
└── internal/
    ├── handler/      # HTTP handlers
    ├── middleware/   # Auth middleware
    ├── model/        # DB models
    ├── repository/   # Data access layer
    └── service/      # Business logic
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `SERVER_PORT` | `8080` | HTTP listen port |
| `DATABASE_DSN` | local `habitforge` DSN | PostgreSQL DSN |
| `JWT_SECRET` | `change-me-in-production` | JWT signing key |
| `REDIS_ADDR` | `localhost:6379` | Redis address |
| `REDIS_PASSWORD` | empty | Redis password |

> These are local development defaults. Set real values via environment variables in production.
