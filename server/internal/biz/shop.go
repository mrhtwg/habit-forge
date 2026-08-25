package biz

import "context"

// ShopItem is the domain shop item entity.
type ShopItem struct {
	ID           string
	Name         string
	Description  string
	Price        int64
	Category     string // weapon | helmet | armor | accessory
	Rarity       string // common | rare | epic | legendary
	GLBAssetPath string
	IsOwned      bool
}

// DailyDeal is the rotating discounted item.
type DailyDeal struct {
	ItemID          string
	DiscountPercent int32
	ExpiresAt       int64 // unix millis
}

// ShopUseCase handles the forge shop.
type ShopUseCase struct{}

// NewShopUseCase builds the shop use case.
func NewShopUseCase() *ShopUseCase { return &ShopUseCase{} }

// ListItems returns purchasable items, optionally filtered by category.
func (uc *ShopUseCase) ListItems(ctx context.Context, userID, category string) ([]*ShopItem, error) {
	return nil, ErrNotImplemented // TODO
}

// GetDailyDeal returns the current daily deal.
func (uc *ShopUseCase) GetDailyDeal(ctx context.Context) (*DailyDeal, error) {
	return nil, ErrNotImplemented // TODO
}

// Buy purchases an item with gold or gems and returns the remaining balance.
func (uc *ShopUseCase) Buy(ctx context.Context, userID, itemID, currency string) (*ShopItem, int64, error) {
	return nil, 0, ErrNotImplemented // TODO
}

// ListOwned returns the ids of items owned by the user.
func (uc *ShopUseCase) ListOwned(ctx context.Context, userID string) ([]string, error) {
	return nil, ErrNotImplemented // TODO
}
