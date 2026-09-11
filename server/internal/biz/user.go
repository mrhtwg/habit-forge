package biz

import (
	"context"
	"time"

	"github.com/habitforge/backend/internal/data"
	"github.com/habitforge/backend/internal/model"
)

// UserPrefs is the domain user-preferences / wallet entity.
type UserPrefs struct {
	CharactorClass       string
	CurrentGold          int64
	CurrentGems          int64
	SoundEnabled         bool
	HapticEnabled        bool
	NotificationsEnabled bool
	OnboardingCompleted  bool
	LastOnboardingStep   int32
	TotalTasksCompleted  int64
	TotalTasks           int64
	TodayTasksCompleted  int64
	TodayTasks           int64
	FirstTaskDate        int64
	LastPenaltyDate      int64
}

// UserUseCase handles user preferences and wallet.
type UserUseCase struct {
	prefs *data.PrefsRepo
	tasks *data.TaskRepo
}

// NewUserUseCase builds the user use case.
func NewUserUseCase(prefs *data.PrefsRepo, tasks *data.TaskRepo) *UserUseCase {
	return &UserUseCase{prefs: prefs, tasks: tasks}
}

// GetPrefs returns the current user's preferences.
func (uc *UserUseCase) GetPrefs(ctx context.Context, userID string) (*UserPrefs, error) {
	p, err := uc.prefs.Get(ctx, userID)
	if err != nil {
		return nil, err
	}
	p, err = uc.resetTodayIfNeeded(ctx, p)
	if err != nil {
		return nil, err
	}
	total, _ := uc.tasks.CountByUser(ctx, userID)
	p.TotalTasks = total
	return toBizPrefs(p), nil
}

// UpdatePrefs saves the current user's preferences.
func (uc *UserUseCase) UpdatePrefs(ctx context.Context, userID string, prefs *UserPrefs) (*UserPrefs, error) {
	p, err := uc.prefs.Get(ctx, userID)
	if err != nil {
		return nil, err
	}
	p, err = uc.resetTodayIfNeeded(ctx, p)
	if err != nil {
		return nil, err
	}
	if prefs != nil {
		p.CharactorClass = prefs.CharactorClass
		p.CurrentGold = prefs.CurrentGold
		p.CurrentGems = prefs.CurrentGems
		p.NotificationsEnabled = prefs.NotificationsEnabled
		p.SoundEnabled = prefs.SoundEnabled
		p.HapticEnabled = prefs.HapticEnabled
		p.OnboardingCompleted = prefs.OnboardingCompleted
		p.LastOnboardingStep = prefs.LastOnboardingStep
		// Preserve counters / penalty unless explicitly provided as non-zero overwrite of wallet-only fields.
		if prefs.TotalTasksCompleted > 0 {
			p.TotalTasksCompleted = prefs.TotalTasksCompleted
		}
		if prefs.TodayTasksCompleted >= 0 {
			p.TodayTasksCompleted = prefs.TodayTasksCompleted
		}
		if prefs.FirstTaskDate > 0 {
			p.FirstTaskDate = prefs.FirstTaskDate
		}
	}
	if err := uc.prefs.Save(ctx, p); err != nil {
		return nil, err
	}
	return toBizPrefs(p), nil
}

func (uc *UserUseCase) resetTodayIfNeeded(ctx context.Context, p *model.UserPrefs) (*model.UserPrefs, error) {
	today := dateOnlyMillis(time.Now())
	if p.LastActiveDate == today {
		return p, nil
	}
	p.TodayTasksCompleted = 0
	p.TodayTasks = 0
	p.LastActiveDate = today
	if err := uc.prefs.Save(ctx, p); err != nil {
		return nil, err
	}
	return p, nil
}

func dateOnlyMillis(t time.Time) int64 {
	y, m, d := t.Date()
	return time.Date(y, m, d, 0, 0, 0, 0, t.Location()).UnixMilli()
}

func toBizPrefs(p *model.UserPrefs) *UserPrefs {
	return &UserPrefs{
		CharactorClass:       p.CharactorClass,
		CurrentGold:          p.CurrentGold,
		CurrentGems:          p.CurrentGems,
		SoundEnabled:         p.SoundEnabled,
		HapticEnabled:        p.HapticEnabled,
		NotificationsEnabled: p.NotificationsEnabled,
		OnboardingCompleted:  p.OnboardingCompleted,
		LastOnboardingStep:   p.LastOnboardingStep,
		TotalTasksCompleted:  p.TotalTasksCompleted,
		TotalTasks:           p.TotalTasks,
		TodayTasksCompleted:  p.TodayTasksCompleted,
		TodayTasks:           p.TodayTasks,
		FirstTaskDate:        p.FirstTaskDate,
		LastPenaltyDate:      p.LastPenaltyDate,
	}
}
