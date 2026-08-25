package biz

import (
	"errors"

	"github.com/google/wire"
)

// ErrNotImplemented marks every interface whose implementation is left empty
// by design. Replace each TODO with the real business logic later.
var ErrNotImplemented = errors.New("not implemented")

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
