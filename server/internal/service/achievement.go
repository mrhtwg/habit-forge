package service

import (
	"context"

	achievementv1 "github.com/habitforge/backend/api/achievement/v1"
	"github.com/habitforge/backend/internal/biz"
)

// AchievementService implements the AchievementService interface (HTTP + gRPC).
type AchievementService struct {
	achievementv1.UnimplementedAchievementServiceServer
	uc *biz.AchievementUseCase
}

// NewAchievementService builds the achievement service.
func NewAchievementService(uc *biz.AchievementUseCase) *AchievementService {
	return &AchievementService{uc: uc}
}

// ListAchievements lists all achievements with unlock state.
// TODO(implementation): delegate to s.uc.List.
func (s *AchievementService) ListAchievements(ctx context.Context, req *achievementv1.ListAchievementsRequest) (*achievementv1.ListAchievementsReply, error) {
	return nil, errNotImplemented()
}

// Unlock claims an achievement and grants its gem reward.
// TODO(implementation): delegate to s.uc.Unlock.
func (s *AchievementService) Unlock(ctx context.Context, req *achievementv1.UnlockRequest) (*achievementv1.UnlockReply, error) {
	return nil, errNotImplemented()
}
