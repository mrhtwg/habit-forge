# HabitForge developer commands

.PHONY: app analyze test proto clean

## Run the Flutter app in hive (local) mode
app:
	cd app && flutter run --dart-define-from-file=env/hive.json

## Static analysis + typecheck
analyze:
	cd app && flutter analyze

## Run the Flutter tests
test:
	cd app && flutter test

## Regenerate the Dart models from proto/ (requires protoc + protoc-gen-dart)
proto:
	cd app && ./generate_proto.sh

## Clean local build artifacts
clean:
	rm -rf app/build app/.dart_tool
