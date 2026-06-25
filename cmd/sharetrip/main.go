package main

import (
	"context"

	"github.com/Zhekbland/share_trip/configs"
	"github.com/Zhekbland/share_trip/internal/api"
	"github.com/Zhekbland/share_trip/internal/db"
	"github.com/Zhekbland/share_trip/internal/repository"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/log"
)

func main() {
	ctx := context.Background()

	cfg := db.Config{
		Host:     configs.Env("DB_HOST", "localhost"),
		Port:     configs.EnvInt("DB_PORT", 6543),
		User:     configs.Env("DB_USER", "postgres"),
		Password: configs.Env("DB_PASSWORD", "password"),
		DBName:   configs.Env("DB_NAME", "share_trip"),
		SSLMode:  configs.Env("DB_SSLMODE", "disable"),
	}

	pool, err := db.NewPool(ctx, cfg.DNS())
	if err != nil {
		log.Fatal(err)
	}
	defer pool.Close()

	repo := repository.NewRepoPg(pool)
	server := api.NewServer(repo)

	app := fiber.New()
	server.Route(app.Group("/api"))

	err = app.Listen(":8080")
	if err != nil {
		log.Fatal(err)
	}
}
