package api

import (
	"github.com/gin-gonic/gin"
	"github.com/habitforge/backend/internal/handler"
	"github.com/habitforge/backend/internal/middleware"
	"github.com/habitforge/backend/internal/service"
)

// Router wraps the gin engine for Wire injection.
type Router struct {
	Engine *gin.Engine
}

func NewRouter(authHandler *handler.AuthHandler, authService *service.AuthService) *Router {
	r := gin.Default()

	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// Auth routes (no middleware)
	auth := r.Group("/api/v1/auth")
	{
		auth.POST("/register", authHandler.Register)
		auth.POST("/login", authHandler.Login)
		auth.POST("/oauth", authHandler.OAuthLogin)
	}

	// Protected routes
	protected := r.Group("/api/v1")
	protected.Use(middleware.AuthMiddleware(authService))
	{
		protected.GET("/me", authHandler.Me)
		// Future: tasks, character, shop, achievements
	}

	return &Router{Engine: r}
}
