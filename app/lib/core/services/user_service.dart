import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/animation/frame_sequence_player.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/interface/network_registry.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();
  final character = Rxn<Character>();

  final tasks = <Task>[].obs;
  List<String> getCharacterFrame() {
    if (character.value == null) {
      return FrameSequencePlayer.knightIdleFrames();
    }
    switch (character.value!.characterClass) {
      case CharacterClass.CHARACTER_CLASS_WARRIOR:
        return FrameSequencePlayer.knightIdleFrames();
      case CharacterClass.CHARACTER_CLASS_MAGE:
        return FrameSequencePlayer.mageIdleFrames();
      case CharacterClass.CHARACTER_CLASS_RANGER:
        return FrameSequencePlayer.rangerIdleFrames();
      default:
        return FrameSequencePlayer.knightIdleFrames();
    }
  }

  Future<UserService> init() async {
    return this;
  }

  bool isLoggedIn() => (SpUtils.ins.getString('token') ?? '').isEmpty ? false : true;
  Future<bool> loadCharacter() async {
    character.value = await NetworkRegistry.ins.loadCharacter();
    return true;
  }

  Future<void> saveCharacter(Character character) async {
    await SpUtils.ins.putString('character', character.writeToJson());
  }
}
