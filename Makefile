# HabitForge developer commands

.PHONY: app analyze test proto clean legal-check legal-sync

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

## Fail if the hosted legal pages and the copies bundled in the app have drifted
legal-check:
	@diff -q legal/privacy-policy.html app/assets/legal/privacy-policy.html
	@diff -q legal/terms-of-service.html app/assets/legal/terms-of-service.html
	@echo "legal pages in sync (hosted == bundled)"

## Copy the hosted legal pages over the bundled in-app copies (run after editing legal/)
legal-sync:
	cp legal/privacy-policy.html app/assets/legal/privacy-policy.html
	cp legal/terms-of-service.html app/assets/legal/terms-of-service.html
	@echo "copied legal/ -> app/assets/legal/"
