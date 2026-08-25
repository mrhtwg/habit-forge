package service

import (
	"context"

	shopv1 "github.com/habitforge/backend/api/shop/v1"
	"github.com/habitforge/backend/internal/biz"
)

// ShopService implements the ShopService interface (HTTP + gRPC).
type ShopService struct {
	shopv1.UnimplementedShopServiceServer
	uc *biz.ShopUseCase
}

// NewShopService builds the shop service.
func NewShopService(uc *biz.ShopUseCase) *ShopService {
	return &ShopService{uc: uc}
}

// ListShopItems lists purchasable items.
// TODO(implementation): delegate to s.uc.ListItems.
func (s *ShopService) ListShopItems(ctx context.Context, req *shopv1.ListShopItemsRequest) (*shopv1.ListShopItemsReply, error) {
	return nil, errNotImplemented()
}

// GetDailyDeal returns the current daily deal.
// TODO(implementation): delegate to s.uc.GetDailyDeal.
func (s *ShopService) GetDailyDeal(ctx context.Context, req *shopv1.GetDailyDealRequest) (*shopv1.GetDailyDealReply, error) {
	return nil, errNotImplemented()
}

// BuyItem purchases an item with gold or gems.
// TODO(implementation): delegate to s.uc.Buy.
func (s *ShopService) BuyItem(ctx context.Context, req *shopv1.BuyItemRequest) (*shopv1.BuyItemReply, error) {
	return nil, errNotImplemented()
}

// ListOwnedItems lists items owned by the current user.
// TODO(implementation): delegate to s.uc.ListOwned.
func (s *ShopService) ListOwnedItems(ctx context.Context, req *shopv1.ListOwnedItemsRequest) (*shopv1.ListOwnedItemsReply, error) {
	return nil, errNotImplemented()
}
