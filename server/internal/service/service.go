package service

import (
	kerrors "github.com/go-kratos/kratos/v2/errors"
	"github.com/google/wire"
)

// errNotImplemented is returned by every service method while the
// implementations are intentionally left empty.
func errNotImplemented() error {
	return kerrors.New(501, "NOT_IMPLEMENTED", "not implemented")
}

// ProviderSet is the service layer DI provider.
var ProviderSet = wire.NewSet(
	NewAuthService,
	NewUserService,
	NewCharacterService,
	NewTaskService,
	NewShopService,
	NewAchievementService,
	NewStatsService,
)
