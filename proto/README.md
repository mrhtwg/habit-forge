# Shared Proto Contracts

Single source of truth for the HabitForge API contracts, shared by the Flutter
client (`app/`) and the Go backend (`server/`). Each consumer generates its own
language code from these protos.

## Layout

```text
proto/
├── buf.yaml / buf.gen.yaml   # buf module + codegen config
├── api/
│   ├── auth/                 # register / login / oauth / me
│   ├── user/                 # preferences & wallet
│   ├── character/            # class / level / EXP / HP / stats / equipment
│   ├── task/                 # habit / daily / todo CRUD + complete rewards
│   ├── shop/                 # items / daily deal / buy / owned
│   ├── achievement/          # list / unlock (gem rewards)
│   └── stats/                # completion charts & streak leaderboard
└── third_party/google/api/   # minimal google.api.http annotations
```

## Generating code

- **Go (server)** — protos → `server/api/<service>/v1/*.pb.go` (HTTP + gRPC):

  ```bash
  # from the repository root
  make proto

  # or manually
  cd proto
  buf generate --path api/auth/v1 --path api/user/v1 --path api/character/v1 \
    --path api/task/v1 --path api/shop/v1 --path api/achievement/v1 --path api/stats/v1
  ```

- **Dart (app)** — protos → `app/lib/generated/protos/<service>/v1/*.dart`:

  ```bash
  cd app
  ./generate_proto.sh              # messages only (REST mode); --grpc for gRPC client
  ```

  (`protoc` + `protoc-gen-dart` + barrel files). Full guide: `docs/proto-guide.md`.

## Toolchain

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/go-kratos/kratos/cmd/protoc-gen-go-http/v2@latest
go install github.com/bufbuild/buf/cmd/buf@latest
export PATH="$PATH:$(go env GOPATH)/bin"
```

> If `proxy.golang.org` is unreachable (e.g. in mainland China), use a mirror:
> `GOPROXY=https://goproxy.cn,direct go install ...`
