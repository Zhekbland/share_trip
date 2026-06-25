package api

import "github.com/Zhekbland/share_trip/internal/repository"

type Server struct {
	Repository *repository.RepoPg
}

func NewServer(repo *repository.RepoPg) *Server {
	return &Server{Repository: repo}
}
