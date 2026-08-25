package model

import "time"

type User struct {
	ID        string    `json:"id" gorm:"primaryKey;type:uuid;default:gen_random_uuid()"`
	Email     string    `json:"email" gorm:"uniqueIndex;not null"`
	Password  string    `json:"-" gorm:"not null"`
	Nickname  string    `json:"nickname" gorm:"default:''"`
	AvatarURL string    `json:"avatar_url" gorm:"default:''"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type AuthProvider struct {
	ID         string    `json:"id" gorm:"primaryKey;type:uuid;default:gen_random_uuid()"`
	UserID     string    `json:"user_id" gorm:"index;not null"`
	Provider   string    `json:"provider" gorm:"not null"` // "google" | "apple" | "email"
	ProviderID string    `json:"provider_id" gorm:"index"`
	CreatedAt  time.Time `json:"created_at"`
}
