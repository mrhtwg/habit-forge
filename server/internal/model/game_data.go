package model

import "time"

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
