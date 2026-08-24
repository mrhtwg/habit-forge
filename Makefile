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

## Generate shared proto contracts (when proto files are added)
proto:
	@echo "No proto files yet. This target will generate Dart/Go code in the future."

## Clean local build artifacts
clean:
	rm -rf app/build app/.dart_tool server/bin
