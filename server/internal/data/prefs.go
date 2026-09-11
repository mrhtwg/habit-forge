package data

import (
	"context"
	"errors"
	"time"

	"gorm.io/gorm"

	"github.com/habitforge/backend/internal/model"
)

// PrefsRepo persists user preferences / wallet.
type PrefsRepo struct{ data *Data }

// NewPrefsRepo builds PrefsRepo.
func NewPrefsRepo(d *Data) *PrefsRepo { return &PrefsRepo{data: d} }

// Get returns prefs for a user, creating defaults if missing.
func (r *PrefsRepo) Get(ctx context.Context, userID string) (*model.UserPrefs, error) {
	var p model.UserPrefs
	err := r.data.db.WithContext(ctx).Where("user_id = ?", userID).First(&p).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		p = model.UserPrefs{
			UserID: userID, NotificationsEnabled: true, SoundEnabled: true, HapticEnabled: true,
		}
		if err := r.data.db.WithContext(ctx).Create(&p).Error; err != nil {
			return nil, err
		}
		return &p, nil
	}
	if err != nil {
		return nil, err
	}
	return &p, nil
}

// Save updates prefs.
func (r *PrefsRepo) Save(ctx context.Context, p *model.UserPrefs) error {
	p.UpdatedAt = time.Now()
	return r.data.db.WithContext(ctx).Save(p).Error
}

// SaveTx updates prefs in a transaction.
func (r *PrefsRepo) SaveTx(tx *gorm.DB, p *model.UserPrefs) error {
	p.UpdatedAt = time.Now()
	return tx.Save(p).Error
}
