package service

import (
	"context"

	"github.com/google/wire"

	authv1 "github.com/habitforge/backend/api/auth/v1"
	"github.com/habitforge/backend/internal/biz"
	"github.com/habitforge/backend/internal/middleware"
)

// ProviderSet is the service layer DI provider.
var ProviderSet = wire.NewSet(
	NewAuthService,
	NewUserService,
	NewCharacterService,
	NewTaskService,
	NewShopService,
	NewAchievementService,
	NewStatsService,
)

func requireUserID(ctx context.Context) (string, error) {
	id := middleware.UserIDFromContext(ctx)
	if id == "" {
		return "", middleware.ErrUnauthorized
	}
	return id, nil
}

// AuthService implements the AuthService interface (HTTP + gRPC).
type AuthService struct {
	authv1.UnimplementedAuthServiceServer
	uc *biz.AuthUseCase
}

// NewAuthService builds the auth service.
func NewAuthService(uc *biz.AuthUseCase) *AuthService {
	return &AuthService{uc: uc}
}

// Register creates an account.
func (s *AuthService) Register(ctx context.Context, req *authv1.RegisterRequest) (*authv1.RegisterReply, error) {
	tok, user, err := s.uc.Register(ctx, req.GetEmail(), req.GetPassword(), req.GetNickname())
	if err != nil {
		return nil, err
	}
	return &authv1.RegisterReply{Token: tok, User: toProtoUser(user)}, nil
}

// Login authenticates with email/password.
func (s *AuthService) Login(ctx context.Context, req *authv1.LoginRequest) (*authv1.LoginReply, error) {
	tok, user, err := s.uc.Login(ctx, req.GetEmail(), req.GetPassword())
	if err != nil {
		return nil, err
	}
	return &authv1.LoginReply{Token: tok, User: toProtoUser(user)}, nil
}

// OAuthLogin logs in or auto-creates a user via a provider.
func (s *AuthService) OAuthLogin(ctx context.Context, req *authv1.OAuthLoginRequest) (*authv1.LoginReply, error) {
	tok, user, err := s.uc.OAuthLogin(ctx, req.GetProvider(), req.GetProviderId(), req.GetEmail(), req.GetNickname())
	if err != nil {
		return nil, err
	}
	return &authv1.LoginReply{Token: tok, User: toProtoUser(user)}, nil
}

// Me returns the current user from the JWT subject.
func (s *AuthService) Me(ctx context.Context, req *authv1.MeRequest) (*authv1.MeReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	user, err := s.uc.Me(ctx, uid)
	if err != nil {
		return nil, err
	}
	return &authv1.MeReply{User: toProtoUser(user)}, nil
}
