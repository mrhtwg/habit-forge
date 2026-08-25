//go:build wireinject
// +build wireinject

package main

import (
	"github.com/go-kratos/kratos/v2"
	"github.com/go-kratos/kratos/v2/log"
	"github.com/google/wire"

	"github.com/habitforge/backend/internal/biz"
	"github.com/habitforge/backend/internal/conf"
	"github.com/habitforge/backend/internal/server"
	"github.com/habitforge/backend/internal/service"
)

// wireApp wires the whole application.
func wireApp(cfg *conf.Config, logger log.Logger) (*kratos.App, func(), error) {
	panic(wire.Build(
		conf.ProviderSet,
		biz.ProviderSet,
		service.ProviderSet,
		server.ProviderSet,
		newApp,
	))
}
