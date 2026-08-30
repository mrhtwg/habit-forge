import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/grpc/base_grpc_api.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pbgrpc.dart';

class CharacterApi extends BaseGrpcApi {
  late final CharacterServiceClient _stub;

  Future<ApiResponse<GetCharacterReply>> getCharacter() async => call(() => _stub.getCharacter(GetCharacterRequest()));
}
