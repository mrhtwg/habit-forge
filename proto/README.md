# Shared Proto Contracts

This directory is reserved for shared API contracts between the Flutter client
and the Go backend.

## Plan

- Define core domain messages:
  - `auth.proto`
  - `task.proto`
  - `character.proto`
  - `shop.proto`
  - `achievement.proto`
- Generate:
  - Go code for the `server/`
  - Dart code for the `app/`
- Use `buf` or `protoc` to keep generation reproducible.

## Status

**Not yet populated.** The backend currently uses Gin + JSON REST APIs.
Once the backend evolves to Kratos + gRPC, this directory will become the
single source of truth for API contracts.
