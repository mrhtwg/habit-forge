package biz

import (
	"context"
	"time"

	"gorm.io/gorm"

	"github.com/habitforge/backend/internal/data"
	"github.com/habitforge/backend/internal/game"
	"github.com/habitforge/backend/internal/model"
)

// settleDayForUser applies overdue HP penalty once per calendar day and rolls over tasks.
func settleDayForUser(ctx context.Context, d *data.Data, chars *data.CharacterRepo, prefs *data.PrefsRepo, tasks *data.TaskRepo, userID string) error {
	now := time.Now()
	today := dateOnlyMillis(now)

	// Rollover tasks first.
	all, err := tasks.List(ctx, userID)
	if err != nil {
		return err
	}
	for _, t := range all {
		gt := fromModelTask(t)
		if reset := game.RolloverIfNeeded(gt, now); reset != nil {
			toModelTask(t, *reset)
			if err := tasks.Save(ctx, t); err != nil {
				return err
			}
		}
	}

	p, err := prefs.Get(ctx, userID)
	if err != nil {
		return err
	}
	if p.LastActiveDate != today {
		p.TodayTasksCompleted = 0
		p.TodayTasks = 0
		p.LastActiveDate = today
		if err := prefs.Save(ctx, p); err != nil {
			return err
		}
	}
	if p.LastPenaltyDate == today {
		return nil
	}

	yesterday := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location()).AddDate(0, 0, -1)
	gTasks := make([]game.Task, 0, len(all))
	// re-list after rollover
	all, err = tasks.List(ctx, userID)
	if err != nil {
		return err
	}
	for _, t := range all {
		gTasks = append(gTasks, fromModelTask(t))
	}
	damage := game.OverduePenalty(gTasks, yesterday)

	return d.InTx(ctx, func(tx *gorm.DB) error {
		p2, err := prefs.Get(ctx, userID)
		if err != nil {
			return err
		}
		if p2.LastPenaltyDate == today {
			return nil
		}
		c, err := chars.GetByUserID(ctx, userID)
		if err != nil {
			return err
		}
		if c != nil && !c.IsDead && damage > 0 {
			gc := game.TakeDamage(fromModelCharacter(c), damage, d.Catalog.BonusLookup(), now)
			toModelCharacter(c, gc)
			if err := chars.SaveTx(tx, c); err != nil {
				return err
			}
		}
		p2.LastPenaltyDate = today
		return prefs.SaveTx(tx, p2)
	})
}

// applyUnlocks unlocks newly met achievements and grants gem rewards.
func applyUnlocks(
	ctx context.Context,
	tx *gorm.DB,
	d *data.Data,
	ach *data.AchievementRepo,
	prefs *data.PrefsRepo,
	userID string,
	p *model.UserPrefs,
	c *model.Character,
	streak int,
	deathsOverride int,
) error {
	unlocked, err := ach.ListUnlockedIDs(ctx, userID)
	if err != nil {
		return err
	}
	set := make(map[string]struct{}, len(unlocked))
	for id := range unlocked {
		set[id] = struct{}{}
	}
	defs := make([]game.AchievementDef, 0, len(d.Catalog.Achievements))
	for _, a := range d.Catalog.Achievements {
		defs = append(defs, a)
	}
	level := 1
	if c != nil {
		level = int(c.Level)
	}
	purchases, _ := countOwnedTx(tx, userID)
	deaths := int(p.DeathCount)
	if deathsOverride > 0 {
		deaths = deathsOverride
	}
	fresh := game.NewlyUnlocked(defs, set, int(p.TotalTasksCompleted), streak, level, int(purchases), deaths)
	gems := 0
	for _, a := range fresh {
		if err := ach.UnlockTx(tx, userID, a.ID, a.UnlockedAt); err != nil {
			return err
		}
		gems += a.GemReward
	}
	if gems > 0 {
		p.CurrentGems += int64(gems)
	}
	return prefs.SaveTx(tx, p)
}

func countOwnedTx(tx *gorm.DB, userID string) (int64, error) {
	var n int64
	err := tx.Model(&model.OwnedItem{}).Where("user_id = ?", userID).Count(&n).Error
	return n, err
}

func fromModelTask(t *model.Task) game.Task {
	return game.Task{
		ID: t.ID, Title: t.Title, Description: t.Description, Type: t.Type, Difficulty: t.Difficulty,
		Tags: []string(t.Tags), IsCompleted: t.IsCompleted, CompletedAt: t.CompletedAt, DueDate: t.DueDate,
		RepeatDays: []int32(t.RepeatDays), Streak: int(t.Streak), LastStreakDate: t.LastStreakDate,
		CustomExpReward: int(t.CustomExpReward), CustomGoldReward: int(t.CustomGoldReward),
		Priority: t.Priority, HpPenalty: int(t.HpPenalty), IsSkipped: t.IsSkipped,
		CreatedAt: t.CreatedAtMillis, UpdatedAt: t.UpdatedAtMillis,
	}
}

func toModelTask(dst *model.Task, src game.Task) {
	dst.IsCompleted = src.IsCompleted
	dst.CompletedAt = src.CompletedAt
	dst.DueDate = src.DueDate
	dst.Streak = int32(src.Streak)
	dst.LastStreakDate = src.LastStreakDate
	dst.IsSkipped = src.IsSkipped
	dst.UpdatedAtMillis = src.UpdatedAt
	if src.UpdatedAt == 0 {
		dst.UpdatedAtMillis = time.Now().UnixMilli()
	}
}
