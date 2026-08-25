package biz

import "context"

// Task is the domain task entity (Habit / Daily / ToDo).
type Task struct {
	ID               string
	Title            string
	Description      string
	Type             string // habit | daily | todo
	Difficulty       string // easy | medium | hard
	Tags             []string
	IsCompleted      bool
	CompletedAt      int64 // unix millis
	DueDate          int64 // unix millis
	RepeatDays       []int32 // 0=Mon .. 6=Sun
	Streak           int32
	LastStreakDate   int64 // unix millis
	CustomExpReward  int32
	CustomGoldReward int32
	Priority         string
	HpPenalty        int32
	IsSkipped        bool
	CreatedAt        int64 // unix millis
	UpdatedAt        int64 // unix millis
}

// TaskReward is granted when a task is completed.
type TaskReward struct {
	Exp  int32
	Gold int32
	HP   int32
}

// TaskUseCase handles task CRUD and completion rewards.
type TaskUseCase struct{}

// NewTaskUseCase builds the task use case.
func NewTaskUseCase() *TaskUseCase { return &TaskUseCase{} }

// List returns tasks for the current user.
func (uc *TaskUseCase) List(ctx context.Context, userID string) ([]*Task, error) {
	return nil, ErrNotImplemented // TODO
}

// Get returns one task.
func (uc *TaskUseCase) Get(ctx context.Context, userID, id string) (*Task, error) {
	return nil, ErrNotImplemented // TODO
}

// Create stores a new task.
func (uc *TaskUseCase) Create(ctx context.Context, userID string, t *Task) (*Task, error) {
	return nil, ErrNotImplemented // TODO
}

// Update stores task changes (complete / skip / postpone included).
func (uc *TaskUseCase) Update(ctx context.Context, userID string, t *Task) (*Task, error) {
	return nil, ErrNotImplemented // TODO
}

// Delete removes a task.
func (uc *TaskUseCase) Delete(ctx context.Context, userID, id string) error {
	return ErrNotImplemented // TODO
}

// Complete marks a task completed and computes the EXP/gold reward.
func (uc *TaskUseCase) Complete(ctx context.Context, userID, id string) (*Task, *TaskReward, error) {
	return nil, nil, ErrNotImplemented // TODO: streak multiplier, HP penalty, wallet update
}
