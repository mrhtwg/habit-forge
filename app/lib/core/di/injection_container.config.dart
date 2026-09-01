// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../common/utils/sp_utils.dart' as _i619;
import '../network/grpc/base/grpc_client_channel.dart' as _i799;
import '../network/hive/character_box.dart' as _i545;
import '../network/hive/shop_box.dart' as _i1070;
import '../network/hive/task_box.dart' as _i165;
import '../network/hive/user_box.dart' as _i70;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  gh.singleton<_i619.SpUtils>(() => _i619.SpUtils());
  gh.singleton<_i799.GrpcClientChannel>(() => _i799.GrpcClientChannel());
  gh.singleton<_i545.CharacterBox>(() => _i545.CharacterBox());
  gh.singleton<_i1070.ShopBox>(() => _i1070.ShopBox());
  gh.singleton<_i165.TaskBox>(() => _i165.TaskBox());
  gh.singleton<_i70.UserBox>(() => _i70.UserBox());
  return getIt;
}
