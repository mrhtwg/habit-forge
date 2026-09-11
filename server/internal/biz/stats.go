package biz

import (
	"context"
	"fmt"
	"sort"
	"time"

	"github.com/habitforge/backend/internal/data"
	"github.com/habitforge/backend/internal/game"
)

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
	Range               StatsRange
	Segments            []*TimeSegment
	StreakLeaderboard   []*StreakEntry
	TotalTasksCompleted int64
	TotalGoldEarned     int64
	TotalExpEarned      int64
}

// StatsUseCase handles statistics aggregation.
type StatsUseCase struct {
	tasks *data.TaskRepo
	prefs *data.PrefsRepo
	chars *data.CharacterRepo
	data  *data.Data
}

// NewStatsUseCase builds the stats use case.
func NewStatsUseCase(tasks *data.TaskRepo, prefs *data.PrefsRepo, chars *data.CharacterRepo, d *data.Data) *StatsUseCase {
	return &StatsUseCase{tasks: tasks, prefs: prefs, chars: chars, data: d}
}

// Get returns statistics for the given range.
func (uc *StatsUseCase) Get(ctx context.Context, userID string, r StatsRange) (*Stats, error) {
	rows, err := uc.tasks.List(ctx, userID)
	if err != nil {
		return nil, err
	}
	p, _ := uc.prefs.Get(ctx, userID)
	c, _ := uc.chars.GetByUserID(ctx, userID)
	bonus := uc.data.Catalog.BonusLookup()

	now := time.Now()
	var since time.Time
	switch r {
	case StatsDay:
		since = time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
	case StatsWeek:
		since = now.AddDate(0, 0, -7)
	case StatsMonth:
		since = now.AddDate(0, -1, 0)
	default:
		since = time.Time{}
		r = StatsAll
	}

	segments := map[string]int64{}
	var totalCompleted int64
	var totalGold, totalExp int64
	streaks := make([]*StreakEntry, 0)

	for _, t := range rows {
		if t.Streak > 0 {
			streaks = append(streaks, &StreakEntry{TaskID: t.ID, Title: t.Title, Streak: t.Streak})
		}
		if !t.IsCompleted || t.CompletedAt <= 0 {
			continue
		}
		completedAt := time.UnixMilli(t.CompletedAt)
		if !since.IsZero() && completedAt.Before(since) {
			continue
		}
		totalCompleted++
		label := segmentLabel(completedAt, r)
		segments[label]++

		gt := fromModelTask(t)
		if c != nil {
			gc := fromModelCharacter(c)
			totalExp += int64(game.ExpReward(gt, gc, bonus))
			totalGold += int64(game.GoldReward(gt, gc, bonus))
		} else {
			totalExp += int64(game.BaseExpReward(t.Difficulty))
			totalGold += int64(game.BaseGoldReward(t.Difficulty))
		}
	}

	segList := make([]*TimeSegment, 0, len(segments))
	for k, v := range segments {
		segList = append(segList, &TimeSegment{Label: k, CompletedCount: v})
	}
	sort.Slice(segList, func(i, j int) bool { return segList[i].Label < segList[j].Label })
	sort.Slice(streaks, func(i, j int) bool { return streaks[i].Streak > streaks[j].Streak })
	if len(streaks) > 10 {
		streaks = streaks[:10]
	}

	if p != nil && r == StatsAll {
		totalCompleted = p.TotalTasksCompleted
	}

	return &Stats{
		Range: r, Segments: segList, StreakLeaderboard: streaks,
		TotalTasksCompleted: totalCompleted, TotalGoldEarned: totalGold, TotalExpEarned: totalExp,
	}, nil
}

func segmentLabel(t time.Time, r StatsRange) string {
	switch r {
	case StatsDay:
		return fmt.Sprintf("%02d:00", t.Hour())
	case StatsWeek:
		return t.Weekday().String()[:3]
	case StatsMonth:
		return fmt.Sprintf("%02d-%02d", t.Month(), t.Day())
	default:
		return fmt.Sprintf("%04d-%02d", t.Year(), t.Month())
	}
}
