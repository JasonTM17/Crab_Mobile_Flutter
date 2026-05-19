.PHONY: dev build test lint clean docker-up docker-down db-migrate db-seed help

# Colors
GREEN  := \033[0;32m
YELLOW := \033[0;33m
CYAN   := \033[0;36m
RESET  := \033[0m

help: ## Show this help
	@echo "$(CYAN)Crab Super App$(RESET) - Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'

# Development
dev: ## Start all services in development mode
	pnpm dev

build: ## Build all services
	pnpm build

lint: ## Run linter on all services
	pnpm lint

lint-fix: ## Run linter with auto-fix
	pnpm lint:fix

format: ## Format all files with Prettier
	pnpm format

format-check: ## Check formatting without modifying
	pnpm format:check

# Testing
test: ## Run unit tests
	pnpm test

test-watch: ## Run tests in watch mode
	pnpm test:watch

test-cov: ## Run tests with coverage report
	pnpm test:cov

test-e2e: ## Run end-to-end tests
	pnpm test:e2e

test-load: ## Run full load test suite (requires k6)
	pnpm test:load

test-load-rate: ## Run rate limiting load test
	pnpm test:load:rate

test-load-ride: ## Run ride service load test
	pnpm test:load:ride

# Database
db-migrate: ## Run database migrations
	pnpm db:migrate

db-seed: ## Seed database with demo data
	pnpm db:seed

db-reset: ## Reset database (WARNING: destroys all data)
	pnpm db:reset

# Docker
docker-up: ## Start all services with Docker
	docker compose up -d

docker-down: ## Stop all Docker services
	docker compose down

docker-build: ## Build all Docker images
	docker compose build

docker-logs: ## Follow Docker logs
	docker compose logs -f

docker-ps: ## Show running containers
	docker compose ps

docker-restart: ## Restart all services
	docker compose restart

docker-clean: ## Remove all containers, volumes, and images
	docker compose down -v --rmi all

# Monitoring
monitoring-up: ## Start monitoring stack (Prometheus + Grafana)
	pnpm monitoring:up

monitoring-down: ## Stop monitoring stack
	pnpm monitoring:down

# Kubernetes
k8s-deploy: ## Deploy to Kubernetes
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/services/
	kubectl apply -f k8s/ingress.yaml

k8s-status: ## Check Kubernetes deployment status
	kubectl get pods -n crab
	kubectl get svc -n crab
	kubectl get hpa -n crab

k8s-logs: ## Follow logs for all pods
	kubectl logs -f -l tier=backend -n crab --max-log-requests=10

k8s-delete: ## Delete Kubernetes deployment
	kubectl delete -f k8s/ingress.yaml
	kubectl delete -f k8s/services/
	kubectl delete -f k8s/namespace.yaml

# Utilities
clean: ## Clean build artifacts
	pnpm clean
	Find . -name 'dist' -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name 'coverage' -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name '.turbo' -type d -exec rm -rf {} + 2>/dev/null || true

health: ## Check health of all services
	@echo "$(CYAN)Checking service health...$(RESET)"
	@for port in 3000 3001 3002 3003 3004 3005 3006 3007 3008; do \
		status=$$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$$port/health 2>/dev/null); \
		if [ "$$status" = "200" ]; then \
			echo "  $(GREEN)Port $$port: OK$(RESET)"; \
		else \
			echo "  $(YELLOW)Port $$port: DOWN ($$status)$(RESET)"; \
		fi \
	done

setup: ## Initial project setup
	@echo "$(CYAN)Setting up Crab Super App...$(RESET)"
	cp -n .env.example .env 2>/dev/null || true
	pnpm install
	docker compose up -d postgres mongodb redis
	@echo "Waiting for databases..."
	sleep 5
	pnpm db:migrate
	pnpm db:seed
	@echo "$(GREEN)Setup complete!$(RESET)"
	@echo "Run 'make dev' to start development"
