package data

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"gorm.io/gorm"

	"github.com/habitforge/backend/internal/model"
)

// AchievementRepo persists achievement defs and unlocks.
type AchievementRepo struct{ data *Data }

// NewAchievementRepo builds AchievementRepo.
func NewAchievementRepo(d *Data) *AchievementRepo { return &AchievementRepo{data: d} }

// ListDefs returns all achievement definitions.
func (r *AchievementRepo) ListDefs(ctx context.Context) ([]*model.AchievementDef, error) {
	var defs []*model.AchievementDef
	err := r.data.db.WithContext(ctx).Order("threshold asc").Find(&defs).Error
	return defs, err
}

// GetDef returns one definition.
func (r *AchievementRepo) GetDef(ctx context.Context, id string) (*model.AchievementDef, error) {
	var d model.AchievementDef
	err := r.data.db.WithContext(ctx).Where("id = ?", id).First(&d).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &d, nil
}

// ListUnlockedIDs returns unlocked achievement ids for a user.
func (r *AchievementRepo) ListUnlockedIDs(ctx context.Context, userID string) (map[string]int64, error) {
	var rows []model.UserAchievement
	if err := r.data.db.WithContext(ctx).Where("user_id = ?", userID).Find(&rows).Error; err != nil {
		return nil, err
	}
	out := make(map[string]int64, len(rows))
	for _, r := range rows {
		out[r.AchieveID] = r.UnlockedAt
	}
	return out, nil
}

// Unlock records an unlock.
func (r *AchievementRepo) Unlock(ctx context.Context, userID, achieveID string, at int64) error {
	return r.data.db.WithContext(ctx).Create(&model.UserAchievement{
		ID: uuid.NewString(), UserID: userID, AchieveID: achieveID, UnlockedAt: at,
	}).Error
}

// UnlockTx records an unlock in a transaction.
func (r *AchievementRepo) UnlockTx(tx *gorm.DB, userID, achieveID string, at int64) error {
	return tx.Create(&model.UserAchievement{
		ID: uuid.NewString(), UserID: userID, AchieveID: achieveID, UnlockedAt: at,
	}).Error
}
