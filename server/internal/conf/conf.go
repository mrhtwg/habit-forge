package conf

import (
	"os"
	"time"

	"github.com/google/wire"
)

// Config is the env-based server configuration.
type Config struct {
	Server *Server
	Data   *Data
	JWT    *JWT
}

// Server holds the listen addresses.
type Server struct {
	HTTPAddr string
	GRPCAddr string
}

// Data holds database and cache configuration.
type Data struct {
	Database *Database
	Redis    *Redis
}

// Database is the PostgreSQL DSN.
type Database struct {
	DSN string
}

// Redis cache settings.
type Redis struct {
	Addr     string
	Password string
	DB       int
}

// JWT signing configuration.
type JWT struct {
	Secret     string
	ExpireTime time.Duration
}

// Load reads configuration from environment variables with local defaults.
func Load() *Config {
	return &Config{
		Server: &Server{
			HTTPAddr: getEnv("SERVER_HTTP_ADDR", ":8080"),
			GRPCAddr: getEnv("SERVER_GRPC_ADDR", ":9000"),
		},
		Data: &Data{
			Database: &Database{
				DSN: getEnv("DATABASE_DSN", "host=localhost user=habitforge password=habitforge dbname=habitforge port=5432 sslmode=disable"),
			},
			Redis: &Redis{
				Addr:     getEnv("REDIS_ADDR", "localhost:6379"),
				Password: getEnv("REDIS_PASSWORD", ""),
				DB:       0,
			},
		},
		JWT: &JWT{
			Secret:     getEnv("JWT_SECRET", "change-me-in-production"),
			ExpireTime: 72 * time.Hour,
		},
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

// ProviderSet is the config DI provider.
var ProviderSet = wire.NewSet(Load, ProvideServer, ProvideData, ProvideJWT)

// ProvideServer extracts the server settings.
func ProvideServer(c *Config) *Server { return c.Server }

// ProvideData extracts the data settings.
func ProvideData(c *Config) *Data { return c.Data }

// ProvideJWT extracts the JWT settings.
func ProvideJWT(c *Config) *JWT { return c.JWT }
