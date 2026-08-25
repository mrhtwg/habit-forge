package biz

import "context"

// CharacterStats is the six-attribute stat block.
type CharacterStats struct {
	Strength     int32
	Intelligence int32
	Agility      int32
	Defense      int32
	Vitality     int32
	Luck         int32
}

// Character is the domain character entity.
type Character struct {
	ID                  string
	CharacterClass      string // warrior | mage | ranger
	Level               int32
	CurrentExp          int64
	CurrentHp           int32
	BaseStats           CharacterStats
	AvailableStatPoints int32
	Equipment           map[string]string // slot -> shop item id
	IsDead              bool
	DeathRecoveryUntil  int64 // unix millis
}

// StatType enumerates the allocatable attributes.
type StatType int32

// Allocatable attributes.
const (
	StatStrength StatType = iota + 1
	StatIntelligence
	StatAgility
	StatDefense
	StatVitality
	StatLuck
)

// CharacterUseCase handles the RPG character state.
type CharacterUseCase struct{}

// NewCharacterUseCase builds the character use case.
func NewCharacterUseCase() *CharacterUseCase { return &CharacterUseCase{} }

// Get returns the current user's character.
func (uc *CharacterUseCase) Get(ctx context.Context, userID string) (*Character, error) {
	return nil, ErrNotImplemented // TODO
}

// Update replaces the character state.
func (uc *CharacterUseCase) Update(ctx context.Context, userID string, c *Character) (*Character, error) {
	return nil, ErrNotImplemented // TODO
}

// AllocateStatPoint spends one available point on an attribute.
func (uc *CharacterUseCase) AllocateStatPoint(ctx context.Context, userID string, stat StatType) (*Character, error) {
	return nil, ErrNotImplemented // TODO
}

// Revive revives a dead character (e.g. after the recovery timer).
func (uc *CharacterUseCase) Revive(ctx context.Context, userID string) (*Character, error) {
	return nil, ErrNotImplemented // TODO
}
