package biz

import (
	kerrors "github.com/go-kratos/kratos/v2/errors"
	"github.com/google/wire"
)

// Sentinel / kratos errors used across use cases.
var (
	ErrNotFound      = kerrors.NotFound("NOT_FOUND", "not found")
	ErrConflict      = kerrors.Conflict("ALREADY_EXISTS", "already exists")
	ErrBadRequest    = kerrors.BadRequest("INVALID_ARGUMENT", "invalid argument")
	ErrUnauthorized  = kerrors.Unauthorized("UNAUTHORIZED", "unauthorized")
	ErrFailedPrecond = kerrors.New(409, "FAILED_PRECONDITION", "failed precondition")
)

func badRequest(msg string) error {
	return kerrors.BadRequest("INVALID_ARGUMENT", msg)
}

func notFound(msg string) error {
	return kerrors.NotFound("NOT_FOUND", msg)
}

func conflict(msg string) error {
	return kerrors.Conflict("ALREADY_EXISTS", msg)
}

func failedPrecond(msg string) error {
	return kerrors.New(409, "FAILED_PRECONDITION", msg)
}

func unauthorized(msg string) error {
	return kerrors.Unauthorized("UNAUTHORIZED", msg)
}

// ProviderSet is the business layer DI provider.
var ProviderSet = wire.NewSet(
	NewAuthUseCase,
	NewUserUseCase,
	NewCharacterUseCase,
	NewTaskUseCase,
	NewShopUseCase,
	NewAchievementUseCase,
	NewStatsUseCase,
)
