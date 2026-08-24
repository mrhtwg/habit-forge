package main

import (
	"fmt"
	"log"
	"os"

	"github.com/habitforge/backend/config"
	"github.com/habitforge/backend/internal/model"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func main() {
	cfg := config.Load()

	// Database
	db, err := gorm.Open(postgres.Open(cfg.Database.DSN), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatalf("failed to connect database: %v", err)
	}

	// Auto migrate all models
	if err := db.AutoMigrate(
		&model.User{},
		&model.AuthProvider{},
		&model.Character{},
		&model.Task{},
		&model.OwnedItem{},
		&model.Achievement{},
	); err != nil {
		log.Fatalf("failed to migrate: %v", err)
	}

	// Wire DI
	router := InitializeApp(db, cfg)

	addr := fmt.Sprintf(":%s", cfg.Server.Port)
	log.Printf("server starting on %s", addr)
	if err := router.Engine.Run(addr); err != nil {
		log.Fatalf("server failed: %v", err)
		os.Exit(1)
	}
}
