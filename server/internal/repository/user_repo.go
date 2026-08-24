package repository

import (
	"github.com/habitforge/backend/internal/model"
	"gorm.io/gorm"
)

type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) Create(user *model.User) error {
	return r.db.Create(user).Error
}

func (r *UserRepository) FindByEmail(email string) (*model.User, error) {
	var user model.User
	err := r.db.Where("email = ?", email).First(&user).Error
	return &user, err
}

func (r *UserRepository) FindByID(id string) (*model.User, error) {
	var user model.User
	err := r.db.First(&user, "id = ?", id).Error
	return &user, err
}

func (r *UserRepository) FindByProvider(provider, providerID string) (*model.User, error) {
	var auth model.AuthProvider
	if err := r.db.Where("provider = ? AND provider_id = ?", provider, providerID).First(&auth).Error; err != nil {
		return nil, err
	}
	return r.FindByID(auth.UserID)
}

func (r *UserRepository) LinkProvider(auth *model.AuthProvider) error {
	return r.db.Create(auth).Error
}
