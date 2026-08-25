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
// TODO(implementation): delegate to s.uc.List.
func (s *TaskService) ListTasks(ctx context.Context, req *taskv1.ListTasksRequest) (*taskv1.ListTasksReply, error) {
	return nil, errNotImplemented()
}

// GetTask returns one task.
// TODO(implementation): delegate to s.uc.Get.
func (s *TaskService) GetTask(ctx context.Context, req *taskv1.GetTaskRequest) (*taskv1.GetTaskReply, error) {
	return nil, errNotImplemented()
}

// CreateTask creates a new task.
// TODO(implementation): delegate to s.uc.Create.
func (s *TaskService) CreateTask(ctx context.Context, req *taskv1.CreateTaskRequest) (*taskv1.CreateTaskReply, error) {
	return nil, errNotImplemented()
}

// UpdateTask updates an existing task.
// TODO(implementation): delegate to s.uc.Update.
func (s *TaskService) UpdateTask(ctx context.Context, req *taskv1.UpdateTaskRequest) (*taskv1.UpdateTaskReply, error) {
	return nil, errNotImplemented()
}

// DeleteTask removes a task.
// TODO(implementation): delegate to s.uc.Delete.
func (s *TaskService) DeleteTask(ctx context.Context, req *taskv1.DeleteTaskRequest) (*taskv1.DeleteTaskReply, error) {
	return nil, errNotImplemented()
}

// CompleteTask marks a task completed and grants rewards.
// TODO(implementation): delegate to s.uc.Complete.
func (s *TaskService) CompleteTask(ctx context.Context, req *taskv1.CompleteTaskRequest) (*taskv1.CompleteTaskReply, error) {
	return nil, errNotImplemented()
}
