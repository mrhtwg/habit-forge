package data

import (
	"log"

	"github.com/google/wire"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"

	"github.com/habitforge/backend/internal/conf"
)

// Data wraps the data sources. Repositories will be added here once the
// business logic is implemented.
type Data struct {
	db *gorm.DB
}

// NewData opens the PostgreSQL connection. The connection failure is only
// logged for now — implementations are empty and the skeleton must still boot.
func NewData(cfg *conf.Data) (*Data, func(), error) {
	db, err := gorm.Open(postgres.Open(cfg.Database.DSN), &gorm.Config{})
	if err != nil {
		// TODO(implementation): fail hard once repositories are implemented.
		log.Printf("warning: database connection failed (%v); continuing without db", err)
		db = nil
	}

	d := &Data{db: db}
	cleanup := func() {
		if db != nil {
			if sqlDB, err := db.DB(); err == nil {
				_ = sqlDB.Close()
			}
		}
	}
	return d, cleanup, nil
}

// ProviderSet is the data layer DI provider.
var ProviderSet = wire.NewSet(NewData)
