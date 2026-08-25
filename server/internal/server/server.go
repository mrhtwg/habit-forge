package server

import (
	"net/http"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/go-kratos/kratos/v2/middleware/recovery"
	"github.com/go-kratos/kratos/v2/transport/grpc"
	khttp "github.com/go-kratos/kratos/v2/transport/http"
	"github.com/google/wire"

	achievementv1 "github.com/habitforge/backend/api/achievement/v1"
	authv1 "github.com/habitforge/backend/api/auth/v1"
	characterv1 "github.com/habitforge/backend/api/character/v1"
	shopv1 "github.com/habitforge/backend/api/shop/v1"
	statsv1 "github.com/habitforge/backend/api/stats/v1"
	taskv1 "github.com/habitforge/backend/api/task/v1"
	userv1 "github.com/habitforge/backend/api/user/v1"
	"github.com/habitforge/backend/internal/conf"
	"github.com/habitforge/backend/internal/middleware"
	"github.com/habitforge/backend/internal/service"
)

// NewHTTPServer builds the kratos HTTP server with all services registered.
// The JWT middleware protects every route except the public prefixes
// (/health and the auth entry points).
func NewHTTPServer(cfg *conf.Server, jwtCfg *conf.JWT, logger log.Logger,
	auth *service.AuthService,
	user *service.UserService,
	character *service.CharacterService,
	task *service.TaskService,
	shop *service.ShopService,
	achievement *service.AchievementService,
	stats *service.StatsService,
) *khttp.Server {
	var opts = []khttp.ServerOption{
		khttp.Middleware(
			recovery.Recovery(),
			middleware.JWT(jwtCfg,
				"/health",
				"/api/v1/auth/register",
				"/api/v1/auth/login",
				"/api/v1/auth/oauth",
			),
		),
		khttp.Address(cfg.HTTPAddr),
	}
	srv := khttp.NewServer(opts...)

	// Health check (public).
	srv.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"status":"ok"}`))
	})

	// Register all service routes.
	authv1.RegisterAuthServiceHTTPServer(srv, auth)
	userv1.RegisterUserServiceHTTPServer(srv, user)
	characterv1.RegisterCharacterServiceHTTPServer(srv, character)
	taskv1.RegisterTaskServiceHTTPServer(srv, task)
	shopv1.RegisterShopServiceHTTPServer(srv, shop)
	achievementv1.RegisterAchievementServiceHTTPServer(srv, achievement)
	statsv1.RegisterStatsServiceHTTPServer(srv, stats)

	return srv
}

// NewGRPCServer builds the kratos gRPC server with all services registered.
// NOTE: the JWT middleware is applied to the HTTP transport only for now;
// gRPC auth will be added together with the implementations.
func NewGRPCServer(cfg *conf.Server, logger log.Logger,
	auth *service.AuthService,
	user *service.UserService,
	character *service.CharacterService,
	task *service.TaskService,
	shop *service.ShopService,
	achievement *service.AchievementService,
	stats *service.StatsService,
) *grpc.Server {
	var opts = []grpc.ServerOption{
		grpc.Middleware(recovery.Recovery()),
		grpc.Address(cfg.GRPCAddr),
	}
	srv := grpc.NewServer(opts...)

	authv1.RegisterAuthServiceServer(srv, auth)
	userv1.RegisterUserServiceServer(srv, user)
	characterv1.RegisterCharacterServiceServer(srv, character)
	taskv1.RegisterTaskServiceServer(srv, task)
	shopv1.RegisterShopServiceServer(srv, shop)
	achievementv1.RegisterAchievementServiceServer(srv, achievement)
	statsv1.RegisterStatsServiceServer(srv, stats)

	return srv
}

// ProviderSet is the server layer DI provider.
var ProviderSet = wire.NewSet(NewHTTPServer, NewGRPCServer)
