package service

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/habitforge/backend/config"
	"github.com/habitforge/backend/internal/model"
	"github.com/habitforge/backend/internal/repository"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type AuthService struct {
	repo   *repository.UserRepository
	jwtCfg config.JWTConfig
}

func NewAuthService(repo *repository.UserRepository, jwtCfg config.JWTConfig) *AuthService {
	return &AuthService{repo: repo, jwtCfg: jwtCfg}
}

func (s *AuthService) Register(req *model.RegisterRequest) (*model.AuthResponse, error) {
	existing, _ := s.repo.FindByEmail(req.Email)
	if existing != nil {
		return nil, errors.New("email already registered")
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	user := &model.User{
		ID:       uuid.New().String(),
		Email:    req.Email,
		Password: string(hash),
		Nickname: req.Nickname,
	}
	if err := s.repo.Create(user); err != nil {
		return nil, err
	}

	token, err := s.generateToken(user.ID)
	if err != nil {
		return nil, err
	}

	// Link email auth provider
	s.repo.LinkProvider(&model.AuthProvider{
		ID:       uuid.New().String(),
		UserID:   user.ID,
		Provider: "email",
	})

	return &model.AuthResponse{Token: token, User: *user}, nil
}

func (s *AuthService) Login(req *model.LoginRequest) (*model.AuthResponse, error) {
	user, err := s.repo.FindByEmail(req.Email)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("invalid email or password")
		}
		return nil, err
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return nil, errors.New("invalid email or password")
	}

	token, err := s.generateToken(user.ID)
	if err != nil {
		return nil, err
	}

	return &model.AuthResponse{Token: token, User: *user}, nil
}

func (s *AuthService) OAuthLogin(req *model.OAuthLoginRequest) (*model.AuthResponse, error) {
	user, err := s.repo.FindByProvider(req.Provider, req.ProviderID)
	if err != nil {
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, err
		}
		// Auto-create user
		user = &model.User{
			ID:    uuid.New().String(),
			Email: req.Email,
		}
		if err := s.repo.Create(user); err != nil {
			return nil, err
		}
		s.repo.LinkProvider(&model.AuthProvider{
			ID:         uuid.New().String(),
			UserID:     user.ID,
			Provider:   req.Provider,
			ProviderID: req.ProviderID,
		})
	}

	token, err := s.generateToken(user.ID)
	if err != nil {
		return nil, err
	}

	return &model.AuthResponse{Token: token, User: *user}, nil
}

func (s *AuthService) ValidateToken(tokenStr string) (string, error) {
	token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) {
		return []byte(s.jwtCfg.Secret), nil
	})
	if err != nil {
		return "", err
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return "", errors.New("invalid token")
	}

	sub, _ := claims.GetSubject()
	return sub, nil
}

func (s *AuthService) generateToken(userID string) (string, error) {
	claims := jwt.MapClaims{
		"sub": userID,
		"iat": time.Now().Unix(),
		"exp": time.Now().Add(s.jwtCfg.ExpireTime).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.jwtCfg.Secret))
}
