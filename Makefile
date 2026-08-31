# HabitForge developer commands

.PHONY: server app test proto clean

## Run the Go backend
server:
	cd server && go run ./cmd/server/

## Run the Flutter app in hive (local) mode
app:
	cd app && flutter run --dart-define-from-file=env/hive.json

## Run backend and Flutter tests
test:
	cd server && go test ./...
	cd app && flutter test

## Generate shared proto contracts (Go → server/api) — requires buf + protoc-gen-go(+http/grpc) on PATH
proto:
	cd proto && buf generate --path api/auth/v1 --path api/user/v1 --path api/character/v1 --path api/task/v1 --path api/shop/v1 --path api/achievement/v1 --path api/stats/v1 --path api/shared/v1

## Clean local build artifacts
clean:
	rm -rf app/build app/.dart_tool server/bin
