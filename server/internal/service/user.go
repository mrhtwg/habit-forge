package service

import (
	"context"

	userv1 "github.com/habitforge/backend/api/user/v1"
	"github.com/habitforge/backend/internal/biz"
)

// UserService implements the UserService interface (HTTP + gRPC).
type UserService struct {
	userv1.UnimplementedUserServiceServer
	uc *biz.UserUseCase
}

// NewUserService builds the user service.
func NewUserService(uc *biz.UserUseCase) *UserService {
	return &UserService{uc: uc}
}

// GetPrefs returns the current user's preferences and wallet.
// TODO(implementation): delegate to s.uc.GetPrefs.
func (s *UserService) GetPrefs(ctx context.Context, req *userv1.GetPrefsRequest) (*userv1.GetPrefsReply, error) {
	return nil, errNotImplemented()
}

// UpdatePrefs saves the current user's preferences and wallet.
// TODO(implementation): delegate to s.uc.UpdatePrefs.
func (s *UserService) UpdatePrefs(ctx context.Context, req *userv1.UpdatePrefsRequest) (*userv1.UpdatePrefsReply, error) {
	return nil, errNotImplemented()
}
