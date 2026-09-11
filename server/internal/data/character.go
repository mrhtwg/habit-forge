package data

import (
	"context"
	"errors"

	"gorm.io/gorm"

	"github.com/habitforge/backend/internal/model"
)

// CharacterRepo persists characters.
type CharacterRepo struct{ data *Data }

// NewCharacterRepo builds CharacterRepo.
func NewCharacterRepo(d *Data) *CharacterRepo { return &CharacterRepo{data: d} }

// GetByUserID returns the user's character or nil.
func (r *CharacterRepo) GetByUserID(ctx context.Context, userID string) (*model.Character, error) {
	var c model.Character
	err := r.data.db.WithContext(ctx).Where("user_id = ?", userID).First(&c).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &c, nil
}

// Create inserts a character.
func (r *CharacterRepo) Create(ctx context.Context, c *model.Character) error {
	return r.data.db.WithContext(ctx).Create(c).Error
}

// CreateTx inserts within an existing transaction.
func (r *CharacterRepo) CreateTx(tx *gorm.DB, c *model.Character) error {
	return tx.Create(c).Error
}

// Save upserts character fields.
func (r *CharacterRepo) Save(ctx context.Context, c *model.Character) error {
	return r.data.db.WithContext(ctx).Save(c).Error
}

// SaveTx saves within a transaction.
func (r *CharacterRepo) SaveTx(tx *gorm.DB, c *model.Character) error {
	return tx.Save(c).Error
}
