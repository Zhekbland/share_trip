.PHONY: deps fmt lint test build run up down migrate-up migrate-down migrate-status check

# Переменные
GO := go
GO_PKG := ./...
BINARY_NAME=sharetrip
DB_URL=postgres://postgres:password@localhost:6543/share_trip?sslmode=disable
MIGRATE_PATH=./migrations

## deps: Установка зависимостей и инструментов
.PHONY: deps
deps:
	# Проверяем lint
	@command -v golangci-lint > /dev/null 2>&1 || { \
		echo "⏳ Установка golangci-lint..."; \
		go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest; \
	}
	# Проверяем goose
	@command -v goose > /dev/null 2>&1 || { \
		echo "⏳ Установка goose..."; \
		go install github.com/pressly/goose/v3/cmd/goose@v3.26.0; \
	}
	@echo "Get fiber..."
	go get github.com/gofiber/fiber/v2
	go get github.com/gofiber/fiber/v2/log
	@echo "Get pgx..."
	go get github.com/jackc/pgx/v5/pgxpool

## fmt: Форматирование кода
.PHONY: fmt
fmt:
	@echo "Format code..."
	go fmt ./...

## lint: Запуск линтера
.PHONY: lint
lint:
	@echo "Run linter..."
	golangci-lint run ./...

# Запуск всех тестов
.PHONY: test
test:
	$(GO) test -v $(GO_PKG)

# Генерация отчёта о покрытии в формате HTML
.PHONY: coverage cover
coverage cover:
	$(GO) test -coverprofile=coverage.out $(GO_PKG)
	$(GO) tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: file://$(shell pwd)/coverage.html"

## build: Сборка бинарного файла
.PHONY: build
build:
	@echo "Build app..."
	go build -o $(BINARY_NAME) ./cmd/sharetrip

## run: Запуск приложения
.PHONY: run
run:
	@echo "Run app..."
	go run ./cmd/sharetrip

## up: Поднять инфраструктуру (PostgreSQL)
.PHONY: up
up:
	@echo "Up PostgreSQL..."
	docker-compose -f deploy/docker-compose.yml up -d postgres
	@sleep 3
	@echo "PostgreSQL is running"

## down: Остановить инфраструктуру
.PHONY: down
down:
	@echo "Stop PostgreSQL..."
	docker-compose -f deploy/docker-compose.yml down

## migrate-up: Применить миграции
.PHONY: migrate-up
migrate-up:
	@echo "Migration accept..."
	goose -dir $(MIGRATE_PATH) postgres "$(DB_URL)" up

## migrate-down: Откатить миграции
.PHONY: migrate-down
migrate-down:
	@echo "Migration rollback..."
	goose -dir $(MIGRATE_PATH) postgres "$(DB_URL)" down 1

## migrate-status: Статус миграций
.PHONY: migrate-status
migrate-status:
	@echo "Migration status..."
	goose -dir $(MIGRATE_PATH) postgres "$(DB_URL)" status

## e2e: End-to-end проверка
.PHONY: e2e
e2e:
	@echo "E2E check..."
	@curl -s http://localhost:8080/api/ready || echo "Error: server not available"

## check: Полная проверка
.PHONY: check
check: deps fmt lint test build
	@echo "OK!"

## help: Show available commands
.PHONY: help
help:
	@echo "ShareTrip Makefile Commands"
	@echo ""
	@echo "============================================================"
	@echo "  DEVELOPMENT"
	@echo "------------------------------------------------------------"
	@echo "  make deps            Install dependencies and tools"
	@echo "  make fmt             Format code"
	@echo "  make lint            Run linter (golangci-lint)"
	@echo "  make test            Run all tests"
	@echo "  make coverage        Generate HTML coverage report"
	@echo "  make check           Full CI check (deps -> fmt -> lint -> test -> build)"
	@echo ""
	@echo "  BUILD & RUN"
	@echo "------------------------------------------------------------"
	@echo "  make build           Build binary"
	@echo "  make run             Run application locally"
	@echo ""
	@echo "  DATABASE"
	@echo "------------------------------------------------------------"
	@echo "  make up              Start PostgreSQL in Docker"
	@echo "  make down            Stop PostgreSQL"
	@echo "  make migrate-up      Apply migrations"
	@echo "  make migrate-down    Rollback last migration"
	@echo "  make migrate-status  Migration status"
	@echo ""
	@echo "  TESTING"
	@echo "------------------------------------------------------------"
	@echo "  make e2e             End-to-end check (/ready)"
	@echo ""
	@echo "============================================================"
	@echo ""
	@echo "Examples:"
	@echo "  make up && make migrate-up && make run    # Full startup"
	@echo "  make check                                 # CI check"
	@echo "  make coverage && open coverage.html        # View coverage report"