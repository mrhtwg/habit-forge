import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/grpc/base/base_grpc_api.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pbgrpc.dart';

class UserApi extends BaseGrpcApi {
  UserApi() {
    _stub = UserServiceClient(channel, interceptors: interceptors);
  }

  late final UserServiceClient _stub;

  Future<ApiResponse<GetPrefsReply>> getPrefs() async => call(() => _stub.getPrefs(GetPrefsRequest()));
}
