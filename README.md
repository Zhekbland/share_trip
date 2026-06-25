# ShareTrip

ShareTrip — учебный проект для закрепления процессингового мышления при разработке
веб-сервисов на Go. Сервис представляет собой HTTP-приложение с подключением к
PostgreSQL и построен по стандартной для Go структуре с разделением на слои:
точка входа (`cmd/`), внутренняя логика (`internal/`) и конфигурация (`configs/`).

Зависимости и поток управления связываются сверху вниз в `cmd/sharetrip/main.go`:
переменные окружения через `configs` → пул соединений `pgxpool` в `internal/db` →
репозиторий `RepoPg` в `internal/repository` → HTTP-сервер `Server` в `internal/api`.
Маршруты регистрируются в группе `/api`, обработчики возвращают ошибки через Fiber.

## Стек

- **Go 1.25**
- **[Fiber v2](https://github.com/gofiber/fiber)** — HTTP-фреймворк
- **[pgx v5 / pgxpool](https://github.com/jackc/pgx)** — драйвер и пул соединений PostgreSQL
- **[goose](https://github.com/pressly/goose)** — миграции базы данных
- **[golangci-lint](https://github.com/golangci/golangci-lint)** — статический анализ
- **Docker Compose** — запуск PostgreSQL для локальной разработки

## Запуск

Все рабочие сценарии вынесены в `Makefile`. Основные команды:

```bash
make up           # поднять PostgreSQL в Docker
make migrate-up   # применить миграции
make run          # запустить приложение (слушает :8080)
```

Полный старт одной строкой: `make up && make migrate-up && make run`.

Прочие команды: `make build`, `make test`, `make coverage`, `make lint`,
`make fmt`, `make check` (полная CI-проверка). Список всех целей — `make help`.

## Конфигурация

Параметры подключения к БД читаются из переменных окружения со значениями по
умолчанию: `DB_HOST`, `DB_PORT` (6543), `DB_USER`, `DB_PASSWORD`, `DB_NAME`,
`DB_SSLMODE`. Health-check доступен по адресу `GET /api/ready/`.