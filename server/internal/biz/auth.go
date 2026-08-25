package biz

import "context"

// User is the domain user entity.
type User struct {
	ID        string
	Email     string
	Nickname  string
	AvatarURL string
}

// AuthUseCase handles authentication: register / login / oauth / me.
type AuthUseCase struct{}

// NewAuthUseCase builds the auth use case.
func NewAuthUseCase() *AuthUseCase { return &AuthUseCase{} }

// Register creates an account and returns a JWT. No email verification required.
func (uc *AuthUseCase) Register(ctx context.Context, email, password, nickname string) (token string, user *User, err error) {
	return "", nil, ErrNotImplemented // TODO: hash password, create user, issue JWT
}

// Login validates credentials and returns a JWT.
func (uc *AuthUseCase) Login(ctx context.Context, email, password string) (token string, user *User, err error) {
	return "", nil, ErrNotImplemented // TODO: verify password, issue JWT
}

// OAuthLogin logs in or auto-creates a user for a provider account.
func (uc *AuthUseCase) OAuthLogin(ctx context.Context, provider, providerID, email, nickname string) (token string, user *User, err error) {
	return "", nil, ErrNotImplemented // TODO: find-or-create by provider, issue JWT
}

// Me returns the current authenticated user.
func (uc *AuthUseCase) Me(ctx context.Context, userID string) (*User, error) {
	return nil, ErrNotImplemented // TODO: load user by id
}
