package data

import (
	"context"
	"errors"

	"gorm.io/gorm"

	"github.com/habitforge/backend/internal/model"
)

// TaskRepo persists tasks.
type TaskRepo struct{ data *Data }

// NewTaskRepo builds TaskRepo.
func NewTaskRepo(d *Data) *TaskRepo { return &TaskRepo{data: d} }

// ListFilter holds optional list filters.
type ListFilter struct {
	Type             string
	Difficulty       string
	Tags             []string
	OnlyDueToday     bool
	IncludeCompleted bool
}

// List returns tasks for a user.
func (r *TaskRepo) List(ctx context.Context, userID string) ([]*model.Task, error) {
	var tasks []*model.Task
	err := r.data.db.WithContext(ctx).Where("user_id = ?", userID).Order("created_at_millis asc").Find(&tasks).Error
	return tasks, err
}

// Get returns one task owned by userID.
func (r *TaskRepo) Get(ctx context.Context, userID, id string) (*model.Task, error) {
	var t model.Task
	err := r.data.db.WithContext(ctx).Where("id = ? AND user_id = ?", id, userID).First(&t).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &t, nil
}

// Create inserts a task.
func (r *TaskRepo) Create(ctx context.Context, t *model.Task) error {
	return r.data.db.WithContext(ctx).Create(t).Error
}

// Save updates a task.
func (r *TaskRepo) Save(ctx context.Context, t *model.Task) error {
	return r.data.db.WithContext(ctx).Save(t).Error
}

// SaveTx updates within a transaction.
func (r *TaskRepo) SaveTx(tx *gorm.DB, t *model.Task) error {
	return tx.Save(t).Error
}

// Delete removes a task.
func (r *TaskRepo) Delete(ctx context.Context, userID, id string) error {
	return r.data.db.WithContext(ctx).Where("id = ? AND user_id = ?", id, userID).Delete(&model.Task{}).Error
}

// CountByUser returns total task count.
func (r *TaskRepo) CountByUser(ctx context.Context, userID string) (int64, error) {
	var n int64
	err := r.data.db.WithContext(ctx).Model(&model.Task{}).Where("user_id = ?", userID).Count(&n).Error
	return n, err
}
