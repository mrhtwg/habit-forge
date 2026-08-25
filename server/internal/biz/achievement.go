package biz

import "context"

// Achievement is the domain achievement entity.
type Achievement struct {
	ID            string
	Title         string
	Description   string
	ConditionType string // tasks_completed | streak | level ...
	Threshold     int32
	Progress      int32
	IsUnlocked    bool
	UnlockedAt    int64 // unix millis
	GemReward     int32
}

// AchievementUseCase handles achievements and reward claiming.
type AchievementUseCase struct{}

// NewAchievementUseCase builds the achievement use case.
func NewAchievementUseCase() *AchievementUseCase { return &AchievementUseCase{} }

// List returns all achievements with the user's unlock state.
func (uc *AchievementUseCase) List(ctx context.Context, userID string) ([]*Achievement, error) {
	return nil, ErrNotImplemented // TODO
}

// Unlock claims an achievement and grants its gem reward.
func (uc *AchievementUseCase) Unlock(ctx context.Context, userID, id string) (*Achievement, int32, error) {
	return nil, 0, ErrNotImplemented // TODO
}
