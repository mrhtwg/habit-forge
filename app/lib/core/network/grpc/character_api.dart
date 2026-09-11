import 'package:habit_forge_app/core/network/api_response.dart';
import 'package:habit_forge_app/core/network/grpc/base/base_grpc_api.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pbgrpc.dart';
import 'package:habit_forge_app/generated/protos/shared/v1/shared.pbenum.dart';

class CharacterApi extends BaseGrpcApi {
  CharacterApi() {
    _stub = CharacterServiceClient(channel, interceptors: interceptors);
  }

  late final CharacterServiceClient _stub;

  Future<ApiResponse<CreateCharacterReply>> createCharacter(CharacterClass characterClass) async =>
      call(() => _stub.createCharacter(CreateCharacterRequest(characterClass: characterClass)));

  Future<ApiResponse<GetCharacterReply>> getCharacter() async =>
      call(() => _stub.getCharacter(GetCharacterRequest()));

  Future<ApiResponse<AllocateStatPointReply>> allocateStatPoint(StatType stat) async =>
      call(() => _stub.allocateStatPoint(AllocateStatPointRequest(stat: stat)));

  Future<ApiResponse<ReviveReply>> revive() async => call(() => _stub.revive(ReviveRequest()));

  Future<ApiResponse<EquipItemReply>> equipItem(String itemId, EquipmentSlot slot) async =>
      call(() => _stub.equipItem(EquipItemRequest(itemId: itemId, slot: slot)));
}
