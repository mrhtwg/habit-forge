# Architecture

HabitForge is a full-stack monorepo with a mobile-first client and a Go backend.

## High-Level Overview

```text
+-------------------+       +---------------------+
|   Flutter App     |  HTTP |   Go Backend (Gin)  |
|  (app/)           | <----> |  (server/)          |
|  Hive local data  |       |  PostgreSQL          |
+-------------------+       +---------------------+
        |                            |
        | Firebase Auth (optional)   | GORM
        v                            v
   Firebase / local auth        PostgreSQL
```

## Flutter Client (`app/`)

- State management: GetX
- Local persistence: Hive
- Feature-first layout under `lib/features/`
- Auth: Firebase Auth with guest/test fallback

## Go Backend (`server/`)

- HTTP framework: Gin
- ORM: GORM
- DI: Wire
- Database: PostgreSQL
- Current scope: auth APIs

## Shared Contracts (`proto/`)

The `proto/` directory is reserved for shared API contracts. A future evolution
will introduce Kratos + gRPC and generate Dart/Go models from `.proto` files.

## Why Monorepo

Keeping `app/`, `server/`, `proto/`, and `docs/` in one repository makes the
full-stack project easy to navigate, develop, and review. It also matches the
goal of presenting a complete product as a single open source project.
