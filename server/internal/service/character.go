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

// CreateCharacter creates the current user's character.
func (s *CharacterService) CreateCharacter(ctx context.Context, req *characterv1.CreateCharacterRequest) (*characterv1.CreateCharacterReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	c, err := s.uc.Create(ctx, uid, characterClassName(req.GetCharacterClass()))
	if err != nil {
		return nil, err
	}
	return &characterv1.CreateCharacterReply{Character: toProtoCharacter(c)}, nil
}

// GetCharacter returns the current user's character.
func (s *CharacterService) GetCharacter(ctx context.Context, req *characterv1.GetCharacterRequest) (*characterv1.GetCharacterReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	c, err := s.uc.Get(ctx, uid)
	if err != nil {
		return nil, err
	}
	return &characterv1.GetCharacterReply{Character: toProtoCharacter(c)}, nil
}

// UpdateCharacter replaces the character state.
func (s *CharacterService) UpdateCharacter(ctx context.Context, req *characterv1.UpdateCharacterRequest) (*characterv1.UpdateCharacterReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	c, err := s.uc.Update(ctx, uid, fromProtoCharacter(req.GetCharacter()))
	if err != nil {
		return nil, err
	}
	return &characterv1.UpdateCharacterReply{Character: toProtoCharacter(c)}, nil
}

// AllocateStatPoint spends one available stat point.
func (s *CharacterService) AllocateStatPoint(ctx context.Context, req *characterv1.AllocateStatPointRequest) (*characterv1.AllocateStatPointReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	c, err := s.uc.AllocateStatPoint(ctx, uid, toBizStat(req.GetStat()))
	if err != nil {
		return nil, err
	}
	return &characterv1.AllocateStatPointReply{Character: toProtoCharacter(c)}, nil
}

// Revive revives a dead character.
func (s *CharacterService) Revive(ctx context.Context, req *characterv1.ReviveRequest) (*characterv1.ReviveReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	c, err := s.uc.Revive(ctx, uid)
	if err != nil {
		return nil, err
	}
	return &characterv1.ReviveReply{Character: toProtoCharacter(c)}, nil
}

// EquipItem equips or unequips an item.
func (s *CharacterService) EquipItem(ctx context.Context, req *characterv1.EquipItemRequest) (*characterv1.EquipItemReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	if _, err := s.uc.Equip(ctx, uid, req.GetItemId(), int32(req.GetSlot())); err != nil {
		return nil, err
	}
	return &characterv1.EquipItemReply{}, nil
}
