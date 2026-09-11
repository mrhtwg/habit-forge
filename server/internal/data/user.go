package data

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"gorm.io/gorm"

	"github.com/habitforge/backend/internal/model"
)

// UserRepo persists users and auth providers.
type UserRepo struct{ data *Data }

// NewUserRepo builds UserRepo.
func NewUserRepo(d *Data) *UserRepo { return &UserRepo{data: d} }

// Create inserts a user.
func (r *UserRepo) Create(ctx context.Context, u *model.User) error {
	if u.ID == "" {
		u.ID = uuid.NewString()
	}
	return r.data.db.WithContext(ctx).Create(u).Error
}

// CreateWithPrefs creates a user and default prefs in one transaction.
func (r *UserRepo) CreateWithPrefs(ctx context.Context, u *model.User, provider *model.AuthProvider) error {
	return r.data.InTx(ctx, func(tx *gorm.DB) error {
		if u.ID == "" {
			u.ID = uuid.NewString()
		}
		if err := tx.Create(u).Error; err != nil {
			return err
		}
		prefs := &model.UserPrefs{UserID: u.ID, NotificationsEnabled: true, SoundEnabled: true, HapticEnabled: true}
		if err := tx.Create(prefs).Error; err != nil {
			return err
		}
		if provider != nil {
			provider.UserID = u.ID
			if provider.ID == "" {
				provider.ID = uuid.NewString()
			}
			if err := tx.Create(provider).Error; err != nil {
				return err
			}
		}
		return nil
	})
}

// FindByEmail loads a user by email.
func (r *UserRepo) FindByEmail(ctx context.Context, email string) (*model.User, error) {
	var u model.User
	err := r.data.db.WithContext(ctx).Where("email = ?", email).First(&u).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &u, nil
}

// FindByID loads a user by id.
func (r *UserRepo) FindByID(ctx context.Context, id string) (*model.User, error) {
	var u model.User
	err := r.data.db.WithContext(ctx).Where("id = ?", id).First(&u).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &u, nil
}

// FindByProvider finds a user linked to a provider identity.
func (r *UserRepo) FindByProvider(ctx context.Context, provider, providerID string) (*model.User, error) {
	var ap model.AuthProvider
	err := r.data.db.WithContext(ctx).Where("provider = ? AND provider_id = ?", provider, providerID).First(&ap).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return r.FindByID(ctx, ap.UserID)
}

// AddProvider attaches an auth provider to a user.
func (r *UserRepo) AddProvider(ctx context.Context, ap *model.AuthProvider) error {
	if ap.ID == "" {
		ap.ID = uuid.NewString()
	}
	return r.data.db.WithContext(ctx).Create(ap).Error
}
