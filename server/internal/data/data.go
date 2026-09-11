package data

import (
	"context"
	"fmt"

	"github.com/google/wire"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	"github.com/habitforge/backend/internal/conf"
	"github.com/habitforge/backend/internal/game"
	"github.com/habitforge/backend/internal/model"
)

// Data wraps the data sources.
type Data struct {
	db      *gorm.DB
	Catalog *game.Catalog
}

// DB returns the underlying gorm DB.
func (d *Data) DB() *gorm.DB { return d.db }

// NewData opens PostgreSQL, AutoMigrates models, and seeds the catalog when empty.
func NewData(cfg *conf.Data) (*Data, func(), error) {
	db, err := gorm.Open(postgres.Open(cfg.Database.DSN), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Warn),
	})
	if err != nil {
		return nil, nil, fmt.Errorf("database connection failed: %w", err)
	}

	// Prefer SQL migrations (server/migrations/*.sql). AutoMigrate only runs on
	// an empty database so existing constraint names from hand-written SQL
	// (e.g. users_email_key) do not clash with GORM's uni_* names.
	if !db.Migrator().HasTable(&model.User{}) {
		if err := db.AutoMigrate(
			&model.User{},
			&model.AuthProvider{},
			&model.UserPrefs{},
			&model.Character{},
			&model.Task{},
			&model.OwnedItem{},
			&model.UserAchievement{},
			&model.ShopItem{},
			&model.AchievementDef{},
			&model.GameConstant{},
		); err != nil {
			return nil, nil, fmt.Errorf("auto migrate: %w", err)
		}
	}

	cat, err := game.LoadCatalog()
	if err != nil {
		return nil, nil, fmt.Errorf("load catalog: %w", err)
	}
	if err := seedCatalogIfEmpty(db, cat); err != nil {
		return nil, nil, fmt.Errorf("seed catalog: %w", err)
	}
	if err := seedGameConstants(db); err != nil {
		return nil, nil, fmt.Errorf("seed constants: %w", err)
	}

	d := &Data{db: db, Catalog: cat}
	cleanup := func() {
		if sqlDB, err := db.DB(); err == nil {
			_ = sqlDB.Close()
		}
	}
	return d, cleanup, nil
}

func seedCatalogIfEmpty(db *gorm.DB, cat *game.Catalog) error {
	var count int64
	if err := db.Model(&model.ShopItem{}).Count(&count).Error; err != nil {
		return err
	}
	if count > 0 {
		return nil
	}
	return db.Transaction(func(tx *gorm.DB) error {
		for _, it := range cat.Items {
			row := model.ShopItem{
				ID: it.ID, Name: it.Name, Description: it.Description, Price: it.Price,
				Slot: it.Slot, Rarity: it.Rarity, Currency: it.Currency, Icon: it.Icon, Category: it.Category,
				StatStr: int32(it.Stats.Strength), StatInt: int32(it.Stats.Intelligence),
				StatAgi: int32(it.Stats.Agility), StatDef: int32(it.Stats.Defense),
				StatVit: int32(it.Stats.Vitality), StatLuk: int32(it.Stats.Luck),
			}
			if err := tx.Create(&row).Error; err != nil {
				return err
			}
		}
		for _, a := range cat.Achievements {
			row := model.AchievementDef{
				ID: a.ID, Title: a.Title, Description: a.Description,
				ConditionType: a.ConditionType, Threshold: int32(a.Threshold), GemReward: int32(a.GemReward),
			}
			if err := tx.Create(&row).Error; err != nil {
				return err
			}
		}
		return nil
	})
}

func seedGameConstants(db *gorm.DB) error {
	rows := []model.GameConstant{
		{Key: "max_level", Value: fmt.Sprintf("%d", game.MaxLevel)},
		{Key: "max_hp", Value: fmt.Sprintf("%d", game.MaxHp)},
		{Key: "initial_hp", Value: fmt.Sprintf("%d", game.InitialHp)},
		{Key: "death_recovery_minutes", Value: fmt.Sprintf("%d", game.DeathRecoveryMinutes)},
		{Key: "death_recovery_hp", Value: fmt.Sprintf("%d", game.DeathRecoveryHp)},
		{Key: "complete_task_add_hp", Value: fmt.Sprintf("%d", game.CompleteTaskAddHp)},
		{Key: "stat_points_per_level", Value: fmt.Sprintf("%d", game.StatPointsPerLevel)},
		{Key: "exp_easy", Value: fmt.Sprintf("%d", game.ExpEasy)},
		{Key: "exp_medium", Value: fmt.Sprintf("%d", game.ExpMedium)},
		{Key: "exp_hard", Value: fmt.Sprintf("%d", game.ExpHard)},
		{Key: "gold_easy", Value: fmt.Sprintf("%d", game.GoldEasy)},
		{Key: "gold_medium", Value: fmt.Sprintf("%d", game.GoldMedium)},
		{Key: "gold_hard", Value: fmt.Sprintf("%d", game.GoldHard)},
	}
	for _, r := range rows {
		var existing model.GameConstant
		err := db.Where("key = ?", r.Key).First(&existing).Error
		if err == gorm.ErrRecordNotFound {
			if err := db.Create(&r).Error; err != nil {
				return err
			}
		} else if err != nil {
			return err
		}
	}
	return nil
}

// InTx runs fn inside a transaction.
func (d *Data) InTx(ctx context.Context, fn func(tx *gorm.DB) error) error {
	return d.db.WithContext(ctx).Transaction(fn)
}

// ProviderSet is the data layer DI provider.
var ProviderSet = wire.NewSet(
	NewData,
	NewUserRepo,
	NewCharacterRepo,
	NewTaskRepo,
	NewShopRepo,
	NewAchievementRepo,
	NewPrefsRepo,
)
