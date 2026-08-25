package service

import (
	"context"

	statsv1 "github.com/habitforge/backend/api/stats/v1"
	"github.com/habitforge/backend/internal/biz"
)

// StatsService implements the StatsService interface (HTTP + gRPC).
type StatsService struct {
	statsv1.UnimplementedStatsServiceServer
	uc *biz.StatsUseCase
}

// NewStatsService builds the stats service.
func NewStatsService(uc *biz.StatsUseCase) *StatsService {
	return &StatsService{uc: uc}
}

// GetStats returns task statistics over a time range.
// TODO(implementation): delegate to s.uc.Get.
func (s *StatsService) GetStats(ctx context.Context, req *statsv1.GetStatsRequest) (*statsv1.GetStatsReply, error) {
	return nil, errNotImplemented()
}
