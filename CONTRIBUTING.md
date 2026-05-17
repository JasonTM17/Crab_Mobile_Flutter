# Contributing to Crab

Thank you for your interest in contributing to Crab! This is a learning project and all contributions are welcome.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/Crab_Mobile_Flutter.git`
3. Create a branch: `git checkout -b feature/your-feature`
4. Make your changes
5. Push and create a Pull Request

## Development Setup

### Prerequisites
- Node.js >= 18
- pnpm >= 8
- Flutter SDK >= 3.0
- Docker & Docker Compose

### Backend
```bash
pnpm install
docker-compose up -d postgres mongodb redis  # Start infrastructure
pnpm dev                                      # Start all services
```

### Mobile
```bash
cd apps/mobile
flutter pub get
flutter run
```

### Web Admin
```bash
pnpm --filter @crab/web-admin dev
```

## Code Style

- **Backend:** Follow NestJS conventions, use TypeScript strict mode
- **Mobile:** Follow Flutter/Dart conventions, use BLoC pattern
- **Web:** Follow React + TypeScript conventions with TailwindCSS

## Commit Messages

Use conventional commits:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `refactor:` Code refactoring
- `test:` Adding tests
- `infra:` Infrastructure changes
- `ci:` CI/CD changes

## Reporting Issues

Please include:
- Steps to reproduce
- Expected behavior
- Actual behavior
- Environment details (OS, Flutter version, Node version)

## Contact

Author: Nguyễn Sơn  
Email: jasonbmt06@gmail.com
