package biz

import "context"

// StatsRange is the aggregation window.
type StatsRange int32

// Supported aggregation windows.
const (
	StatsDay StatsRange = iota + 1
	StatsWeek
	StatsMonth
	StatsAll
)

// TimeSegment is one bar of the completion chart.
type TimeSegment struct {
	Label          string
	CompletedCount int64
}

// StreakEntry is one row of the streak leaderboard.
type StreakEntry struct {
	TaskID string
	Title  string
	Streak int32
}

// Stats aggregates task statistics for a user.
type Stats struct {
	Range              StatsRange
	Segments           []*TimeSegment
	StreakLeaderboard  []*StreakEntry
	TotalTasksCompleted int64
	TotalGoldEarned    int64
	TotalExpEarned     int64
}

// StatsUseCase handles statistics aggregation.
type StatsUseCase struct{}

// NewStatsUseCase builds the stats use case.
func NewStatsUseCase() *StatsUseCase { return &StatsUseCase{} }

// Get returns statistics for the given range.
func (uc *StatsUseCase) Get(ctx context.Context, userID string, r StatsRange) (*Stats, error) {
	return nil, ErrNotImplemented // TODO
}
