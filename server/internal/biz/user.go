package biz

import "context"

// UserPrefs is the domain user-preferences / wallet entity.
type UserPrefs struct {
	OnboardingCompleted bool
	LastOnboardingStep  int32
	CurrentGold         int64
	CurrentGems         int64
	SoundEnabled        bool
	HapticEnabled       bool
	NotificationsEnabled bool
	TotalTasksCompleted int64
	FirstTaskDate       int64 // unix millis
}

// UserUseCase handles user preferences and wallet.
type UserUseCase struct{}

// NewUserUseCase builds the user use case.
func NewUserUseCase() *UserUseCase { return &UserUseCase{} }

// GetPrefs returns the current user's preferences.
func (uc *UserUseCase) GetPrefs(ctx context.Context, userID string) (*UserPrefs, error) {
	return nil, ErrNotImplemented // TODO
}

// UpdatePrefs saves the current user's preferences.
func (uc *UserUseCase) UpdatePrefs(ctx context.Context, userID string, prefs *UserPrefs) (*UserPrefs, error) {
	return nil, ErrNotImplemented // TODO
}
