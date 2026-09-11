package biz

import (
	"context"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"

	"github.com/habitforge/backend/internal/conf"
	"github.com/habitforge/backend/internal/data"
	"github.com/habitforge/backend/internal/model"
)

// User is the domain user entity.
type User struct {
	ID        string
	Email     string
	Nickname  string
	AvatarURL string
	CreatedAt int64
	UpdatedAt int64
}

// AuthUseCase handles authentication: register / login / oauth / me.
type AuthUseCase struct {
	users *data.UserRepo
	jwt   *conf.JWT
}

// NewAuthUseCase builds the auth use case.
func NewAuthUseCase(users *data.UserRepo, jwtCfg *conf.JWT) *AuthUseCase {
	return &AuthUseCase{users: users, jwt: jwtCfg}
}

// Register creates an account and returns a JWT. No email verification required.
func (uc *AuthUseCase) Register(ctx context.Context, email, password, nickname string) (token string, user *User, err error) {
	email = strings.TrimSpace(strings.ToLower(email))
	if email == "" || len(password) < 8 {
		return "", nil, badRequest("email required and password min 8 characters")
	}
	existing, err := uc.users.FindByEmail(ctx, email)
	if err != nil {
		return "", nil, err
	}
	if existing != nil {
		return "", nil, conflict("email already registered")
	}
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", nil, err
	}
	u := &model.User{
		ID: uuid.NewString(), Email: email, Password: string(hash), Nickname: nickname,
	}
	if err := uc.users.CreateWithPrefs(ctx, u, &model.AuthProvider{
		Provider: "email", ProviderID: email,
	}); err != nil {
		return "", nil, err
	}
	tok, err := uc.issueToken(u.ID)
	if err != nil {
		return "", nil, err
	}
	return tok, toBizUser(u), nil
}

// Login validates credentials and returns a JWT.
func (uc *AuthUseCase) Login(ctx context.Context, email, password string) (token string, user *User, err error) {
	email = strings.TrimSpace(strings.ToLower(email))
	u, err := uc.users.FindByEmail(ctx, email)
	if err != nil {
		return "", nil, err
	}
	if u == nil || u.Password == "" {
		return "", nil, unauthorized("invalid credentials")
	}
	if err := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(password)); err != nil {
		return "", nil, unauthorized("invalid credentials")
	}
	tok, err := uc.issueToken(u.ID)
	if err != nil {
		return "", nil, err
	}
	return tok, toBizUser(u), nil
}

// OAuthLogin logs in or auto-creates a user for a provider account.
func (uc *AuthUseCase) OAuthLogin(ctx context.Context, provider, providerID, email, nickname string) (token string, user *User, err error) {
	provider = strings.TrimSpace(strings.ToLower(provider))
	providerID = strings.TrimSpace(providerID)
	if provider == "" || providerID == "" {
		return "", nil, badRequest("provider and provider_id required")
	}
	u, err := uc.users.FindByProvider(ctx, provider, providerID)
	if err != nil {
		return "", nil, err
	}
	if u == nil {
		email = strings.TrimSpace(strings.ToLower(email))
		if email == "" {
			email = provider + "_" + providerID + "@oauth.local"
		}
		// Prefer existing email account if present.
		if existing, err := uc.users.FindByEmail(ctx, email); err != nil {
			return "", nil, err
		} else if existing != nil {
			u = existing
			_ = uc.users.AddProvider(ctx, &model.AuthProvider{
				UserID: u.ID, Provider: provider, ProviderID: providerID,
			})
		} else {
			u = &model.User{
				ID: uuid.NewString(), Email: email, Password: "", Nickname: nickname,
			}
			if err := uc.users.CreateWithPrefs(ctx, u, &model.AuthProvider{
				Provider: provider, ProviderID: providerID,
			}); err != nil {
				return "", nil, err
			}
		}
	}
	tok, err := uc.issueToken(u.ID)
	if err != nil {
		return "", nil, err
	}
	return tok, toBizUser(u), nil
}

// Me returns the current authenticated user.
func (uc *AuthUseCase) Me(ctx context.Context, userID string) (*User, error) {
	if userID == "" {
		return nil, unauthorized("unauthorized")
	}
	u, err := uc.users.FindByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if u == nil {
		return nil, notFound("user not found")
	}
	return toBizUser(u), nil
}

func (uc *AuthUseCase) issueToken(userID string) (string, error) {
	claims := jwt.RegisteredClaims{
		Subject:   userID,
		ExpiresAt: jwt.NewNumericDate(time.Now().Add(uc.jwt.ExpireTime)),
		IssuedAt:  jwt.NewNumericDate(time.Now()),
	}
	t := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return t.SignedString([]byte(uc.jwt.Secret))
}

func toBizUser(u *model.User) *User {
	return &User{
		ID: u.ID, Email: u.Email, Nickname: u.Nickname, AvatarURL: u.AvatarURL,
		CreatedAt: u.CreatedAt.UnixMilli(), UpdatedAt: u.UpdatedAt.UnixMilli(),
	}
}
