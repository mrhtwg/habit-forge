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

// ── Request/Response DTOs ──

type RegisterRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=8"`
	Nickname string `json:"nickname"`
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

type OAuthLoginRequest struct {
	Provider   string `json:"provider" binding:"required"` // "google" | "apple"
	ProviderID string `json:"provider_id" binding:"required"`
	Email      string `json:"email"`
	Nickname   string `json:"nickname"`
}

type AuthResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

type ErrorResponse struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}
