package biz

import (
	"context"
	"time"

	"gorm.io/gorm"

	"github.com/habitforge/backend/internal/data"
	"github.com/habitforge/backend/internal/model"
)

// Achievement is the domain achievement entity.
type Achievement struct {
	ID            string
	Title         string
	Description   string
	ConditionType string
	Threshold     int32
	Progress      int32
	IsUnlocked    bool
	UnlockedAt    int64
	GemReward     int32
}

// AchievementUseCase handles achievements and reward claiming.
type AchievementUseCase struct {
	ach   *data.AchievementRepo
	prefs *data.PrefsRepo
	chars *data.CharacterRepo
	shop  *data.ShopRepo
	data  *data.Data
}

// NewAchievementUseCase builds the achievement use case.
func NewAchievementUseCase(
	ach *data.AchievementRepo,
	prefs *data.PrefsRepo,
	chars *data.CharacterRepo,
	shop *data.ShopRepo,
	d *data.Data,
) *AchievementUseCase {
	return &AchievementUseCase{ach: ach, prefs: prefs, chars: chars, shop: shop, data: d}
}

// List returns all achievements with the user's unlock state.
func (uc *AchievementUseCase) List(ctx context.Context, userID string) ([]*Achievement, error) {
	defs, err := uc.ach.ListDefs(ctx)
	if err != nil || len(defs) == 0 {
		// Fall back to YAML catalog.
		defs = nil
		for _, a := range uc.data.Catalog.Achievements {
			defs = append(defs, &model.AchievementDef{
				ID: a.ID, Title: a.Title, Description: a.Description,
				ConditionType: a.ConditionType, Threshold: int32(a.Threshold), GemReward: int32(a.GemReward),
			})
		}
	}
	unlocked, err := uc.ach.ListUnlockedIDs(ctx, userID)
	if err != nil {
		return nil, err
	}
	p, _ := uc.prefs.Get(ctx, userID)
	c, _ := uc.chars.GetByUserID(ctx, userID)
	purchases, _ := uc.shop.CountOwned(ctx, userID)

	out := make([]*Achievement, 0, len(defs))
	for _, def := range defs {
		a := &Achievement{
			ID: def.ID, Title: def.Title, Description: def.Description,
			ConditionType: def.ConditionType, Threshold: def.Threshold, GemReward: def.GemReward,
		}
		if at, ok := unlocked[def.ID]; ok {
			a.IsUnlocked = true
			a.UnlockedAt = at
			a.Progress = def.Threshold
		} else {
			a.Progress = progressFor(def, p, c, purchases)
		}
		out = append(out, a)
	}
	return out, nil
}

// Unlock claims an achievement and grants its gem reward.
func (uc *AchievementUseCase) Unlock(ctx context.Context, userID, id string) (*Achievement, int32, error) {
	def, err := uc.ach.GetDef(ctx, id)
	if err != nil {
		return nil, 0, err
	}
	if def == nil {
		for _, a := range uc.data.Catalog.Achievements {
			if a.ID == id {
				def = &model.AchievementDef{
					ID: a.ID, Title: a.Title, Description: a.Description,
					ConditionType: a.ConditionType, Threshold: int32(a.Threshold), GemReward: int32(a.GemReward),
				}
				break
			}
		}
	}
	if def == nil {
		return nil, 0, notFound("achievement not found")
	}
	unlocked, err := uc.ach.ListUnlockedIDs(ctx, userID)
	if err != nil {
		return nil, 0, err
	}
	if _, ok := unlocked[id]; ok {
		return nil, 0, conflict("already unlocked")
	}
	p, err := uc.prefs.Get(ctx, userID)
	if err != nil {
		return nil, 0, err
	}
	c, _ := uc.chars.GetByUserID(ctx, userID)
	purchases, _ := uc.shop.CountOwned(ctx, userID)
	if progressFor(def, p, c, purchases) < def.Threshold {
		return nil, 0, failedPrecond("condition not met")
	}
	now := time.Now().UnixMilli()
	err = uc.data.InTx(ctx, func(tx *gorm.DB) error {
		if err := uc.ach.UnlockTx(tx, userID, id, now); err != nil {
			return err
		}
		p.CurrentGems += int64(def.GemReward)
		return uc.prefs.SaveTx(tx, p)
	})
	if err != nil {
		return nil, 0, err
	}
	return &Achievement{
		ID: def.ID, Title: def.Title, Description: def.Description,
		ConditionType: def.ConditionType, Threshold: def.Threshold,
		Progress: def.Threshold, IsUnlocked: true, UnlockedAt: now, GemReward: def.GemReward,
	}, def.GemReward, nil
}

func progressFor(def *model.AchievementDef, p *model.UserPrefs, c *model.Character, purchases int64) int32 {
	var cur int64
	switch def.ConditionType {
	case "total_tasks":
		if p != nil {
			cur = p.TotalTasksCompleted
		}
	case "streak":
		// Best-effort: no single streak stored; progress 0 until auto-unlock on complete.
		cur = 0
	case "level":
		if c != nil {
			cur = int64(c.Level)
		}
	case "purchases":
		cur = purchases
	case "deaths":
		if p != nil {
			cur = p.DeathCount
		}
	}
	if cur > int64(def.Threshold) {
		return def.Threshold
	}
	return int32(cur)
}
