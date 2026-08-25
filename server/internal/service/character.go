package service

import (
	"context"

	characterv1 "github.com/habitforge/backend/api/character/v1"
	"github.com/habitforge/backend/internal/biz"
)

// CharacterService implements the CharacterService interface (HTTP + gRPC).
type CharacterService struct {
	characterv1.UnimplementedCharacterServiceServer
	uc *biz.CharacterUseCase
}

// NewCharacterService builds the character service.
func NewCharacterService(uc *biz.CharacterUseCase) *CharacterService {
	return &CharacterService{uc: uc}
}

// GetCharacter returns the current user's character.
// TODO(implementation): delegate to s.uc.Get.
func (s *CharacterService) GetCharacter(ctx context.Context, req *characterv1.GetCharacterRequest) (*characterv1.GetCharacterReply, error) {
	return nil, errNotImplemented()
}

// UpdateCharacter replaces the character state.
// TODO(implementation): delegate to s.uc.Update.
func (s *CharacterService) UpdateCharacter(ctx context.Context, req *characterv1.UpdateCharacterRequest) (*characterv1.UpdateCharacterReply, error) {
	return nil, errNotImplemented()
}

// AllocateStatPoint spends one available stat point.
// TODO(implementation): delegate to s.uc.AllocateStatPoint.
func (s *CharacterService) AllocateStatPoint(ctx context.Context, req *characterv1.AllocateStatPointRequest) (*characterv1.AllocateStatPointReply, error) {
	return nil, errNotImplemented()
}

// Revive revives a dead character.
// TODO(implementation): delegate to s.uc.Revive.
func (s *CharacterService) Revive(ctx context.Context, req *characterv1.ReviveRequest) (*characterv1.ReviveReply, error) {
	return nil, errNotImplemented()
}
