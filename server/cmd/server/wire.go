//go:build wireinject
// +build wireinject

package main

import (
	"github.com/google/wire"
	"github.com/habitforge/backend/api"
	"github.com/habitforge/backend/config"
	"github.com/habitforge/backend/internal/handler"
	"github.com/habitforge/backend/internal/repository"
	"github.com/habitforge/backend/internal/service"
	"gorm.io/gorm"
)

func InitializeApp(db *gorm.DB, cfg *config.Config) *api.Router {
	wire.Build(
		provideJWTConfig,
		repository.NewUserRepository,
		service.NewAuthService,
		handler.NewAuthHandler,
		api.NewRouter,
	)
	return nil
}

func provideJWTConfig(cfg *config.Config) config.JWTConfig {
	return cfg.JWT
}
