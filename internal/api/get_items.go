package api

import (
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/log"
)

func (s *Server) Check(c *fiber.Ctx) error {
	err := s.Repository.Ping(c.Context())
	if err != nil {
		log.Errorw("s.Repository.Ping", err)
		return fiber.NewError(fiber.StatusInternalServerError, "internal server error")
	}

	return c.Status(fiber.StatusOK).SendStatus(200)
}
