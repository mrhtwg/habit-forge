package data

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"gorm.io/gorm"

	"github.com/habitforge/backend/internal/model"
)

// ShopRepo persists shop catalog and owned items.
type ShopRepo struct{ data *Data }

// NewShopRepo builds ShopRepo.
func NewShopRepo(d *Data) *ShopRepo { return &ShopRepo{data: d} }

// ListItems returns catalog items, optionally filtered by slot/category.
func (r *ShopRepo) ListItems(ctx context.Context, category string) ([]*model.ShopItem, error) {
	q := r.data.db.WithContext(ctx).Model(&model.ShopItem{})
	if category != "" {
		q = q.Where("slot = ? OR category = ?", category, category)
	}
	var items []*model.ShopItem
	err := q.Order("price asc").Find(&items).Error
	return items, err
}

// GetItem returns one catalog item.
func (r *ShopRepo) GetItem(ctx context.Context, id string) (*model.ShopItem, error) {
	var it model.ShopItem
	err := r.data.db.WithContext(ctx).Where("id = ?", id).First(&it).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &it, nil
}

// ListOwnedIDs returns owned item ids for a user.
func (r *ShopRepo) ListOwnedIDs(ctx context.Context, userID string) ([]string, error) {
	var rows []model.OwnedItem
	if err := r.data.db.WithContext(ctx).Where("user_id = ?", userID).Find(&rows).Error; err != nil {
		return nil, err
	}
	out := make([]string, 0, len(rows))
	for _, r := range rows {
		out = append(out, r.ItemID)
	}
	return out, nil
}

// Owns reports whether the user owns itemID.
func (r *ShopRepo) Owns(ctx context.Context, userID, itemID string) (bool, error) {
	var n int64
	err := r.data.db.WithContext(ctx).Model(&model.OwnedItem{}).
		Where("user_id = ? AND item_id = ?", userID, itemID).Count(&n).Error
	return n > 0, err
}

// AddOwned inserts an owned item.
func (r *ShopRepo) AddOwned(ctx context.Context, userID, itemID string) error {
	return r.data.db.WithContext(ctx).Create(&model.OwnedItem{
		ID: uuid.NewString(), UserID: userID, ItemID: itemID,
	}).Error
}

// AddOwnedTx inserts within a transaction.
func (r *ShopRepo) AddOwnedTx(tx *gorm.DB, userID, itemID string) error {
	return tx.Create(&model.OwnedItem{
		ID: uuid.NewString(), UserID: userID, ItemID: itemID,
	}).Error
}

// CountOwned returns purchase count.
func (r *ShopRepo) CountOwned(ctx context.Context, userID string) (int64, error) {
	var n int64
	err := r.data.db.WithContext(ctx).Model(&model.OwnedItem{}).Where("user_id = ?", userID).Count(&n).Error
	return n, err
}
