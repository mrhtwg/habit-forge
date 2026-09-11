package biz

import (
	"context"
	"time"

	"gorm.io/gorm"

	"github.com/habitforge/backend/internal/data"
	"github.com/habitforge/backend/internal/model"
)

// ShopItem is the domain shop item entity.
type ShopItem struct {
	ID          string
	Name        string
	Description string
	Price       int64
	Category    string // weapon | helmet | armor | accessory
	Rarity      string
	Currency    string // gold | gems
	Slot        string
	IsOwned     bool
	StatStr     int32
	StatInt     int32
	StatAgi     int32
	StatDef     int32
	StatVit     int32
	StatLuk     int32
}

// DailyDeal is the rotating discounted item.
type DailyDeal struct {
	ItemID          string
	DiscountPercent int32
	ExpiresAt       int64
}

// ShopUseCase handles the forge shop.
type ShopUseCase struct {
	shop  *data.ShopRepo
	prefs *data.PrefsRepo
	chars *data.CharacterRepo
	ach   *data.AchievementRepo
	data  *data.Data
}

// NewShopUseCase builds the shop use case.
func NewShopUseCase(
	shop *data.ShopRepo,
	prefs *data.PrefsRepo,
	chars *data.CharacterRepo,
	ach *data.AchievementRepo,
	d *data.Data,
) *ShopUseCase {
	return &ShopUseCase{shop: shop, prefs: prefs, chars: chars, ach: ach, data: d}
}

// ListItems returns purchasable items, optionally filtered by category.
func (uc *ShopUseCase) ListItems(ctx context.Context, userID, category string) ([]*ShopItem, error) {
	items, err := uc.shop.ListItems(ctx, category)
	if err != nil {
		return nil, err
	}
	owned := map[string]struct{}{}
	if userID != "" {
		ids, err := uc.shop.ListOwnedIDs(ctx, userID)
		if err != nil {
			return nil, err
		}
		for _, id := range ids {
			owned[id] = struct{}{}
		}
	}
	out := make([]*ShopItem, 0, len(items))
	for _, it := range items {
		_, isOwned := owned[it.ID]
		out = append(out, toBizShopItem(it, isOwned))
	}
	return out, nil
}

// GetDailyDeal returns the current daily deal (matches hive: sword_flame 30%).
func (uc *ShopUseCase) GetDailyDeal(ctx context.Context) (*DailyDeal, error) {
	_ = ctx
	return &DailyDeal{
		ItemID:          "sword_flame",
		DiscountPercent: 30,
		ExpiresAt:       time.Now().Add(24 * time.Hour).UnixMilli(),
	}, nil
}

// Buy purchases an item; currency is taken from item config (ignore client hint).
func (uc *ShopUseCase) Buy(ctx context.Context, userID, itemID, _currency string) (*ShopItem, int64, error) {
	item, err := uc.shop.GetItem(ctx, itemID)
	if err != nil {
		return nil, 0, err
	}
	if item == nil {
		return nil, 0, notFound("Item not found")
	}
	var balance int64
	var out *ShopItem
	err = uc.data.InTx(ctx, func(tx *gorm.DB) error {
		owns, err := uc.shop.Owns(ctx, userID, itemID)
		if err != nil {
			return err
		}
		if owns {
			return conflict("Item already owned")
		}
		p, err := uc.prefs.Get(ctx, userID)
		if err != nil {
			return err
		}
		payGems := item.Currency == "gems" || uc.data.Catalog.IsGems(itemID)
		if payGems {
			if p.CurrentGems < item.Price {
				return failedPrecond("Not enough gems")
			}
			p.CurrentGems -= item.Price
			balance = p.CurrentGems
		} else {
			if p.CurrentGold < item.Price {
				return failedPrecond("Not enough gold")
			}
			p.CurrentGold -= item.Price
			balance = p.CurrentGold
		}
		if err := uc.shop.AddOwnedTx(tx, userID, itemID); err != nil {
			return err
		}
		c, _ := uc.chars.GetByUserID(ctx, userID)
		if err := applyUnlocks(ctx, tx, uc.data, uc.ach, uc.prefs, userID, p, c, 0, 0); err != nil {
			return err
		}
		// applyUnlocks may have granted gems — refresh balance if paying gems.
		if payGems {
			balance = p.CurrentGems
		} else {
			balance = p.CurrentGold
		}
		out = toBizShopItem(item, true)
		return nil
	})
	return out, balance, err
}

// ListOwned returns the ids of items owned by the user.
func (uc *ShopUseCase) ListOwned(ctx context.Context, userID string) ([]string, error) {
	return uc.shop.ListOwnedIDs(ctx, userID)
}

func toBizShopItem(it *model.ShopItem, owned bool) *ShopItem {
	cat := it.Slot
	if cat == "" {
		cat = it.Category
	}
	return &ShopItem{
		ID: it.ID, Name: it.Name, Description: it.Description, Price: it.Price,
		Category: cat, Rarity: it.Rarity, Currency: it.Currency, Slot: it.Slot, IsOwned: owned,
		StatStr: it.StatStr, StatInt: it.StatInt, StatAgi: it.StatAgi,
		StatDef: it.StatDef, StatVit: it.StatVit, StatLuk: it.StatLuk,
	}
}
