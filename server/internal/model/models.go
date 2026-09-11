package model

import (
	"database/sql/driver"
	"encoding/json"
	"fmt"
	"time"
)

// StringMap is a JSON object map[string]string stored in PostgreSQL JSONB.
type StringMap map[string]string

func (m StringMap) Value() (driver.Value, error) {
	if m == nil {
		return []byte("{}"), nil
	}
	return json.Marshal(m)
}

func (m *StringMap) Scan(src any) error {
	if src == nil {
		*m = StringMap{}
		return nil
	}
	var b []byte
	switch v := src.(type) {
	case []byte:
		b = v
	case string:
		b = []byte(v)
	default:
		return fmt.Errorf("StringMap: unsupported type %T", src)
	}
	if len(b) == 0 {
		*m = StringMap{}
		return nil
	}
	return json.Unmarshal(b, m)
}

// StringSlice is a JSON string array.
type StringSlice []string

func (s StringSlice) Value() (driver.Value, error) {
	if s == nil {
		return []byte("[]"), nil
	}
	return json.Marshal(s)
}

func (s *StringSlice) Scan(src any) error {
	if src == nil {
		*s = StringSlice{}
		return nil
	}
	var b []byte
	switch v := src.(type) {
	case []byte:
		b = v
	case string:
		b = []byte(v)
	default:
		return fmt.Errorf("StringSlice: unsupported type %T", src)
	}
	if len(b) == 0 {
		*s = StringSlice{}
		return nil
	}
	return json.Unmarshal(b, s)
}

// Int32Slice is a JSON int32 array (repeat_days).
type Int32Slice []int32

func (s Int32Slice) Value() (driver.Value, error) {
	if s == nil {
		return []byte("[]"), nil
	}
	return json.Marshal(s)
}

func (s *Int32Slice) Scan(src any) error {
	if src == nil {
		*s = Int32Slice{}
		return nil
	}
	var b []byte
	switch v := src.(type) {
	case []byte:
		b = v
	case string:
		b = []byte(v)
	default:
		return fmt.Errorf("Int32Slice: unsupported type %T", src)
	}
	if len(b) == 0 {
		*s = Int32Slice{}
		return nil
	}
	return json.Unmarshal(b, s)
}

// User is an account row.
type User struct {
	ID        string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	Email     string    `gorm:"uniqueIndex;not null" json:"email"`
	Password  string    `gorm:"not null;default:''" json:"-"` // empty OK for OAuth-only
	Nickname  string    `gorm:"default:''" json:"nickname"`
	AvatarURL string    `gorm:"default:''" json:"avatar_url"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func (User) TableName() string { return "users" }

// AuthProvider links a third-party identity to a user.
type AuthProvider struct {
	ID         string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	UserID     string    `gorm:"index;not null" json:"user_id"`
	Provider   string    `gorm:"not null" json:"provider"` // google | apple | email
	ProviderID string    `gorm:"index" json:"provider_id"`
	CreatedAt  time.Time `json:"created_at"`
}

func (AuthProvider) TableName() string { return "auth_providers" }

// UserPrefs is wallet + preferences. LastPenaltyDate is unix millis of last
// overdue HP settlement calendar day (dateOnly millis).
type UserPrefs struct {
	UserID               string    `gorm:"primaryKey;type:uuid" json:"user_id"`
	CharactorClass       string    `gorm:"default:''" json:"charactor_class"`
	CurrentGold          int64     `gorm:"default:0" json:"current_gold"`
	CurrentGems          int64     `gorm:"default:0" json:"current_gems"`
	NotificationsEnabled bool      `gorm:"default:true" json:"notifications_enabled"`
	SoundEnabled         bool      `gorm:"default:true" json:"sound_enabled"`
	HapticEnabled        bool      `gorm:"default:true" json:"haptic_enabled"`
	OnboardingCompleted  bool      `gorm:"default:false" json:"onboarding_completed"`
	LastOnboardingStep   int32     `gorm:"default:0" json:"last_onboarding_step"`
	TotalTasksCompleted  int64     `gorm:"default:0" json:"total_tasks_completed"`
	TotalTasks           int64     `gorm:"default:0" json:"total_tasks"`
	TodayTasksCompleted  int64     `gorm:"default:0" json:"today_tasks_completed"`
	TodayTasks           int64     `gorm:"default:0" json:"today_tasks"`
	FirstTaskDate        int64     `gorm:"default:0" json:"first_task_date"`
	LastPenaltyDate      int64     `gorm:"default:0" json:"last_penalty_date"` // dateOnly millis
	LastActiveDate       int64     `gorm:"default:0" json:"last_active_date"`  // dateOnly millis for today reset
	DeathCount           int64     `gorm:"default:0" json:"death_count"`
	UpdatedAt            time.Time `json:"updated_at"`
}

func (UserPrefs) TableName() string { return "user_prefs" }

// Character is the user's RPG character.
type Character struct {
	ID                  string    `gorm:"primaryKey;type:uuid" json:"id"`
	UserID              string    `gorm:"uniqueIndex;not null" json:"user_id"`
	CharacterClass      string    `gorm:"not null;default:''" json:"character_class"`
	Level               int32     `gorm:"default:1" json:"level"`
	CurrentExp          int64     `gorm:"default:0" json:"current_exp"`
	MaxExp              int64     `gorm:"default:100" json:"max_exp"`
	CurrentHp           int32     `gorm:"default:100" json:"current_hp"`
	Strength            int32     `gorm:"default:0" json:"strength"`
	Intelligence        int32     `gorm:"default:0" json:"intelligence"`
	Agility             int32     `gorm:"default:0" json:"agility"`
	Defense             int32     `gorm:"default:0" json:"defense"`
	Vitality            int32     `gorm:"default:0" json:"vitality"`
	Luck                int32     `gorm:"default:0" json:"luck"`
	AvailableStatPoints int32     `gorm:"default:0" json:"available_stat_points"`
	Equipment           StringMap `gorm:"type:jsonb;default:'{}'" json:"equipment"`
	IsDead              bool      `gorm:"default:false" json:"is_dead"`
	DeathRecoveryUntil  int64     `gorm:"default:0" json:"death_recovery_until"`
	CreatedAt           time.Time `json:"created_at"`
	UpdatedAt           time.Time `json:"updated_at"`
}

func (Character) TableName() string { return "characters" }

// Task is a habit/daily/todo owned by a user.
type Task struct {
	ID               string      `gorm:"primaryKey;type:uuid" json:"id"`
	UserID           string      `gorm:"index;not null" json:"user_id"`
	Title            string      `gorm:"not null" json:"title"`
	Description      string      `gorm:"default:''" json:"description"`
	Type             string      `gorm:"not null" json:"type"`                      // habit | daily | todo
	Difficulty       string      `gorm:"not null;default:'easy'" json:"difficulty"` // easy | medium | hard
	Tags             StringSlice `gorm:"type:jsonb;default:'[]'" json:"tags"`
	IsCompleted      bool        `gorm:"default:false" json:"is_completed"`
	CompletedAt      int64       `gorm:"default:0" json:"completed_at"`
	DueDate          int64       `gorm:"default:0" json:"due_date"`
	RepeatDays       Int32Slice  `gorm:"type:jsonb;default:'[]'" json:"repeat_days"`
	Streak           int32       `gorm:"default:0" json:"streak"`
	LastStreakDate   int64       `gorm:"default:0" json:"last_streak_date"`
	CustomExpReward  int32       `gorm:"default:0" json:"custom_exp_reward"`
	CustomGoldReward int32       `gorm:"default:0" json:"custom_gold_reward"`
	Priority         string      `gorm:"default:''" json:"priority"`
	HpPenalty        int32       `gorm:"default:0" json:"hp_penalty"`
	IsSkipped        bool        `gorm:"default:false" json:"is_skipped"`
	CreatedAtMillis  int64       `gorm:"default:0" json:"created_at_millis"`
	UpdatedAtMillis  int64       `gorm:"default:0" json:"updated_at_millis"`
	CreatedAt        time.Time   `json:"created_at"`
	UpdatedAt        time.Time   `json:"updated_at"`
}

func (Task) TableName() string { return "tasks" }

// OwnedItem is a shop item owned by a user.
type OwnedItem struct {
	ID        string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	UserID    string    `gorm:"index;not null;uniqueIndex:uid_item" json:"user_id"`
	ItemID    string    `gorm:"not null;uniqueIndex:uid_item" json:"item_id"`
	CreatedAt time.Time `json:"created_at"`
}

func (OwnedItem) TableName() string { return "owned_items" }

// UserAchievement is an unlocked achievement for a user.
type UserAchievement struct {
	ID         string    `gorm:"primaryKey;type:uuid;default:gen_random_uuid()" json:"id"`
	UserID     string    `gorm:"index;not null;uniqueIndex:uid_achieve" json:"user_id"`
	AchieveID  string    `gorm:"not null;uniqueIndex:uid_achieve" json:"achieve_id"`
	UnlockedAt int64     `gorm:"not null" json:"unlocked_at"`
	CreatedAt  time.Time `json:"created_at"`
}

func (UserAchievement) TableName() string { return "user_achievements" }

// ShopItem is a catalog shop item persisted in DB.
type ShopItem struct {
	ID          string `gorm:"primaryKey" json:"id"`
	Name        string `gorm:"not null" json:"name"`
	Description string `gorm:"default:''" json:"description"`
	Price       int64  `gorm:"not null" json:"price"`
	Slot        string `gorm:"default:''" json:"slot"`
	Rarity      string `gorm:"default:'common'" json:"rarity"`
	Currency    string `gorm:"default:'gold'" json:"currency"` // gold | gems
	Icon        string `gorm:"default:''" json:"icon"`
	Category    string `gorm:"default:'equipment'" json:"category"`
	StatStr     int32  `gorm:"default:0" json:"stat_str"`
	StatInt     int32  `gorm:"default:0" json:"stat_int"`
	StatAgi     int32  `gorm:"default:0" json:"stat_agi"`
	StatDef     int32  `gorm:"default:0" json:"stat_def"`
	StatVit     int32  `gorm:"default:0" json:"stat_vit"`
	StatLuk     int32  `gorm:"default:0" json:"stat_luk"`
}

func (ShopItem) TableName() string { return "shop_items" }

// AchievementDef is a catalog achievement definition.
type AchievementDef struct {
	ID            string `gorm:"primaryKey" json:"id"`
	Title         string `gorm:"not null" json:"title"`
	Description   string `gorm:"default:''" json:"description"`
	ConditionType string `gorm:"not null" json:"condition_type"`
	Threshold     int32  `gorm:"not null" json:"threshold"`
	GemReward     int32  `gorm:"default:0" json:"gem_reward"`
}

func (AchievementDef) TableName() string { return "achievement_defs" }

// GameConstant is a key-value game constant seed row.
type GameConstant struct {
	Key   string `gorm:"primaryKey" json:"key"`
	Value string `gorm:"not null" json:"value"`
}

func (GameConstant) TableName() string { return "game_constants" }
