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
func (s *ShopService) ListShopItems(ctx context.Context, req *shopv1.ListShopItemsRequest) (*shopv1.ListShopItemsReply, error) {
	uid, _ := requireUserID(ctx) // optional for ownership flags
	items, err := s.uc.ListItems(ctx, uid, req.GetCategory())
	if err != nil {
		return nil, err
	}
	out := make([]*shopv1.ShopItem, 0, len(items))
	for _, it := range items {
		out = append(out, toProtoShopItem(it))
	}
	return &shopv1.ListShopItemsReply{Items: out}, nil
}

// GetDailyDeal returns the current daily deal.
func (s *ShopService) GetDailyDeal(ctx context.Context, req *shopv1.GetDailyDealRequest) (*shopv1.GetDailyDealReply, error) {
	deal, err := s.uc.GetDailyDeal(ctx)
	if err != nil {
		return nil, err
	}
	return &shopv1.GetDailyDealReply{
		Deal: &shopv1.DailyDeal{
			ItemId: deal.ItemID, DiscountPercent: deal.DiscountPercent, ExpiresAt: deal.ExpiresAt,
		},
	}, nil
}

// BuyItem purchases an item with gold or gems.
func (s *ShopService) BuyItem(ctx context.Context, req *shopv1.BuyItemRequest) (*shopv1.BuyItemReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	item, balance, err := s.uc.Buy(ctx, uid, req.GetItemId(), req.GetCurrency().String())
	if err != nil {
		return nil, err
	}
	return &shopv1.BuyItemReply{Item: toProtoShopItem(item), Balance: balance}, nil
}

// ListOwnedItems lists items owned by the current user.
func (s *ShopService) ListOwnedItems(ctx context.Context, req *shopv1.ListOwnedItemsRequest) (*shopv1.ListOwnedItemsReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	ids, err := s.uc.ListOwned(ctx, uid)
	if err != nil {
		return nil, err
	}
	return &shopv1.ListOwnedItemsReply{ItemIds: ids}, nil
}
