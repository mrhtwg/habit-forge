# Shared Proto Contracts

Single source of truth for the HabitForge data contracts. The Flutter client
(`app/`) generates its Dart data models from these protos.

> The MVP has **no server**. Earlier revisions of this README described a Go
> backend consuming the same protos; that module is not part of this repository.
> The `go_package` options and `google.api.http` annotations are kept so a
> backend can be reintroduced later.

## Layout

```text
proto/
├── buf.yaml / buf.gen.yaml   # buf module + Go codegen config (unused until a server returns)
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

- **Dart (app)** — protos → `app/lib/generated/protos/<service>/v1/*.dart`:

  ```bash
  # from the repository root
  make proto

  # or directly
  cd app
  ./generate_proto.sh
  ```

  Requires `protoc` + `protoc-gen-dart` and also emits barrel files. Full guide:
  `docs/proto-guide.md`.

## Toolchain

```bash
brew install protobuf
flutter pub global activate protoc_plugin 24.0.0
export PATH="$PATH:$HOME/.pub-cache/bin"
protoc-gen-dart --version
```
