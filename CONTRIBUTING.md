# Contributing to HabitForge

Thanks for your interest in contributing! This project is a full-stack Flutter + Go monorepo, and contributions are welcome in code, docs, design, and testing.

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
- `server/` — Go backend
- `proto/` — shared API contracts (planned)
- `docs/` — product and architecture docs

## Code Style

- Flutter: follow `analysis_options.yaml`, run `flutter analyze`.
- Go: run `go fmt` and `go vet`.
- Keep PRs focused and descriptive.
- Add tests for new logic when practical.

## Reporting Issues

Please include:

- Environment (OS, Flutter/Go versions)
- Steps to reproduce
- Expected vs actual behavior
- Logs or screenshots if available

## Security Notes

- **Never commit** Firebase config files, keystores, `key.properties`, or environment secrets.
- Use placeholder configs or `.example` files for public templates.
- If you suspect a leaked secret, report it privately before opening an issue.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
