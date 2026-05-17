.PHONY: dev build test lint clean docker-up docker-down docker-build

# Development
dev:
	pnpm dev

build:
	pnpm build

test:
	pnpm test

lint:
	pnpm lint

clean:
	pnpm clean

# Docker
docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

docker-build:
	docker-compose build

docker-logs:
	docker-compose logs -f

docker-restart:
	docker-compose down && docker-compose up -d

# Individual services
dev-gateway:
	pnpm --filter @crab/gateway dev

dev-auth:
	pnpm --filter @crab/auth-service dev

dev-web:
	pnpm --filter @crab/web-admin dev

# Database
db-migrate:
	pnpm --filter @crab/auth-service migration:run

db-seed:
	pnpm --filter @crab/auth-service seed:run

# Flutter
flutter-run:
	cd apps/mobile && flutter run

flutter-build:
	cd apps/mobile && flutter build apk

flutter-clean:
	cd apps/mobile && flutter clean && flutter pub get
