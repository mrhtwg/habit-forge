package game

import "math"

const (
	MaxLevel             = 50
	MaxHp                = 100
	InitialHp            = 100
	DeathRecoveryMinutes = 30
	DeathRecoveryHp      = 50
	CompleteTaskAddHp    = 20
	StatPointsPerLevel   = 1

	ExpEasy   = 15
	ExpMedium = 30
	ExpHard   = 50

	GoldEasy   = 5
	GoldMedium = 10
	GoldHard   = 20
)

// MaxHpFor returns the HP cap for a character with the given vitality.
func MaxHpFor(vitality int) int {
	return MaxHp + vitality*2
}

// ExpForLevel returns EXP needed to advance from level to level+1.
// Formula: 100 + (level-1)*50 + (level-1)^2 * 10
func ExpForLevel(level int) int {
	n := level - 1
	return 100 + n*50 + n*n*10
}

// CalculateLevel derives level from cumulative total EXP (legacy helper).
func CalculateLevel(totalExp int) int {
	level := 1
	for i := 1; i <= MaxLevel; i++ {
		needed := ExpForLevel(i)
		if totalExp < needed {
			return level
		}
		totalExp -= needed
		level = i + 1
	}
	return MaxLevel
}

// ExpProgress returns progress percent within the current level.
func ExpProgress(currentExp, level int) int {
	needed := ExpForLevel(level)
	if needed <= 0 {
		return 0
	}
	return int(math.Round(float64(currentExp) * 100 / float64(needed)))
}

// StreakMultiplier caps at 2.0: 1.0 + streak*0.02.
func StreakMultiplier(streak int) float64 {
	m := 1.0 + float64(streak)*0.02
	if m > 2.0 {
		return 2.0
	}
	return m
}

// BaseExpReward returns difficulty-based base EXP.
func BaseExpReward(difficulty string) int {
	switch difficulty {
	case "medium", "TASK_DIFFICULTY_MEDIUM":
		return ExpMedium
	case "hard", "TASK_DIFFICULTY_HARD":
		return ExpHard
	default:
		return ExpEasy
	}
}

// BaseGoldReward returns difficulty-based base gold.
func BaseGoldReward(difficulty string) int {
	switch difficulty {
	case "medium", "TASK_DIFFICULTY_MEDIUM":
		return GoldMedium
	case "hard", "TASK_DIFFICULTY_HARD":
		return GoldHard
	default:
		return GoldEasy
	}
}
