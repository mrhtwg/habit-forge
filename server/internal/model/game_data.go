package model

import "time"

// ── Character ──

type Character struct {
	ID                 string `json:"id" gorm:"primaryKey"`
	UserID             string `json:"user_id" gorm:"uniqueIndex;not null"`
	CharacterClass     string `json:"character_class"` // warrior | mage | ranger
	Level              int    `json:"level"`
	CurrentExp         int    `json:"current_exp"`
	CurrentHp          int    `json:"current_hp"`
	AvailableStatPoint int    `json:"available_stat_point"`
	Strength           int    `json:"strength"`
	Intelligence       int    `json:"intelligence"`
	Agility            int    `json:"agility"`
	Defense            int    `json:"defense"`
	Vitality           int    `json:"vitality"`
	Luck               int    `json:"luck"`
	IsDead             bool   `json:"is_dead"`
	DeathRecoveryUntil *time.Time `json:"death_recovery_until,omitempty"`
	CreatedAt          time.Time `json:"created_at"`
	UpdatedAt          time.Time `json:"updated_at"`
}

// ── Task ──

type Task struct {
	ID              string    `json:"id" gorm:"primaryKey"`
	UserID          string    `json:"user_id" gorm:"index;not null"`
	Title           string    `json:"title" gorm:"not null"`
	Description     string    `json:"description"`
	Type            string    `json:"type"`       // habit | daily | todo
	Difficulty      string    `json:"difficulty"` // easy | medium | hard
	Tags            string    `json:"tags" gorm:"type:text"` // JSON array
	IsCompleted     bool      `json:"is_completed"`
	CompletedAt     *time.Time `json:"completed_at,omitempty"`
	DueDate         *time.Time `json:"due_date,omitempty"`
	RepeatDays      string    `json:"repeat_days" gorm:"type:text"` // JSON array
	Streak          int       `json:"streak"`
	LastStreakDate  *time.Time `json:"last_streak_date,omitempty"`
	CustomExpReward int       `json:"custom_exp_reward"`
	CustomGoldReward int      `json:"custom_gold_reward"`
	HpPenalty       int       `json:"hp_penalty"`
	IsSkipped       bool      `json:"is_skipped"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
	DeletedAt       *time.Time `json:"deleted_at,omitempty" gorm:"index"`
}

// ── Shop & Achievement ──

type OwnedItem struct {
	ID        string    `json:"id" gorm:"primaryKey"`
	UserID    string    `json:"user_id" gorm:"index;not null"`
	ItemID    string    `json:"item_id" gorm:"not null"`
	CreatedAt time.Time `json:"created_at"`
}

type Achievement struct {
	ID         string    `json:"id" gorm:"primaryKey"`
	UserID     string    `json:"user_id" gorm:"index;not null"`
	AchieveID  string    `json:"achieve_id" gorm:"not null"`
	UnlockedAt time.Time `json:"unlocked_at"`
}
