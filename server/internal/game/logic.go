package game

import (
	"math"
	"strings"
	"time"
)

// Stats is the six-attribute block.
type Stats struct {
	Strength     int
	Intelligence int
	Agility      int
	Defense      int
	Vitality     int
	Luck         int
}

// Character is the mutable RPG character state used by game rules.
type Character struct {
	ID                  string
	CharacterClass      string
	Level               int
	CurrentExp          int64
	MaxExp              int64
	CurrentHp           int
	BaseStats           Stats
	AvailableStatPoints int
	Equipment           map[string]string
	IsDead              bool
	DeathRecoveryUntil  int64
}

// Task is the mutable task state used by game rules.
type Task struct {
	ID               string
	Title            string
	Description      string
	Type             string // habit | daily | todo | TASK_TYPE_*
	Difficulty       string
	Tags             []string
	IsCompleted      bool
	CompletedAt      int64
	DueDate          int64
	RepeatDays       []int32
	Streak           int
	LastStreakDate   int64
	CustomExpReward  int
	CustomGoldReward int
	Priority         string
	HpPenalty        int
	IsSkipped        bool
	CreatedAt        int64
	UpdatedAt        int64
}

// AchievementUnlock is a newly unlocked achievement definition snapshot.
type AchievementUnlock struct {
	ID            string
	Title         string
	Description   string
	ConditionType string
	Threshold     int
	GemReward     int
	UnlockedAt    int64
}

// AchievementDef is a catalog achievement definition.
type AchievementDef struct {
	ID            string
	Title         string
	Description   string
	ConditionType string
	Threshold     int
	GemReward     int
}

// BonusLookup returns equipment bonus stats for an item id.
type BonusLookup func(itemID string) Stats

// SlotKey maps an equipment slot enum/name to the character equipment map key.
func SlotKey(slot string) string {
	switch strings.ToLower(slot) {
	case "weapon", "equipment_slot_weapon", "1":
		return "weapon"
	case "helmet", "equipment_slot_helmet", "2":
		return "helmet"
	case "armor", "equipment_slot_armor", "3":
		return "armor"
	case "accessory", "equipment_slot_accessory", "4":
		return "accessory"
	default:
		return "unspecified"
	}
}

// SlotKeyFromInt maps shared.EquipmentSlot int values.
func SlotKeyFromInt(slot int32) string {
	switch slot {
	case 1:
		return "weapon"
	case 2:
		return "helmet"
	case 3:
		return "armor"
	case 4:
		return "accessory"
	default:
		return "unspecified"
	}
}

// InvalidTaskShape validates create/update task shape. Returns reason or "".
func InvalidTaskShape(t Task) string {
	if strings.TrimSpace(t.Title) == "" ||
		normalizeType(t.Type) == "" ||
		normalizeDifficulty(t.Difficulty) == "" {
		return "Title, type and difficulty are required"
	}
	if normalizeType(t.Type) == "daily" && len(t.RepeatDays) == 0 {
		return "Daily tasks require at least one repeat day"
	}
	if normalizeType(t.Type) == "todo" && t.DueDate <= 0 {
		return "Todo tasks require a due date"
	}
	return ""
}

// WeekdayIndex returns 0=Mon .. 6=Sun (matches DateTime.weekday-1).
func WeekdayIndex(d time.Time) int {
	// Go: Sunday=0 .. Saturday=6. Dart weekday: Mon=1 .. Sun=7 → weekday-1.
	wd := int(d.Weekday()) // Sun=0
	if wd == 0 {
		return 6
	}
	return wd - 1
}

func dateOnly(t time.Time) time.Time {
	y, m, d := t.Date()
	return time.Date(y, m, d, 0, 0, 0, 0, t.Location())
}

func isSameDay(a, b time.Time) bool {
	ay, am, ad := a.Date()
	by, bm, bd := b.Date()
	return ay == by && am == bm && ad == bd
}

func isToday(millis int64, now time.Time) bool {
	if millis <= 0 {
		return false
	}
	t := time.UnixMilli(millis).In(now.Location())
	return isSameDay(t, now)
}

func normalizeType(t string) string {
	switch strings.ToLower(t) {
	case "habit", "task_type_habit", "1":
		return "habit"
	case "daily", "task_type_daily", "2":
		return "daily"
	case "todo", "task_type_todo", "3":
		return "todo"
	default:
		return ""
	}
}

func normalizeDifficulty(d string) string {
	switch strings.ToLower(d) {
	case "easy", "task_difficulty_easy", "1":
		return "easy"
	case "medium", "task_difficulty_medium", "2":
		return "medium"
	case "hard", "task_difficulty_hard", "3":
		return "hard"
	default:
		return ""
	}
}

// IsDueOn reports whether task is scheduled on the given calendar day.
func IsDueOn(task Task, day time.Time) bool {
	day = dateOnly(day)
	switch normalizeType(task.Type) {
	case "habit":
		return true
	case "daily":
		idx := int32(WeekdayIndex(day))
		for _, d := range task.RepeatDays {
			if d == idx {
				return true
			}
		}
		return false
	case "todo":
		if task.DueDate <= 0 {
			return false
		}
		due := dateOnly(time.UnixMilli(task.DueDate).In(day.Location()))
		return isSameDay(due, day)
	default:
		return false
	}
}

// RolloverIfNeeded re-arms a repeatable task completed on a previous day.
// Returns nil when no change is needed.
func RolloverIfNeeded(task Task, now time.Time) *Task {
	if !task.IsCompleted {
		return nil
	}
	if isToday(task.CompletedAt, now) {
		return nil
	}
	typ := normalizeType(task.Type)
	repeatable := typ == "habit" || (typ == "daily" && IsDueOn(task, now))
	if !repeatable {
		return nil
	}
	out := task
	out.IsCompleted = false
	return &out
}

// OverduePenalty returns HP damage from tasks due and left uncompleted yesterday.
func OverduePenalty(tasks []Task, yesterday time.Time) int {
	y := dateOnly(yesterday)
	damage := 0
	for _, task := range tasks {
		if task.IsSkipped {
			continue
		}
		completedAt := dateOnly(time.UnixMilli(task.CompletedAt).In(y.Location()))
		if task.IsCompleted && isSameDay(completedAt, y) {
			continue
		}
		typ := normalizeType(task.Type)
		if typ == "todo" {
			if task.IsCompleted {
				continue
			}
			if task.DueDate <= 0 {
				continue
			}
			dueDay := dateOnly(time.UnixMilli(task.DueDate).In(y.Location()))
			if dueDay.After(y) {
				continue
			}
		} else if !IsDueOn(task, y) {
			continue
		}
		damage += task.HpPenalty
	}
	return damage
}

// NewlyUnlocked returns achievements whose condition is newly met.
func NewlyUnlocked(defs []AchievementDef, unlockedIDs map[string]struct{}, totalTasks, streak, level, purchases, deaths int) []AchievementUnlock {
	now := time.Now().UnixMilli()
	out := make([]AchievementUnlock, 0)
	for _, def := range defs {
		if _, ok := unlockedIDs[def.ID]; ok {
			continue
		}
		met := false
		switch def.ConditionType {
		case "total_tasks":
			met = totalTasks >= def.Threshold
		case "streak":
			met = streak >= def.Threshold
		case "level":
			met = level >= def.Threshold
		case "purchases":
			met = purchases >= def.Threshold
		case "deaths":
			met = deaths >= def.Threshold
		}
		if !met {
			continue
		}
		out = append(out, AchievementUnlock{
			ID:            def.ID,
			Title:         def.Title,
			Description:   def.Description,
			ConditionType: def.ConditionType,
			Threshold:     def.Threshold,
			GemReward:     def.GemReward,
			UnlockedAt:    now,
		})
	}
	return out
}

// AllocateStat spends one available point on the given attribute.
// stat: strength|intelligence|agility|defense|vitality|luck (or STAT_TYPE_*).
func AllocateStat(c Character, stat string) Character {
	if c.AvailableStatPoints <= 0 {
		return c
	}
	s := c.BaseStats
	switch strings.ToLower(stat) {
	case "strength", "stat_type_strength", "1":
		s.Strength++
	case "intelligence", "stat_type_intelligence", "2":
		s.Intelligence++
	case "agility", "stat_type_agility", "3":
		s.Agility++
	case "defense", "stat_type_defense", "4":
		s.Defense++
	case "vitality", "stat_type_vitality", "5":
		s.Vitality++
	case "luck", "stat_type_luck", "6":
		s.Luck++
	default:
		return c
	}
	c.AvailableStatPoints--
	c.BaseStats = s
	return c
}

// CompleteTask marks the task complete and bumps the streak (once per day).
func CompleteTask(task Task, now time.Time) Task {
	newStreak := task.Streak
	if !isToday(task.LastStreakDate, now) {
		newStreak = task.Streak + 1
	}
	millis := now.UnixMilli()
	task.IsCompleted = true
	task.Streak = newStreak
	task.LastStreakDate = millis
	task.CompletedAt = millis
	task.UpdatedAt = millis
	return task
}

// Equip equips itemID into slot; empty itemID or re-equipping unequips.
func Equip(c Character, slot, itemID string) Character {
	eq := make(map[string]string, len(c.Equipment))
	for k, v := range c.Equipment {
		eq[k] = v
	}
	if itemID == "" || eq[slot] == itemID {
		delete(eq, slot)
	} else {
		eq[slot] = itemID
	}
	c.Equipment = eq
	return c
}

// EffectiveStats returns base stats plus equipped item bonuses.
func EffectiveStats(c Character, bonusOf BonusLookup) Stats {
	s := c.BaseStats
	if bonusOf == nil {
		return s
	}
	for _, itemID := range c.Equipment {
		b := bonusOf(itemID)
		s.Strength += b.Strength
		s.Intelligence += b.Intelligence
		s.Agility += b.Agility
		s.Defense += b.Defense
		s.Vitality += b.Vitality
		s.Luck += b.Luck
	}
	return s
}

// MaxHpOf returns the HP cap for c (or base MaxHp when nil).
func MaxHpOf(c *Character, bonusOf BonusLookup) int {
	if c == nil {
		return MaxHp
	}
	return MaxHpFor(EffectiveStats(*c, bonusOf).Vitality)
}

// ExpReward returns EXP for completing a task.
func ExpReward(task Task, character Character, bonusOf BonusLookup) int {
	if task.CustomExpReward > 0 {
		return task.CustomExpReward
	}
	base := float64(BaseExpReward(normalizeDifficulty(task.Difficulty))) * StreakMultiplier(task.Streak)
	return int(math.Round(base * (1 + float64(EffectiveStats(character, bonusOf).Intelligence)*0.01)))
}

// GoldReward returns gold for completing a task.
func GoldReward(task Task, character Character, bonusOf BonusLookup) int {
	if task.CustomGoldReward > 0 {
		return task.CustomGoldReward
	}
	base := float64(BaseGoldReward(normalizeDifficulty(task.Difficulty)))
	return int(math.Round(base * (1 + float64(EffectiveStats(character, bonusOf).Strength)*0.01)))
}

// GainExp applies exp and returns (character, newLevel or -1).
func GainExp(c Character, exp int, bonusOf BonusLookup) (Character, int) {
	remaining := int(c.CurrentExp) + exp
	level := c.Level
	if level < 1 {
		level = 1
	}
	for level < MaxLevel && remaining >= ExpForLevel(level) {
		remaining -= ExpForLevel(level)
		level++
	}
	if level <= c.Level {
		if level >= MaxLevel {
			maxForLevel := ExpForLevel(level)
			if remaining < 0 {
				remaining = 0
			}
			if remaining > maxForLevel {
				remaining = maxForLevel
			}
		}
		c.CurrentExp = int64(remaining)
		c.MaxExp = int64(ExpForLevel(c.Level))
		return c, -1
	}
	gained := (level - c.Level) * StatPointsPerLevel
	maxForLevel := ExpForLevel(level)
	cappedExp := remaining
	if level >= MaxLevel {
		if cappedExp < 0 {
			cappedExp = 0
		}
		if cappedExp > maxForLevel {
			cappedExp = maxForLevel
		}
	}
	maxHp := MaxHpFor(EffectiveStats(c, bonusOf).Vitality)
	newHp := c.CurrentHp + CompleteTaskAddHp
	if newHp < 0 {
		newHp = 0
	}
	if newHp > maxHp {
		newHp = maxHp
	}
	c.CurrentExp = int64(cappedExp)
	c.Level = level
	c.MaxExp = int64(maxForLevel)
	c.AvailableStatPoints += gained
	c.CurrentHp = newHp
	return c, level
}

// Postpone skips the task and (for todos) pushes due date to tomorrow.
func Postpone(task Task, now time.Time) Task {
	tomorrow := now.Add(24 * time.Hour)
	task.IsSkipped = true
	if normalizeType(task.Type) == "todo" {
		task.DueDate = tomorrow.UnixMilli()
	}
	return task
}

// Revive revives a dead character with recovery HP.
func Revive(c Character) Character {
	c.IsDead = false
	c.CurrentHp = DeathRecoveryHp
	c.DeathRecoveryUntil = 0
	return c
}

// TakeDamage applies damage; DEF absorbs 1 per point (min 1 damage).
func TakeDamage(c Character, amount int, bonusOf BonusLookup, now time.Time) Character {
	if c.IsDead {
		return c
	}
	effective := EffectiveStats(c, bonusOf)
	reduced := amount - effective.Defense
	dealt := reduced
	if dealt < 1 {
		dealt = 1
	}
	maxHp := MaxHpFor(effective.Vitality)
	newHp := c.CurrentHp - dealt
	if newHp < 0 {
		newHp = 0
	}
	if newHp > maxHp {
		newHp = maxHp
	}
	dead := newHp <= 0
	c.CurrentHp = newHp
	c.IsDead = dead
	if dead {
		c.DeathRecoveryUntil = now.Add(time.Duration(DeathRecoveryMinutes) * time.Minute).UnixMilli()
	} else {
		c.DeathRecoveryUntil = 0
	}
	return c
}
