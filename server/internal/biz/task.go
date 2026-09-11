package biz

import (
	"context"
	"strings"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"

	"github.com/habitforge/backend/internal/data"
	"github.com/habitforge/backend/internal/game"
	"github.com/habitforge/backend/internal/model"
)

// Task is the domain task entity (Habit / Daily / ToDo).
type Task struct {
	ID               string
	Title            string
	Description      string
	Type             string // habit | daily | todo
	Difficulty       string // easy | medium | hard
	Tags             []string
	IsCompleted      bool
	CompletedAt      int64
	DueDate          int64
	RepeatDays       []int32
	Streak           int32
	LastStreakDate   int64
	CustomExpReward  int32
	CustomGoldReward int32
	Priority         string
	HpPenalty        int32
	IsSkipped        bool
	CreatedAt        int64
	UpdatedAt        int64
}

// TaskReward is granted when a task is completed.
type TaskReward struct {
	Exp  int32
	Gold int32
	HP   int32
}

// TaskListFilter holds list filters.
type TaskListFilter struct {
	Type             string
	Difficulty       string
	Tags             []string
	OnlyDueToday     bool
	IncludeCompleted bool
}

// CompleteResult is the outcome of completing a task.
type CompleteResult struct {
	Task      *Task
	Prefs     *UserPrefs
	Character *Character
	Exp       int32
	Gold      int32
}

// TaskUseCase handles task CRUD and completion rewards.
type TaskUseCase struct {
	tasks *data.TaskRepo
	chars *data.CharacterRepo
	prefs *data.PrefsRepo
	ach   *data.AchievementRepo
	data  *data.Data
}

// NewTaskUseCase builds the task use case.
func NewTaskUseCase(
	tasks *data.TaskRepo,
	chars *data.CharacterRepo,
	prefs *data.PrefsRepo,
	ach *data.AchievementRepo,
	d *data.Data,
) *TaskUseCase {
	return &TaskUseCase{tasks: tasks, chars: chars, prefs: prefs, ach: ach, data: d}
}

// List returns tasks for the current user.
func (uc *TaskUseCase) List(ctx context.Context, userID string, f TaskListFilter) ([]*Task, error) {
	if err := settleDayForUser(ctx, uc.data, uc.chars, uc.prefs, uc.tasks, userID); err != nil {
		return nil, err
	}
	rows, err := uc.tasks.List(ctx, userID)
	if err != nil {
		return nil, err
	}
	now := time.Now()
	out := make([]*Task, 0, len(rows))
	for _, t := range rows {
		if f.Type != "" && normalizeTaskType(t.Type) != normalizeTaskType(f.Type) {
			continue
		}
		if f.Difficulty != "" && normalizeDiff(t.Difficulty) != normalizeDiff(f.Difficulty) {
			continue
		}
		if len(f.Tags) > 0 {
			tagSet := map[string]struct{}{}
			for _, tg := range t.Tags {
				tagSet[tg] = struct{}{}
			}
			ok := true
			for _, want := range f.Tags {
				if _, hit := tagSet[want]; !hit {
					ok = false
					break
				}
			}
			if !ok {
				continue
			}
		}
		if !f.IncludeCompleted && t.IsCompleted {
			continue
		}
		if f.OnlyDueToday && !game.IsDueOn(fromModelTask(t), now) {
			continue
		}
		out = append(out, toBizTask(t))
	}
	return out, nil
}

// Get returns one task.
func (uc *TaskUseCase) Get(ctx context.Context, userID, id string) (*Task, error) {
	t, err := uc.tasks.Get(ctx, userID, id)
	if err != nil {
		return nil, err
	}
	if t == nil {
		return nil, notFound("Task not found")
	}
	return toBizTask(t), nil
}

// Create stores a new task.
func (uc *TaskUseCase) Create(ctx context.Context, userID string, t *Task) (*Task, error) {
	gt := fromBizTask(t)
	if reason := game.InvalidTaskShape(gt); reason != "" {
		return nil, badRequest(reason)
	}
	now := time.Now().UnixMilli()
	m := &model.Task{
		ID: uuid.NewString(), UserID: userID,
		Title: strings.TrimSpace(t.Title), Description: t.Description,
		Type: normalizeTaskType(t.Type), Difficulty: normalizeDiff(t.Difficulty),
		Tags: model.StringSlice(t.Tags), RepeatDays: model.Int32Slice(t.RepeatDays),
		DueDate: t.DueDate, CustomExpReward: t.CustomExpReward, CustomGoldReward: t.CustomGoldReward,
		Priority: t.Priority, HpPenalty: t.HpPenalty,
		CreatedAtMillis: now, UpdatedAtMillis: now,
	}
	if err := uc.tasks.Create(ctx, m); err != nil {
		return nil, err
	}
	p, _ := uc.prefs.Get(ctx, userID)
	if p != nil {
		p.TotalTasks++
		_ = uc.prefs.Save(ctx, p)
	}
	return toBizTask(m), nil
}

// Update stores task changes.
func (uc *TaskUseCase) Update(ctx context.Context, userID string, t *Task) (*Task, error) {
	cur, err := uc.tasks.Get(ctx, userID, t.ID)
	if err != nil {
		return nil, err
	}
	if cur == nil {
		return nil, notFound("Task not found")
	}
	gt := fromBizTask(t)
	if reason := game.InvalidTaskShape(gt); reason != "" {
		return nil, badRequest(reason)
	}
	cur.Title = strings.TrimSpace(t.Title)
	cur.Description = t.Description
	cur.Type = normalizeTaskType(t.Type)
	cur.Difficulty = normalizeDiff(t.Difficulty)
	cur.Tags = model.StringSlice(t.Tags)
	cur.DueDate = t.DueDate
	cur.RepeatDays = model.Int32Slice(t.RepeatDays)
	cur.Priority = t.Priority
	cur.HpPenalty = t.HpPenalty
	cur.UpdatedAtMillis = time.Now().UnixMilli()
	if err := uc.tasks.Save(ctx, cur); err != nil {
		return nil, err
	}
	return toBizTask(cur), nil
}

// Delete removes a task.
func (uc *TaskUseCase) Delete(ctx context.Context, userID, id string) error {
	cur, err := uc.tasks.Get(ctx, userID, id)
	if err != nil {
		return err
	}
	if cur == nil {
		return notFound("Task not found")
	}
	return uc.tasks.Delete(ctx, userID, id)
}

// Complete marks a task completed and computes the EXP/gold reward.
func (uc *TaskUseCase) Complete(ctx context.Context, userID, id string) (*CompleteResult, error) {
	var result *CompleteResult
	err := uc.data.InTx(ctx, func(tx *gorm.DB) error {
		t, err := uc.tasks.Get(ctx, userID, id)
		if err != nil {
			return err
		}
		if t == nil {
			return notFound("Task not found")
		}
		if t.IsCompleted {
			return failedPrecond("Task already completed")
		}
		c, err := uc.chars.GetByUserID(ctx, userID)
		if err != nil {
			return err
		}
		if c == nil {
			return notFound("Character not found")
		}
		if c.IsDead {
			return failedPrecond("Character is dead — revive first")
		}
		bonus := uc.data.Catalog.BonusLookup()
		gt := fromModelTask(t)
		gc := fromModelCharacter(c)
		gainExp := game.ExpReward(gt, gc, bonus)
		gainGold := game.GoldReward(gt, gc, bonus)

		p, err := uc.prefs.Get(ctx, userID)
		if err != nil {
			return err
		}
		today := dateOnlyMillis(time.Now())
		if p.LastActiveDate != today {
			p.TodayTasksCompleted = 0
			p.LastActiveDate = today
		}
		p.CurrentGold += int64(gainGold)
		p.TodayTasksCompleted++
		p.TotalTasksCompleted++
		if p.FirstTaskDate == 0 {
			p.FirstTaskDate = time.Now().UnixMilli()
		}

		newChar, _ := game.GainExp(gc, gainExp, bonus)
		toModelCharacter(c, newChar)
		newTask := game.CompleteTask(gt, time.Now())
		toModelTask(t, newTask)

		if err := applyUnlocks(ctx, tx, uc.data, uc.ach, uc.prefs, userID, p, c, newTask.Streak, 0); err != nil {
			return err
		}
		if err := uc.tasks.SaveTx(tx, t); err != nil {
			return err
		}
		if err := uc.chars.SaveTx(tx, c); err != nil {
			return err
		}
		result = &CompleteResult{
			Task: toBizTask(t), Prefs: toBizPrefs(p), Character: toBizCharacter(c),
			Exp: int32(gainExp), Gold: int32(gainGold),
		}
		return nil
	})
	return result, err
}

// Skip postpones a task (todos → tomorrow).
func (uc *TaskUseCase) Skip(ctx context.Context, userID, id string) (*Task, error) {
	t, err := uc.tasks.Get(ctx, userID, id)
	if err != nil {
		return nil, err
	}
	if t == nil {
		return nil, notFound("Task not found")
	}
	updated := game.Postpone(fromModelTask(t), time.Now())
	toModelTask(t, updated)
	if err := uc.tasks.Save(ctx, t); err != nil {
		return nil, err
	}
	return toBizTask(t), nil
}

func toBizTask(t *model.Task) *Task {
	return &Task{
		ID: t.ID, Title: t.Title, Description: t.Description, Type: t.Type, Difficulty: t.Difficulty,
		Tags: []string(t.Tags), IsCompleted: t.IsCompleted, CompletedAt: t.CompletedAt, DueDate: t.DueDate,
		RepeatDays: []int32(t.RepeatDays), Streak: t.Streak, LastStreakDate: t.LastStreakDate,
		CustomExpReward: t.CustomExpReward, CustomGoldReward: t.CustomGoldReward,
		Priority: t.Priority, HpPenalty: t.HpPenalty, IsSkipped: t.IsSkipped,
		CreatedAt: t.CreatedAtMillis, UpdatedAt: t.UpdatedAtMillis,
	}
}

func fromBizTask(t *Task) game.Task {
	if t == nil {
		return game.Task{}
	}
	return game.Task{
		ID: t.ID, Title: t.Title, Description: t.Description, Type: t.Type, Difficulty: t.Difficulty,
		Tags: t.Tags, IsCompleted: t.IsCompleted, CompletedAt: t.CompletedAt, DueDate: t.DueDate,
		RepeatDays: t.RepeatDays, Streak: int(t.Streak), LastStreakDate: t.LastStreakDate,
		CustomExpReward: int(t.CustomExpReward), CustomGoldReward: int(t.CustomGoldReward),
		Priority: t.Priority, HpPenalty: int(t.HpPenalty), IsSkipped: t.IsSkipped,
		CreatedAt: t.CreatedAt, UpdatedAt: t.UpdatedAt,
	}
}

func normalizeTaskType(t string) string {
	switch strings.ToLower(t) {
	case "habit", "task_type_habit", "1":
		return "habit"
	case "daily", "task_type_daily", "2":
		return "daily"
	case "todo", "task_type_todo", "3":
		return "todo"
	default:
		return strings.ToLower(t)
	}
}

func normalizeDiff(d string) string {
	switch strings.ToLower(d) {
	case "easy", "task_difficulty_easy", "1":
		return "easy"
	case "medium", "task_difficulty_medium", "2":
		return "medium"
	case "hard", "task_difficulty_hard", "3":
		return "hard"
	default:
		return strings.ToLower(d)
	}
}
