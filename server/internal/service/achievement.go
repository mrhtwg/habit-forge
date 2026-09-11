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
func (s *AchievementService) ListAchievements(ctx context.Context, req *achievementv1.ListAchievementsRequest) (*achievementv1.ListAchievementsReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	list, err := s.uc.List(ctx, uid)
	if err != nil {
		return nil, err
	}
	out := make([]*achievementv1.Achievement, 0, len(list))
	for _, a := range list {
		out = append(out, toProtoAchievement(a))
	}
	return &achievementv1.ListAchievementsReply{Achievements: out}, nil
}

// Unlock claims an achievement and grants its gem reward.
func (s *AchievementService) Unlock(ctx context.Context, req *achievementv1.UnlockRequest) (*achievementv1.UnlockReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	a, gems, err := s.uc.Unlock(ctx, uid, req.GetId())
	if err != nil {
		return nil, err
	}
	return &achievementv1.UnlockReply{Achievement: toProtoAchievement(a), GemReward: gems}, nil
}
