package main

import (
	"os"

	"github.com/go-kratos/kratos/v2"
	"github.com/go-kratos/kratos/v2/log"
	"github.com/go-kratos/kratos/v2/transport/grpc"
	"github.com/go-kratos/kratos/v2/transport/http"

	"github.com/habitforge/backend/internal/conf"
)

func main() {
	cfg := conf.Load()

	logger := log.NewStdLogger(os.Stdout)
	helper := log.NewHelper(logger)

	app, cleanup, err := wireApp(cfg, logger)
	if err != nil {
		helper.Fatal(err)
	}
	defer cleanup()

	if err := app.Run(); err != nil {
		helper.Fatal(err)
	}
}

// newApp assembles the kratos application with all transports.
func newApp(logger log.Logger, hs *http.Server, gs *grpc.Server) *kratos.App {
	return kratos.New(
		kratos.Name("habitforge"),
		kratos.Version("v0.0.1"),
		kratos.Logger(logger),
		kratos.Server(hs, gs),
	)
}
