package service

import (
	"strings"

	achievementv1 "github.com/habitforge/backend/api/achievement/v1"
	authv1 "github.com/habitforge/backend/api/auth/v1"
	characterv1 "github.com/habitforge/backend/api/character/v1"
	sharedv1 "github.com/habitforge/backend/api/shared/v1"
	shopv1 "github.com/habitforge/backend/api/shop/v1"
	statsv1 "github.com/habitforge/backend/api/stats/v1"
	taskv1 "github.com/habitforge/backend/api/task/v1"
	userv1 "github.com/habitforge/backend/api/user/v1"
	"github.com/habitforge/backend/internal/biz"
)

func toProtoUser(u *biz.User) *authv1.UserInfo {
	if u == nil {
		return nil
	}
	return &authv1.UserInfo{
		Id: u.ID, Email: u.Email, Nickname: u.Nickname, AvatarUrl: u.AvatarURL,
		CreatedAt: u.CreatedAt, UpdatedAt: u.UpdatedAt,
	}
}

func toProtoPrefs(p *biz.UserPrefs) *userv1.UserPrefs {
	if p == nil {
		return nil
	}
	return &userv1.UserPrefs{
		CharactorClass:       parseCharacterClass(p.CharactorClass),
		CurrentGold:          p.CurrentGold,
		CurrentGems:          p.CurrentGems,
		NotificationsEnabled: p.NotificationsEnabled,
		TotalTasksCompleted:  p.TotalTasksCompleted,
		TotalTasks:           p.TotalTasks,
		TodayTasksCompleted:  p.TodayTasksCompleted,
		TodayTasks:           p.TodayTasks,
		FirstTaskDate:        p.FirstTaskDate,
	}
}

func fromProtoPrefs(p *userv1.UserPrefs) *biz.UserPrefs {
	if p == nil {
		return nil
	}
	return &biz.UserPrefs{
		CharactorClass:       characterClassName(p.CharactorClass),
		CurrentGold:          p.CurrentGold,
		CurrentGems:          p.CurrentGems,
		NotificationsEnabled: p.NotificationsEnabled,
		TotalTasksCompleted:  p.TotalTasksCompleted,
		TotalTasks:           p.TotalTasks,
		TodayTasksCompleted:  p.TodayTasksCompleted,
		TodayTasks:           p.TodayTasks,
		FirstTaskDate:        p.FirstTaskDate,
	}
}

func toProtoCharacter(c *biz.Character) *characterv1.Character {
	if c == nil {
		return nil
	}
	eq := map[string]string{}
	for k, v := range c.Equipment {
		eq[k] = v
	}
	return &characterv1.Character{
		Id: c.ID, Character_Class: parseCharacterClass(c.CharacterClass),
		Level: c.Level, CurrentExp: c.CurrentExp, MaxExp: c.MaxExp, CurrentHp: c.CurrentHp,
		BaseStats: &characterv1.CharacterStats{
			Strength: c.BaseStats.Strength, Intelligence: c.BaseStats.Intelligence,
			Agility: c.BaseStats.Agility, Defense: c.BaseStats.Defense,
			Vitality: c.BaseStats.Vitality, Luck: c.BaseStats.Luck,
		},
		AvailableStatPoints: c.AvailableStatPoints, Equipment: eq,
		IsDead: c.IsDead, DeathRecoveryUntil: c.DeathRecoveryUntil,
	}
}

func fromProtoCharacter(c *characterv1.Character) *biz.Character {
	if c == nil {
		return nil
	}
	bs := c.GetBaseStats()
	eq := map[string]string{}
	for k, v := range c.Equipment {
		eq[k] = v
	}
	out := &biz.Character{
		ID: c.Id, CharacterClass: characterClassName(c.Character_Class),
		Level: c.Level, CurrentExp: c.CurrentExp, MaxExp: c.MaxExp, CurrentHp: c.CurrentHp,
		AvailableStatPoints: c.AvailableStatPoints, Equipment: eq,
		IsDead: c.IsDead, DeathRecoveryUntil: c.DeathRecoveryUntil,
	}
	if bs != nil {
		out.BaseStats = biz.CharacterStats{
			Strength: bs.Strength, Intelligence: bs.Intelligence, Agility: bs.Agility,
			Defense: bs.Defense, Vitality: bs.Vitality, Luck: bs.Luck,
		}
	}
	return out
}

func toProtoTask(t *biz.Task) *taskv1.Task {
	if t == nil {
		return nil
	}
	return &taskv1.Task{
		Id: t.ID, Title: t.Title, Description: t.Description,
		Type: parseTaskType(t.Type), Difficulty: parseDifficulty(t.Difficulty),
		Tags: t.Tags, IsCompleted: t.IsCompleted, CompletedAt: t.CompletedAt, DueDate: t.DueDate,
		RepeatDays: t.RepeatDays, Streak: t.Streak, LastStreakDate: t.LastStreakDate,
		CustomExpReward: t.CustomExpReward, CustomGoldReward: t.CustomGoldReward,
		Priority: t.Priority, HpPenalty: t.HpPenalty, IsSkipped: t.IsSkipped,
		CreatedAt: t.CreatedAt, UpdatedAt: t.UpdatedAt,
	}
}

func fromProtoTask(t *taskv1.Task) *biz.Task {
	if t == nil {
		return nil
	}
	return &biz.Task{
		ID: t.Id, Title: t.Title, Description: t.Description,
		Type: taskTypeName(t.Type), Difficulty: difficultyName(t.Difficulty),
		Tags: append([]string{}, t.Tags...), IsCompleted: t.IsCompleted,
		CompletedAt: t.CompletedAt, DueDate: t.DueDate, RepeatDays: append([]int32{}, t.RepeatDays...),
		Streak: t.Streak, LastStreakDate: t.LastStreakDate,
		CustomExpReward: t.CustomExpReward, CustomGoldReward: t.CustomGoldReward,
		Priority: t.Priority, HpPenalty: t.HpPenalty, IsSkipped: t.IsSkipped,
		CreatedAt: t.CreatedAt, UpdatedAt: t.UpdatedAt,
	}
}

func toProtoShopItem(it *biz.ShopItem) *shopv1.ShopItem {
	if it == nil {
		return nil
	}
	return &shopv1.ShopItem{
		Id: it.ID, Name: it.Name, Description: it.Description, Price: it.Price,
		Slot: parseSlot(it.Slot), Rarity: parseRarity(it.Rarity),
	}
}

func toProtoAchievement(a *biz.Achievement) *achievementv1.Achievement {
	if a == nil {
		return nil
	}
	return &achievementv1.Achievement{
		Id: a.ID, Title: a.Title, Description: a.Description,
		ConditionType: a.ConditionType, Threshold: a.Threshold, Progress: a.Progress,
		IsUnlocked: a.IsUnlocked, UnlockedAt: a.UnlockedAt, GemReward: a.GemReward,
	}
}

func toProtoStats(s *biz.Stats) *statsv1.StatsReply {
	if s == nil {
		return nil
	}
	segs := make([]*statsv1.TimeSegment, 0, len(s.Segments))
	for _, seg := range s.Segments {
		segs = append(segs, &statsv1.TimeSegment{Label: seg.Label, CompletedCount: seg.CompletedCount})
	}
	streaks := make([]*statsv1.StreakEntry, 0, len(s.StreakLeaderboard))
	for _, e := range s.StreakLeaderboard {
		streaks = append(streaks, &statsv1.StreakEntry{TaskId: e.TaskID, Title: e.Title, Streak: e.Streak})
	}
	return &statsv1.StatsReply{
		Range: statsv1.StatsRange(s.Range), Segments: segs, StreakLeaderboard: streaks,
		TotalTasksCompleted: s.TotalTasksCompleted, TotalGoldEarned: s.TotalGoldEarned, TotalExpEarned: s.TotalExpEarned,
	}
}

func parseCharacterClass(s string) characterv1.CharacterClass {
	switch strings.ToLower(s) {
	case "warrior", "character_class_warrior", "1":
		return characterv1.CharacterClass_CHARACTER_CLASS_WARRIOR
	case "mage", "character_class_mage", "2":
		return characterv1.CharacterClass_CHARACTER_CLASS_MAGE
	case "ranger", "character_class_ranger", "3":
		return characterv1.CharacterClass_CHARACTER_CLASS_RANGER
	default:
		return characterv1.CharacterClass_CHARACTER_CLASS_UNSPECIFIED
	}
}

func characterClassName(c characterv1.CharacterClass) string {
	switch c {
	case characterv1.CharacterClass_CHARACTER_CLASS_WARRIOR:
		return "warrior"
	case characterv1.CharacterClass_CHARACTER_CLASS_MAGE:
		return "mage"
	case characterv1.CharacterClass_CHARACTER_CLASS_RANGER:
		return "ranger"
	default:
		return ""
	}
}

func parseTaskType(s string) taskv1.TaskType {
	switch strings.ToLower(s) {
	case "habit", "1":
		return taskv1.TaskType_TASK_TYPE_HABIT
	case "daily", "2":
		return taskv1.TaskType_TASK_TYPE_DAILY
	case "todo", "3":
		return taskv1.TaskType_TASK_TYPE_TODO
	default:
		return taskv1.TaskType_TASK_TYPE_UNSPECIFIED
	}
}

func taskTypeName(t taskv1.TaskType) string {
	switch t {
	case taskv1.TaskType_TASK_TYPE_HABIT:
		return "habit"
	case taskv1.TaskType_TASK_TYPE_DAILY:
		return "daily"
	case taskv1.TaskType_TASK_TYPE_TODO:
		return "todo"
	default:
		return ""
	}
}

func parseDifficulty(s string) taskv1.TaskDifficulty {
	switch strings.ToLower(s) {
	case "easy", "1":
		return taskv1.TaskDifficulty_TASK_DIFFICULTY_EASY
	case "medium", "2":
		return taskv1.TaskDifficulty_TASK_DIFFICULTY_MEDIUM
	case "hard", "3":
		return taskv1.TaskDifficulty_TASK_DIFFICULTY_HARD
	default:
		return taskv1.TaskDifficulty_TASK_DIFFICULTY_UNSPECIFIED
	}
}

func difficultyName(d taskv1.TaskDifficulty) string {
	switch d {
	case taskv1.TaskDifficulty_TASK_DIFFICULTY_EASY:
		return "easy"
	case taskv1.TaskDifficulty_TASK_DIFFICULTY_MEDIUM:
		return "medium"
	case taskv1.TaskDifficulty_TASK_DIFFICULTY_HARD:
		return "hard"
	default:
		return ""
	}
}

func parseSlot(s string) sharedv1.EquipmentSlot {
	switch strings.ToLower(s) {
	case "weapon":
		return sharedv1.EquipmentSlot_EQUIPMENT_SLOT_WEAPON
	case "helmet":
		return sharedv1.EquipmentSlot_EQUIPMENT_SLOT_HELMET
	case "armor":
		return sharedv1.EquipmentSlot_EQUIPMENT_SLOT_ARMOR
	case "accessory":
		return sharedv1.EquipmentSlot_EQUIPMENT_SLOT_ACCESSORY
	default:
		return sharedv1.EquipmentSlot_EQUIPMENT_SLOT_UNSPECIFIED
	}
}

func parseRarity(s string) sharedv1.EquipmentRarity {
	switch strings.ToLower(s) {
	case "rare":
		return sharedv1.EquipmentRarity_EQUIPMENT_RARITY_RARE
	case "epic":
		return sharedv1.EquipmentRarity_EQUIPMENT_RARITY_EPIC
	case "legendary":
		return sharedv1.EquipmentRarity_EQUIPMENT_RARITY_LEGENDARY
	default:
		return sharedv1.EquipmentRarity_EQUIPMENT_RARITY_COMMON
	}
}

func toBizStat(s characterv1.StatType) biz.StatType {
	return biz.StatType(s)
}
