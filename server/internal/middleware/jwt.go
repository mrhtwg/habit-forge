package middleware

import (
	"context"
	"strings"

	kerrors "github.com/go-kratos/kratos/v2/errors"
	"github.com/go-kratos/kratos/v2/middleware"
	"github.com/go-kratos/kratos/v2/transport"
	"github.com/go-kratos/kratos/v2/transport/http"
	"github.com/golang-jwt/jwt/v5"

	"github.com/habitforge/backend/internal/conf"
)

type ctxKey string

const userIDKey ctxKey = "user_id"

// ErrUnauthorized is returned when the Bearer token is missing or invalid.
var ErrUnauthorized = kerrors.New(401, "UNAUTHORIZED", "unauthorized")

// Public auth operations (HTTP paths and gRPC full method names).
var defaultPublic = []string{
	"/health",
	"/api/v1/auth/register",
	"/api/v1/auth/login",
	"/api/v1/auth/oauth",
	"/api.auth.v1.AuthService/Register",
	"/api.auth.v1.AuthService/Login",
	"/api.auth.v1.AuthService/OAuthLogin",
}

// JWT validates the Authorization Bearer token on protected routes.
// Requests matching publicPrefixes (HTTP paths or gRPC operation names)
// are passed through without a token.
func JWT(cfg *conf.JWT, publicPrefixes ...string) middleware.Middleware {
	if len(publicPrefixes) == 0 {
		publicPrefixes = defaultPublic
	}
	return func(handler middleware.Handler) middleware.Handler {
		return func(ctx context.Context, req interface{}) (interface{}, error) {
			path := operationPath(ctx)
			for _, p := range publicPrefixes {
				if path == p || strings.HasPrefix(path, p) {
					return handler(ctx, req)
				}
			}

			tr, ok := transport.FromServerContext(ctx)
			if !ok {
				return nil, ErrUnauthorized
			}
			tokenStr := strings.TrimPrefix(tr.RequestHeader().Get("Authorization"), "Bearer ")
			if tokenStr == "" {
				return nil, ErrUnauthorized
			}

			claims := &jwt.RegisteredClaims{}
			if _, err := jwt.ParseWithClaims(tokenStr, claims, func(t *jwt.Token) (interface{}, error) {
				return []byte(cfg.Secret), nil
			}); err != nil {
				return nil, ErrUnauthorized
			}

			return handler(context.WithValue(ctx, userIDKey, claims.Subject), req)
		}
	}
}

// operationPath returns the real HTTP request path, falling back to the
// kratos transport operation name (gRPC style) for non-HTTP transports.
func operationPath(ctx context.Context) string {
	if r, ok := http.RequestFromServerContext(ctx); ok {
		return r.URL.Path
	}
	if tr, ok := transport.FromServerContext(ctx); ok {
		return tr.Operation()
	}
	return ""
}

// UserIDFromContext returns the authenticated user id, or "" when absent.
func UserIDFromContext(ctx context.Context) string {
	if v, ok := ctx.Value(userIDKey).(string); ok {
		return v
	}
	return ""
}
