# HabitForge · Proto Contract Authoring & Code Generation Guide

> `proto/` is the **single source of truth** for app/server contracts: change the
> `.proto` files and regenerate Go (server) and Dart (app) code.
> Related: `proto/README.md`, `Makefile` (`make proto`), `app/generate_proto.sh`.

---

## 0. Toolchain Installation (hands-on)

Two pipelines need the following tools (installed independently):

| Tool | Purpose | Install |
|---|---|---|
| `buf` | Server code generation (compiles protos, runs plugins) | `go install` |
| `protoc-gen-go` | Go message code | `go install` |
| `protoc-gen-go-grpc` | Go gRPC code | `go install` |
| `protoc-gen-go-http` | Go kratos HTTP route code | `go install` |
| `protoc` | Frontend Dart code generation (compiler) | `brew install protobuf` |
| `protoc-gen-dart` | Dart code plugin | `flutter pub global activate` |

### 0.1 Server side (Go + buf)

```bash
# 1) Install the 4 Go tools
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/go-kratos/kratos/cmd/protoc-gen-go-http/v2@latest
go install github.com/bufbuild/buf/cmd/buf@latest

# 2) Add GOBIN to PATH (otherwise the commands are not found)
export PATH="$PATH:$(go env GOPATH)/bin"

# 3) Verify
buf --version
protoc-gen-go --version
protoc-gen-go-grpc --version
```

> If `proxy.golang.org` is unreachable (e.g. in mainland China), prefix the
> install commands with: `GOPROXY=https://goproxy.cn,direct go install ...`

### 0.2 Frontend side (protoc + Dart plugin)

```bash
# 1) Install protoc (Protocol Buffers compiler)
brew install protobuf
protoc --version          # verify

# 2) Install the protoc-gen-dart plugin (Dart side, from pub.dev)
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
> `The method 'aI' isn't defined for the type 'BuilderInfo'` — see §3.2.

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
| `go_package` | `github.com/habitforge/backend/api/<service>/v1;v1` (required for Go) |
| service/message | `PascalCase` (`AuthService`, `LoginRequest`) |
| Fields | `snake_case`, numbers start at **1** and **must never change** once released |
| enums | First value must be 0 (proto3 rule); `SCREAMING_SNAKE_CASE` naming |
| Comments | English `//` (project rule: comments/TODOs stay English) |

### 1.2 Standard Skeleton (auth example)

```proto
syntax = "proto3";

package api.auth.v1;

import "google/api/annotations.proto";   // HTTP route annotations (from third_party)

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

## 2. Generating Server Code (Go)

### 2.1 Generate

```bash
# from the repository root (recommended)
make proto

# or manually (inside proto/)
cd proto
buf generate --path api/auth/v1 --path api/user/v1 --path api/character/v1 \
  --path api/task/v1 --path api/shop/v1 --path api/achievement/v1 --path api/stats/v1
```

Configuration: `proto/buf.yaml` (modules) and `proto/buf.gen.yaml` (plugins, `out: ../server`).

### 2.2 Output & Wiring

```
server/api/<service>/v1/
├── xxx.pb.go          # messages/enums (protobuf runtime)
├── xxx_http.pb.go     # kratos HTTP route registration (from google.api.http)
└── xxx_grpc.pb.go     # gRPC service registration
```

The empty methods to implement live in `server/internal/service/*.go` (currently
return `501 NOT_IMPLEMENTED`); business logic goes in `server/internal/biz/*.go`.
Services are already registered in `server/internal/server/server.go` — **no
hand-written routes**: edit the proto → regenerate → fill in the biz logic.

Verify: `cd server && go build ./... && go vet ./...`

---

## 3. Generating Frontend (Dart) Code

> This repo's script: **`app/generate_proto.sh`** (simplified for this layout).

### 3.1 Generate

```bash
cd app
./generate_proto.sh              # generate all modules → lib/generated/protos/
./generate_proto.sh --grpc       # also generate the gRPC client (.pbgrpc.dart, add grpc dep)
./generate_proto.sh --clean      # remove the generated directory
```

Core protoc invocation:

```
protoc \
  --proto_path=../proto/api \            # rooted at api/ → output has no api/ prefix
  --proto_path=../proto/third_party \    # google.api annotations compiled only, not generated
  --dart_out[=grpc]:lib/generated/protos \
  ../proto/api/*/v1/*.proto
```

- `--dart_out` (default) generates messages: `xxx.pb.dart` (messages),
  `xxx.pbenum.dart` (enums), `xxx.pbjson.dart` (JSON serialization),
  `xxx.pbserver.dart` (service base class);
- `--dart_out=grpc:` additionally generates `xxx.pbgrpc.dart` (gRPC client, requires `grpc`);
- A **barrel file** `lib/generated/protos/<svc>/v1/<svc>.dart` is generated per
  module for simpler imports.

### 3.2 Wiring into the app

**pubspec.yaml dependencies** (add before first generation):

```yaml
dependencies:
  protobuf: ^5.0.0        # must match protoc_plugin 24.x + grpc (see §0.2)
  fixnum: ^1.0.0
  # grpc: ^4.0.0          # only when using --grpc
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

// Build / read messages
final task = Task()
  ..id = 'abc'
  ..title = 'Morning exercise'
  ..difficulty = TaskDifficulty.taskDifficultyMedium;

// REST mode: serialize with pbjson to talk to ServerAuthService / the backend
import 'package:habit_forge_app/generated/protos/task/v1/task.pbjson.dart';
final json = taskToJson(task);            // → Map<String, dynamic>
final task2 = Task.fromJson(json);
```

> The app currently talks to the backend over **REST + JSON**
> (`ServerAuthService` posts JSON directly), so generating messages only is
> enough. When switching to gRPC, regenerate with `--grpc` and add the `grpc`
> dependency; client code swaps in structurally.

### 3.3 Alternative: generate Go + Dart in one `buf generate`

Append a Dart plugin to `proto/buf.gen.yaml` and `buf generate` produces both
sides at once:

```yaml
plugins:
  - local: protoc-gen-go
    out: ../server
    opt: [paths=source_relative]
  # ...(go-http / go-grpc)
  - local: protoc-gen-dart
    out: ../app/lib/generated/protos
```

---

## 4. Changing an Interface (full workflow)

```
1. Edit proto/api/<service>/v1/<service>.proto      # add fields / RPCs / route annotations
2. make proto                                        # regenerate the server Go code
3. cd app && ./generate_proto.sh                     # regenerate the frontend Dart code
4. Fill in server/internal/biz/*.go business logic   # for new interfaces
5. Wire the new interface on the frontend with the generated pb messages / JSON
```
