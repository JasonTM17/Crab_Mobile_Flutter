# Contributing to Crab Super App

Thanks for your interest in contributing. This document outlines the process for getting changes into the Crab Super App monorepo.

## Getting Started

1. **Fork** the repository on GitHub: [JasonTM17/Crab_Mobile_Flutter](https://github.com/JasonTM17/Crab_Mobile_Flutter)
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/<your-username>/Crab_Mobile_Flutter.git
   cd Crab_Mobile_Flutter
   ```
3. **Add upstream** remote so you can keep your fork in sync:
   ```bash
   git remote add upstream https://github.com/JasonTM17/Crab_Mobile_Flutter.git
   ```
4. **Create a branch** off `main` for your work (see [Branch Naming](#branch-naming)).

## Development Setup

### Prerequisites

- **Node.js** 20+ (LTS recommended)
- **pnpm** 9+ (`npm install -g pnpm`)
- **Flutter** 3.x stable channel (for the mobile app)
- **Docker** 24+ and **Docker Compose** v2
- **Git** 2.40+

Optional but recommended:
- VS Code with the Dart, Flutter, ESLint, and Prettier extensions
- A local Postgres / MongoDB / Redis client for inspecting state

### Bootstrap

```bash
pnpm install
```

This installs all backend service and web-admin dependencies via the workspace.

### Running the Stack

Two supported workflows:

**Local processes (faster iteration):**
```bash
pnpm dev
```
Starts every backend service in watch mode plus the web admin. Requires the data layer (Postgres, MongoDB, Redis, MinIO) running separately, e.g.:
```bash
docker compose -f docker-compose.dev.yml up -d postgres mongo redis minio
```

**Full container stack:**
```bash
docker compose -f docker-compose.dev.yml up --build
```
Brings up every service and the data layer. Slower but matches production wiring.

### Mobile App

```bash
cd mobile
flutter pub get
flutter run
```

## Coding Standards

- **TypeScript / NestJS**: strict mode on, no `any` without justification, `eslint --max-warnings=0` must pass.
- **Dart / Flutter**: `dart format` and `flutter analyze` must pass; follow the BLoC pattern already in place.
- **React / Web Admin**: function components only, hooks for state, TailwindCSS for styling.
- **Database**: migrations only; never edit schema by hand on a shared DB.
- **API contracts**: update the OpenAPI / proto definitions when changing public endpoints, and regenerate clients.
- **Logging**: structured logs only (JSON), never `console.log` in production code paths.

## Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/). Each commit must:

- Use a recognized prefix: `feat(scope)`, `fix(scope)`, `chore`, `docs`, `test`, `refactor`, `infra`, `ci`, `build`, `perf`
- Keep the subject under 72 characters, imperative mood, lowercase after the prefix
- Use the body to explain **why** the change is needed, not what the diff shows

Examples:
```
feat(auth): add OTP cooldown to prevent SMS abuse
fix(ride): correct fare rounding for premium vehicles
infra(k8s): bump gateway HPA max replicas to 20
```

Rules of hygiene:
- One commit = one logical concern. Don't bundle unrelated changes.
- Each commit must build cleanly on its own (no broken intermediate states).
- Stage specific files (`git add path/to/file`) — **never** `git add .` or `git add -A` without inspecting `git status` first.
- No AI-related signatures or co-author trailers.

## Branch Naming

- `feature/<short-desc>` — new features
- `fix/<issue-num>-<desc>` — bug fixes referencing an issue
- `chore/<short-desc>` — tooling, deps, refactors with no behavior change
- `infra/<short-desc>` — infrastructure, Docker, k8s, CI

Examples: `feature/ride-scheduling`, `fix/142-otp-resend-race`, `infra/grafana-dashboards`.

## Pull Request Process

1. **Sync** with upstream `main` before opening the PR:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```
2. **Run checks locally**:
   ```bash
   pnpm lint
   pnpm test
   ```
   For mobile changes also run `flutter analyze` and `flutter test`.
3. **Open the PR** against `main`. Title under 70 characters, conventional-commit style. Body should cover:
   - **Why** the change is needed
   - **What** changed at a high level (the diff shows the details)
   - **How it was tested** (unit, integration, manual steps)
   - **Linked issues**: `Closes #123` or `Refs #123`
   - **Screenshots / GIFs** for any UI change
4. **CI must be green** before review. Don't ask for review on a red PR unless you're explicitly asking for help.
5. **Code review**: at least 1 approval from a maintainer is required. Address review comments by pushing additional commits — don't force-push during review unless asked.
6. **Merge**: maintainers will squash-merge or rebase-merge depending on the change. Keep your branch up to date if asked.

## Testing

- **Unit tests** live next to source files (`*.spec.ts`, `*_test.dart`).
- **Integration tests** for backend services live in `<service>/test/`.
- **E2E** flows for the web admin live in `web-admin/e2e/`.
- New features require tests. Bug fixes require a regression test reproducing the bug.
- Aim for meaningful coverage of business logic, not 100% line coverage of trivial code.

## Reporting Issues

- **Bugs**: open a GitHub issue with reproduction steps, expected vs actual behavior, environment details, and logs.
- **Security issues**: do **not** open a public issue. Follow [SECURITY.md](SECURITY.md).
- **Feature requests**: open an issue describing the use case and the user problem before writing code.

## Working with AI Agents

If you use AI coding agents (Claude, Kilo, Cursor, etc.) on this repo, see [AGENTS.md](AGENTS.md) for the rules those agents must follow — chunked writes, commit hygiene, no AI signatures in commits, and the private-files exclusion list.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE) that covers this project.
