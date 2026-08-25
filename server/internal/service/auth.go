package service

import (
	"context"

	authv1 "github.com/habitforge/backend/api/auth/v1"
	"github.com/habitforge/backend/internal/biz"
)

// AuthService implements the AuthService interface (HTTP + gRPC).
type AuthService struct {
	authv1.UnimplementedAuthServiceServer
	uc *biz.AuthUseCase
}

// NewAuthService builds the auth service.
func NewAuthService(uc *biz.AuthUseCase) *AuthService {
	return &AuthService{uc: uc}
}

// Register creates an account. No email verification required.
// TODO(implementation): delegate to s.uc.Register.
func (s *AuthService) Register(ctx context.Context, req *authv1.RegisterRequest) (*authv1.RegisterReply, error) {
	return nil, errNotImplemented()
}

// Login authenticates with email/password.
// TODO(implementation): delegate to s.uc.Login.
func (s *AuthService) Login(ctx context.Context, req *authv1.LoginRequest) (*authv1.LoginReply, error) {
	return nil, errNotImplemented()
}

// OAuthLogin logs in or auto-creates a user via a provider.
// TODO(implementation): delegate to s.uc.OAuthLogin.
func (s *AuthService) OAuthLogin(ctx context.Context, req *authv1.OAuthLoginRequest) (*authv1.LoginReply, error) {
	return nil, errNotImplemented()
}

// Me returns the current user from the JWT subject.
// TODO(implementation): read user id from ctx (middleware.UserIDFromContext), delegate to s.uc.Me.
func (s *AuthService) Me(ctx context.Context, req *authv1.MeRequest) (*authv1.MeReply, error) {
	return nil, errNotImplemented()
}
