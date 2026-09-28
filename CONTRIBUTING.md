# Contributing to HabitForge

Thanks for your interest in contributing! This project is a Flutter mobile app repository, and contributions are welcome in code, docs, design, and testing.

## Getting Started

1. Fork the repository.
2. Clone your fork.
3. Create a feature branch:

```bash
git checkout -b feat/your-feature
```

4. Make your changes.
5. Run relevant checks:

```bash
make test
```

6. Commit and push.
7. Open a pull request.

## Project Structure

- `app/` — Flutter client
- `proto/` — data contracts (protobuf source for the generated Dart models)
- `docs/` — product and architecture docs
- `legal/` — privacy policy and terms of service

## Code Style

- Flutter: follow `analysis_options.yaml`, run `flutter analyze`.
- Keep PRs focused and descriptive.
- Add tests for new logic when practical.

## Reporting Issues

Please include:

- Environment (OS, Flutter version)
- Steps to reproduce
- Expected vs actual behavior
- Logs or screenshots if available

## Security Notes

- **Never commit** secrets or project-private configs. Root `.gitignore` already covers:
  - `android/key.properties`, `*.jks` / `*.keystore`
  - `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`
  - `app/env/firebase.json` (use `app/env/firebase.json.example`)
  - `.env*`, service-account JSON, Apple signing certs
- Commit only `*.example` templates; keep real values local.
- If you suspect a leaked secret, report it privately before opening an issue.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
