# HabitForge · Proto Contract Authoring & Dart Code Generation Guide

> `proto/` is the **single source of truth** for the app's data contracts: edit the
> `.proto` files and regenerate the Dart models consumed by `app/`.
> Related: `proto/README.md`, `Makefile` (`make proto`), `app/generate_proto.sh`.
>
> **Scope:** the MVP has **no server**. Earlier revisions of this guide also covered
> a Go + kratos pipeline (`buf` → `server/api/**/*.pb.go`); that module is not part
> of this repository. The `go_package` options and `google.api.http` annotations are
> kept in the protos so a backend can be reintroduced later, but nothing in this
> repository consumes them today.

---

## 0. Toolchain Installation

### 0.1 Dart side (protoc + Dart plugin)

```bash
# 1) Install protoc (Protocol Buffers compiler)
brew install protobuf
protoc --version          # verify

# 2) Install the protoc-gen-dart plugin (from pub.dev)
flutter pub global activate protoc_plugin

# 3) Add the pub global bin to PATH
export PATH="$PATH:$HOME/.pub-cache/bin"

# 4) Verify
protoc-gen-dart --version
```

> **Version compatibility (important)**: the Dart `grpc` package requires
> `protobuf` **< 6**, so this repo pairs **protoc_plugin 24.x + protobuf ^5.0.0**.
> Install the plugin pinned: `flutter pub global activate protoc_plugin 24.0.0`.
> A mismatched pair (e.g. plugin 25 + protobuf ^5) fails with errors like
> `The method 'aI' isn't defined for the type 'BuilderInfo'`.

---

## 1. How to Write Proto Files

### 1.1 Directory & Naming Conventions

```
proto/
├── api/
│   └── <service>/v1/<service>.proto     # module / major version / file
└── third_party/google/api/              # google.api.http annotations (do not edit)
```

| Rule | Convention |
|---|---|
| File path | `api/<service>/v1/<service>.proto` (lowercase snake_case) |
| `syntax` | `syntax = "proto3";` |
| `package` | `api.<service>.v1` (e.g. `api.auth.v1`) |
| `go_package` | `github.com/habitforge/backend/api/<service>/v1;v1` — retained for a future backend; ignored by the Dart-only pipeline |
| service/message | `PascalCase` (`AuthService`, `LoginRequest`) |
| Fields | `snake_case`, numbers start at **1** and **must never change** once released |
| enums | First value must be 0 (proto3 rule); `SCREAMING_SNAKE_CASE` naming |
| Comments | English `//` (project rule: comments/TODOs stay English) |

### 1.2 Standard Skeleton (auth example)

```proto
syntax = "proto3";

package api.auth.v1;

import "google/api/annotations.proto";   // HTTP route annotations (from third_party)

// Kept so a future backend can generate Go from the same file.
option go_package = "github.com/habitforge/backend/api/auth/v1;v1";

// AuthService handles authentication.
service AuthService {
  // Login authenticates with email and password.
  rpc Login(LoginRequest) returns (LoginReply) {
    option (google.api.http) = {
      post: "/api/v1/auth/login"
      body: "*"
    };
  }
}

message LoginRequest {
  string email = 1;
  string password = 2;
}

message LoginReply {
  string token = 1;
  UserInfo user = 2;
}
```

### 1.3 HTTP Route Annotation Rules (`google.api.http`)

> These annotations describe REST routes for a future self-hosted backend. The
> Dart pipeline compiles `third_party/` but generates nothing from them, so they
> are inert today — keep them accurate if a backend is reintroduced.

| Rule | Description |
|---|---|
| One RPC ↔ one HTTP route | `get/post/put/delete/patch` + path |
| Path version prefix | `/api/v1/<resource>` |
| Path parameters | `{field}` placeholders bind to request fields (e.g. `/api/v1/tasks/{id}`) |
| Request body | `body: "*"` (whole message as JSON body); GET/DELETE omit body |
| Plural resource = list | `GET /api/v1/tasks` = list, `GET /api/v1/tasks/{id}` = single |

### 1.4 Field Type Conventions (aligned with the app)

| Scenario | Type | Notes |
|---|---|---|
| Time | `int64` (unix **millis**) | Avoid `google.protobuf.Timestamp` (extra dependency) |
| Key-value | `map<string, string>` | e.g. character `equipment` (slot → itemId) |
| Lists | `repeated` | e.g. `tags`, `repeat_days` |
| State/category | `enum` | e.g. `TaskType`, `TaskDifficulty` |
| Amounts/counts | `int64` | gold, EXP, etc. |

### 1.5 Breaking Changes & Versioning

- **Never touch released fields**: renumbering, changing types, or deleting
  fields breaks older clients.
- Breaking changes → create `api/<service>/v2/`; keep the old v1.
- Adding fields/RPCs is non-breaking — append to the current version (new
  fields must have defaults that are safe for older clients).

---

## 2. Generating Dart Code

> This repo's script: **`app/generate_proto.sh`**.

### 2.1 Generate

```bash
cd app
./generate_proto.sh              # generate all modules → lib/generated/protos/
./generate_proto.sh --grpc       # also generate the gRPC client (.pbgrpc.dart, needs the grpc dep)
./generate_proto.sh --clean      # remove the generated directory
```

Core protoc invocation:

```
protoc \
  --proto_path=../proto \                # module root so api/... imports resolve
  --proto_path=../proto/third_party \    # google.api annotations compiled only, not generated
  --dart_out[=grpc]:lib/generated/protos \
  ../proto/api/*/v1/*.proto
# then flatten api/<svc>/v1 → <svc>/v1 (the script does this automatically)
```

- `--dart_out` (default) generates messages: `xxx.pb.dart` (messages),
  `xxx.pbenum.dart` (enums), `xxx.pbjson.dart` (JSON serialization),
  `xxx.pbserver.dart` (service base class);
- `--dart_out=grpc:` additionally generates `xxx.pbgrpc.dart` (gRPC client, requires `grpc`);
- A **barrel file** `lib/generated/protos/<svc>/v1/<svc>.dart` is generated per
  module for simpler imports.

### 2.2 Wiring into the app

**pubspec.yaml dependencies** (needed by the generated code):

```yaml
dependencies:
  protobuf: ^5.0.0        # must match protoc_plugin 24.x (see §0.1)
  fixnum: ^1.0.0
  grpc: ^4.0.0            # only required when generating --grpc stubs
```

**analysis_options.yaml** (already configured — excludes generated code from linting):

```yaml
analyzer:
  exclude:
    - lib/generated/protos/**
```

**Import & usage**:

```dart
// Import via the barrel file
import 'package:habit_forge_app/generated/protos/task/v1/task.dart';

// Build / read messages — these types are the app's data model in every mode
final task = Task()
  ..id = 'abc'
  ..title = 'Morning exercise'
  ..difficulty = TaskDifficulty.taskDifficultyMedium;
```

The generated messages are used by the Hive and Firebase storage implementations
alike (`app/lib/core/network/`); they are not tied to any transport.

---

## 3. Changing a Contract (full workflow)

```
1. Edit proto/api/<service>/v1/<service>.proto      # add fields / RPCs
2. cd app && ./generate_proto.sh                    # regenerate the Dart models
3. Update app/lib/core/network/**                   # Hive + Firebase storage / mapping
4. Run `make analyze` and `make test`
```
