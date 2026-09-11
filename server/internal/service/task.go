package service

import (
	"context"

	taskv1 "github.com/habitforge/backend/api/task/v1"
	"github.com/habitforge/backend/internal/biz"
)

// TaskService implements the TaskService interface (HTTP + gRPC).
type TaskService struct {
	taskv1.UnimplementedTaskServiceServer
	uc *biz.TaskUseCase
}

// NewTaskService builds the task service.
func NewTaskService(uc *biz.TaskUseCase) *TaskService {
	return &TaskService{uc: uc}
}

// ListTasks lists tasks with optional filters.
func (s *TaskService) ListTasks(ctx context.Context, req *taskv1.ListTasksRequest) (*taskv1.ListTasksReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	list, err := s.uc.List(ctx, uid, biz.TaskListFilter{
		Type:             taskTypeName(req.GetType()),
		Difficulty:       difficultyName(req.GetDifficulty()),
		Tags:             req.GetTags(),
		OnlyDueToday:     req.GetOnlyDueToday(),
		IncludeCompleted: req.GetIncludeCompleted(),
	})
	if err != nil {
		return nil, err
	}
	out := make([]*taskv1.Task, 0, len(list))
	for _, t := range list {
		out = append(out, toProtoTask(t))
	}
	return &taskv1.ListTasksReply{Tasks: out}, nil
}

// GetTask returns one task.
func (s *TaskService) GetTask(ctx context.Context, req *taskv1.GetTaskRequest) (*taskv1.GetTaskReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	t, err := s.uc.Get(ctx, uid, req.GetId())
	if err != nil {
		return nil, err
	}
	return &taskv1.GetTaskReply{Task: toProtoTask(t)}, nil
}

// CreateTask creates a new task.
func (s *TaskService) CreateTask(ctx context.Context, req *taskv1.CreateTaskRequest) (*taskv1.CreateTaskReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	t, err := s.uc.Create(ctx, uid, fromProtoTask(req.GetTask()))
	if err != nil {
		return nil, err
	}
	return &taskv1.CreateTaskReply{Task: toProtoTask(t)}, nil
}

// UpdateTask updates an existing task.
func (s *TaskService) UpdateTask(ctx context.Context, req *taskv1.UpdateTaskRequest) (*taskv1.UpdateTaskReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	t := fromProtoTask(req.GetTask())
	if t != nil {
		t.ID = req.GetId()
	}
	updated, err := s.uc.Update(ctx, uid, t)
	if err != nil {
		return nil, err
	}
	return &taskv1.UpdateTaskReply{Task: toProtoTask(updated)}, nil
}

// DeleteTask removes a task.
func (s *TaskService) DeleteTask(ctx context.Context, req *taskv1.DeleteTaskRequest) (*taskv1.DeleteTaskReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	if err := s.uc.Delete(ctx, uid, req.GetId()); err != nil {
		return nil, err
	}
	return &taskv1.DeleteTaskReply{}, nil
}

// CompleteTask marks a task completed and grants rewards.
func (s *TaskService) CompleteTask(ctx context.Context, req *taskv1.CompleteTaskRequest) (*taskv1.CompleteTaskReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	res, err := s.uc.Complete(ctx, uid, req.GetId())
	if err != nil {
		return nil, err
	}
	return &taskv1.CompleteTaskReply{
		Task: toProtoTask(res.Task), Prefs: toProtoPrefs(res.Prefs), Character: toProtoCharacter(res.Character),
		ExpReward: res.Exp, GoldReward: res.Gold,
	}, nil
}

// SkipTask skips / postpones a task.
func (s *TaskService) SkipTask(ctx context.Context, req *taskv1.SkipTaskRequest) (*taskv1.SkipTaskReply, error) {
	uid, err := requireUserID(ctx)
	if err != nil {
		return nil, err
	}
	t, err := s.uc.Skip(ctx, uid, req.GetId())
	if err != nil {
		return nil, err
	}
	return &taskv1.SkipTaskReply{Task: toProtoTask(t)}, nil
}
