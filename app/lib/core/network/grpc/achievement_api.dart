import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/grpc/base/base_grpc_api.dart';
import 'package:habit_forge_app/generated/protos/achievement/v1/achievement.pbgrpc.dart';

class AchievementApi extends BaseGrpcApi {
  AchievementApi() {
    _stub = AchievementServiceClient(channel, interceptors: interceptors);
  }

  late final AchievementServiceClient _stub;

  Future<ApiResponse<ListAchievementsReply>> listAchievements() async =>
      call(() => _stub.listAchievements(ListAchievementsRequest()));
}
