# HabitForge Server

Go backend for HabitForge, built on the **go-kratos** framework.

- HTTP framework: [go-kratos](https://github.com/go-kratos/kratos) v2 (HTTP + gRPC dual transport)
- ORM: GORM (PostgreSQL)
- DI: Wire
- API contract: protobuf (proto-first, `google.api.http` annotations)

> **Status:** framework skeleton. All route interfaces are defined and the server
> compiles, runs and enforces JWT auth — but every business method is left empty
> and returns `501 NOT_IMPLEMENTED`. Implement the `internal/biz` use cases to
> fill them in.

## Quick Start

```bash
# From repository root (PostgreSQL, optional for the skeleton)
docker compose up -d

# From this directory
go run ./cmd/server/
```

- HTTP listens on `http://localhost:8080`
- gRPC listens on `:9000`
- `GET /health` → `{"status":"ok"}`

## API Routes

All routes are declared in `api/<service>/v1/*.proto` and generated into Go code.
`Auth` column: whether the JWT middleware protects the route.

| Method | Path | Auth | Service method |
|---|---|---|---|
| GET | `/health` | No | — |
| POST | `/api/v1/auth/register` | No | AuthService.Register (no email verification) |
| POST | `/api/v1/auth/login` | No | AuthService.Login |
| POST | `/api/v1/auth/oauth` | No | AuthService.OAuthLogin (google/apple) |
| GET | `/api/v1/auth/me` | Yes | AuthService.Me |
| GET | `/api/v1/user/prefs` | Yes | UserService.GetPrefs |
| PUT | `/api/v1/user/prefs` | Yes | UserService.UpdatePrefs |
| GET | `/api/v1/character` | Yes | CharacterService.GetCharacter |
| PUT | `/api/v1/character` | Yes | CharacterService.UpdateCharacter |
| POST | `/api/v1/character/stats/allocate` | Yes | CharacterService.AllocateStatPoint |
| POST | `/api/v1/character/revive` | Yes | CharacterService.Revive |
| GET | `/api/v1/tasks` | Yes | TaskService.ListTasks |
| GET | `/api/v1/tasks/{id}` | Yes | TaskService.GetTask |
| POST | `/api/v1/tasks` | Yes | TaskService.CreateTask |
| PUT | `/api/v1/tasks/{id}` | Yes | TaskService.UpdateTask |
| DELETE | `/api/v1/tasks/{id}` | Yes | TaskService.DeleteTask |
| POST | `/api/v1/tasks/{id}/complete` | Yes | TaskService.CompleteTask |
| GET | `/api/v1/shop/items` | Yes | ShopService.ListShopItems |
| GET | `/api/v1/shop/daily-deal` | Yes | ShopService.GetDailyDeal |
| POST | `/api/v1/shop/items/{item_id}/buy` | Yes | ShopService.BuyItem |
| GET | `/api/v1/shop/owned` | Yes | ShopService.ListOwnedItems |
| GET | `/api/v1/achievements` | Yes | AchievementService.ListAchievements |
| POST | `/api/v1/achievements/{id}/unlock` | Yes | AchievementService.Unlock |
| GET | `/api/v1/stats` | Yes | StatsService.GetStats |

gRPC services mirror the HTTP API (`api.auth.v1.AuthService`, `api.task.v1.TaskService`, …) on `:9000`.

## Project Structure

```text
server/
├── api/                       # proto contracts + generated Go code
│   ├── auth/v1/               # register / login / oauth / me
│   ├── user/v1/               # preferences & wallet
│   ├── character/v1/          # class / level / EXP / HP / stats / equipment
│   ├── task/v1/               # habit / daily / todo CRUD + complete rewards
│   ├── shop/v1/               # items / daily deal / buy / owned
│   ├── achievement/v1/        # list / unlock (gem rewards)
│   └── stats/v1/              # completion charts & streak leaderboard
├── cmd/server/                # entrypoint + Wire (wire.go / wire_gen.go)
├── configs/config.yaml        # configuration reference (env-based)
├── third_party/google/api/    # minimal google.api.http annotations for codegen
├── internal/
│   ├── conf/                  # env-based configuration
│   ├── data/                  # data layer (PostgreSQL handle, TODO repositories)
│   ├── biz/                   # business use cases — empty, returns not implemented
│   ├── service/               # kratos service implementations — empty, returns 501
│   ├── middleware/            # JWT auth middleware
│   ├── model/                 # GORM models (user, character, task, shop, achievement)
│   └── server/                # kratos HTTP + gRPC server assembly
├── buf.yaml                   # buf module config (api + third_party)
├── buf.gen.yaml               # codegen plugin config
├── go.mod / go.sum
└── README.md
```

## Regenerating the proto code

Install the toolchain once:

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/go-kratos/kratos/cmd/protoc-gen-go-http/v2@latest
go install github.com/bufbuild/buf/cmd/buf@latest
```

Then regenerate (also available as `make proto` from the repository root):

```bash
export PATH="$PATH:$(go env GOPATH)/bin"
buf generate --path api/auth/v1 --path api/user/v1 --path api/character/v1 --path api/task/v1 --path api/shop/v1 --path api/achievement/v1 --path api/stats/v1
```

> If `proxy.golang.org` is unreachable (e.g. in mainland China), use a mirror:
> `GOPROXY=https://goproxy.cn,direct go install ...`

## Configuration

| Variable | Default | Description |
|---|---|---|
| `SERVER_HTTP_ADDR` | `:8080` | HTTP listen address |
| `SERVER_GRPC_ADDR` | `:9000` | gRPC listen address |
| `DATABASE_DSN` | local `habitforge` DSN | PostgreSQL DSN |
| `REDIS_ADDR` / `REDIS_PASSWORD` | `localhost:6379` / empty | Redis settings |
| `JWT_SECRET` | `change-me-in-production` | JWT signing key (72h expiry) |

> Local development defaults only — set real values via environment variables in production.
