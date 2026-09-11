package biz

import (
	"context"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"

	"github.com/habitforge/backend/internal/data"
	"github.com/habitforge/backend/internal/game"
	"github.com/habitforge/backend/internal/model"
)

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
	CharacterClass      string
	Level               int32
	CurrentExp          int64
	MaxExp              int64
	CurrentHp           int32
	BaseStats           CharacterStats
	AvailableStatPoints int32
	Equipment           map[string]string
	IsDead              bool
	DeathRecoveryUntil  int64
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
type CharacterUseCase struct {
	chars  *data.CharacterRepo
	prefs  *data.PrefsRepo
	tasks  *data.TaskRepo
	ach    *data.AchievementRepo
	shop   *data.ShopRepo
	data   *data.Data
}

// NewCharacterUseCase builds the character use case.
func NewCharacterUseCase(
	chars *data.CharacterRepo,
	prefs *data.PrefsRepo,
	tasks *data.TaskRepo,
	ach *data.AchievementRepo,
	shop *data.ShopRepo,
	d *data.Data,
) *CharacterUseCase {
	return &CharacterUseCase{chars: chars, prefs: prefs, tasks: tasks, ach: ach, shop: shop, data: d}
}

// Create creates a new character for the user.
func (uc *CharacterUseCase) Create(ctx context.Context, userID, class string) (*Character, error) {
	existing, err := uc.chars.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		return nil, conflict("Character already exists")
	}
	c := &model.Character{
		ID: uuid.NewString(), UserID: userID, CharacterClass: class,
		Level: 1, CurrentExp: 0, MaxExp: int64(game.ExpForLevel(1)),
		CurrentHp: int32(game.InitialHp), Equipment: model.StringMap{},
	}
	err = uc.data.InTx(ctx, func(tx *gorm.DB) error {
		if err := uc.chars.CreateTx(tx, c); err != nil {
			return err
		}
		p, err := uc.prefs.Get(ctx, userID)
		if err != nil {
			return err
		}
		p.CharactorClass = class
		return uc.prefs.SaveTx(tx, p)
	})
	if err != nil {
		return nil, err
	}
	return toBizCharacter(c), nil
}

// Get returns the current user's character (settles overdue + rollover).
func (uc *CharacterUseCase) Get(ctx context.Context, userID string) (*Character, error) {
	if err := settleDayForUser(ctx, uc.data, uc.chars, uc.prefs, uc.tasks, userID); err != nil {
		return nil, err
	}
	c, err := uc.chars.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if c == nil {
		return nil, notFound("Character not found")
	}
	return toBizCharacter(c), nil
}

// Update replaces the character state.
func (uc *CharacterUseCase) Update(ctx context.Context, userID string, c *Character) (*Character, error) {
	existing, err := uc.chars.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if existing == nil {
		return nil, notFound("Character not found")
	}
	applyCharacter(existing, c)
	if err := uc.chars.Save(ctx, existing); err != nil {
		return nil, err
	}
	return toBizCharacter(existing), nil
}

// AllocateStatPoint spends one available point on an attribute.
func (uc *CharacterUseCase) AllocateStatPoint(ctx context.Context, userID string, stat StatType) (*Character, error) {
	c, err := uc.chars.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if c == nil {
		return nil, notFound("Character not found")
	}
	if c.AvailableStatPoints <= 0 {
		return nil, failedPrecond("no available stat points")
	}
	gc := fromModelCharacter(c)
	gc = game.AllocateStat(gc, statName(stat))
	toModelCharacter(c, gc)
	if err := uc.chars.Save(ctx, c); err != nil {
		return nil, err
	}
	return toBizCharacter(c), nil
}

// Revive revives a dead character after the recovery timer.
func (uc *CharacterUseCase) Revive(ctx context.Context, userID string) (*Character, error) {
	var out *model.Character
	err := uc.data.InTx(ctx, func(tx *gorm.DB) error {
		c, err := uc.chars.GetByUserID(ctx, userID)
		if err != nil {
			return err
		}
		if c == nil {
			return notFound("Character not found")
		}
		if !c.IsDead {
			out = c
			return nil
		}
		if c.DeathRecoveryUntil > 0 && time.Now().UnixMilli() < c.DeathRecoveryUntil {
			return failedPrecond("still recovering")
		}
		gc := game.Revive(fromModelCharacter(c))
		toModelCharacter(c, gc)
		p, err := uc.prefs.Get(ctx, userID)
		if err != nil {
			return err
		}
		p.DeathCount++
		if err := applyUnlocks(ctx, tx, uc.data, uc.ach, uc.prefs, userID, p, c, 0, int(p.DeathCount)); err != nil {
			return err
		}
		if err := uc.chars.SaveTx(tx, c); err != nil {
			return err
		}
		out = c
		return nil
	})
	if err != nil {
		return nil, err
	}
	return toBizCharacter(out), nil
}

// Equip equips or unequips an item.
func (uc *CharacterUseCase) Equip(ctx context.Context, userID, itemID string, slot int32) (*Character, error) {
	c, err := uc.chars.GetByUserID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if c == nil {
		return nil, notFound("Character not found")
	}
	if itemID != "" {
		owns, err := uc.shop.Owns(ctx, userID, itemID)
		if err != nil {
			return nil, err
		}
		if !owns {
			return nil, failedPrecond("Item not owned")
		}
	}
	gc := fromModelCharacter(c)
	gc = game.Equip(gc, game.SlotKeyFromInt(slot), itemID)
	toModelCharacter(c, gc)
	if err := uc.chars.Save(ctx, c); err != nil {
		return nil, err
	}
	return toBizCharacter(c), nil
}

func statName(s StatType) string {
	switch s {
	case StatStrength:
		return "strength"
	case StatIntelligence:
		return "intelligence"
	case StatAgility:
		return "agility"
	case StatDefense:
		return "defense"
	case StatVitality:
		return "vitality"
	case StatLuck:
		return "luck"
	default:
		return ""
	}
}

func toBizCharacter(c *model.Character) *Character {
	eq := map[string]string{}
	for k, v := range c.Equipment {
		eq[k] = v
	}
	return &Character{
		ID: c.ID, CharacterClass: c.CharacterClass, Level: c.Level,
		CurrentExp: c.CurrentExp, MaxExp: c.MaxExp, CurrentHp: c.CurrentHp,
		BaseStats: CharacterStats{
			Strength: c.Strength, Intelligence: c.Intelligence, Agility: c.Agility,
			Defense: c.Defense, Vitality: c.Vitality, Luck: c.Luck,
		},
		AvailableStatPoints: c.AvailableStatPoints, Equipment: eq,
		IsDead: c.IsDead, DeathRecoveryUntil: c.DeathRecoveryUntil,
	}
}

func applyCharacter(dst *model.Character, src *Character) {
	if src == nil {
		return
	}
	dst.CharacterClass = src.CharacterClass
	dst.Level = src.Level
	dst.CurrentExp = src.CurrentExp
	dst.MaxExp = src.MaxExp
	dst.CurrentHp = src.CurrentHp
	dst.Strength = src.BaseStats.Strength
	dst.Intelligence = src.BaseStats.Intelligence
	dst.Agility = src.BaseStats.Agility
	dst.Defense = src.BaseStats.Defense
	dst.Vitality = src.BaseStats.Vitality
	dst.Luck = src.BaseStats.Luck
	dst.AvailableStatPoints = src.AvailableStatPoints
	dst.Equipment = model.StringMap(src.Equipment)
	dst.IsDead = src.IsDead
	dst.DeathRecoveryUntil = src.DeathRecoveryUntil
}

func fromModelCharacter(c *model.Character) game.Character {
	eq := map[string]string{}
	for k, v := range c.Equipment {
		eq[k] = v
	}
	return game.Character{
		ID: c.ID, CharacterClass: c.CharacterClass, Level: int(c.Level),
		CurrentExp: c.CurrentExp, MaxExp: c.MaxExp, CurrentHp: int(c.CurrentHp),
		BaseStats: game.Stats{
			Strength: int(c.Strength), Intelligence: int(c.Intelligence), Agility: int(c.Agility),
			Defense: int(c.Defense), Vitality: int(c.Vitality), Luck: int(c.Luck),
		},
		AvailableStatPoints: int(c.AvailableStatPoints), Equipment: eq,
		IsDead: c.IsDead, DeathRecoveryUntil: c.DeathRecoveryUntil,
	}
}

func toModelCharacter(dst *model.Character, src game.Character) {
	dst.Level = int32(src.Level)
	dst.CurrentExp = src.CurrentExp
	dst.MaxExp = src.MaxExp
	dst.CurrentHp = int32(src.CurrentHp)
	dst.Strength = int32(src.BaseStats.Strength)
	dst.Intelligence = int32(src.BaseStats.Intelligence)
	dst.Agility = int32(src.BaseStats.Agility)
	dst.Defense = int32(src.BaseStats.Defense)
	dst.Vitality = int32(src.BaseStats.Vitality)
	dst.Luck = int32(src.BaseStats.Luck)
	dst.AvailableStatPoints = int32(src.AvailableStatPoints)
	dst.Equipment = model.StringMap(src.Equipment)
	dst.IsDead = src.IsDead
	dst.DeathRecoveryUntil = src.DeathRecoveryUntil
}
