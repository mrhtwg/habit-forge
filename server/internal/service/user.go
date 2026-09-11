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
func (s *UserService) GetPrefs(ctx context.Context, req *userv1.GetPrefsRequest) (*userv1.GetPrefsReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	prefs, err := s.uc.GetPrefs(ctx, uid)
	if err != nil {
		return nil, err
	}
	return &userv1.GetPrefsReply{Prefs: toProtoPrefs(prefs)}, nil
}

// UpdatePrefs saves the current user's preferences and wallet.
func (s *UserService) UpdatePrefs(ctx context.Context, req *userv1.UpdatePrefsRequest) (*userv1.UpdatePrefsReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	prefs, err := s.uc.UpdatePrefs(ctx, uid, fromProtoPrefs(req.GetPrefs()))
	if err != nil {
		return nil, err
	}
	return &userv1.UpdatePrefsReply{Prefs: toProtoPrefs(prefs)}, nil
}
