import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/animation/frame_sequence_player.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();

  final gold = 0.obs;
  final gem = 0.obs;
  final token = ''.obs;

  // Initial class, show on splash
  final initialClass = Rxn<CharacterClass>(CharacterClass.CHARACTER_CLASS_WARRIOR);

  final character = Rxn<Character>();

  final tasks = <Task>[].obs;

  List<String> getCharacterFrame([CharacterClass? characterClass]) {
    CharacterClass? _class = characterClass;
    if (_class == null) {
      if (character.value != null) {
        _class = character.value!.characterClass;
      } else {
        _class = initialClass.value;
      }
    }

    switch (_class) {
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
    initialClass.value =
        CharacterClass.valueOf(SpUtils.ins.getInt('characterClass') ?? CharacterClass.CHARACTER_CLASS_WARRIOR.value);
    token.value = SpUtils.ins.getString('token') ?? '';
    return this;
  }

  bool isLoggedIn() => token.value.isNotEmpty;

  Future<bool> loadCharacter() async {
    final result = await NetworkRegistry.ins.getCharacter();
    if (character.value == null) {
      return false;
    }
    SpUtils.ins.putInt('characterClass', character.value!.characterClass.value);
    return true;
  }

  Future<void> saveCharacter(Character c) async {
    character.value = c;
    await SpUtils.ins.putString('character', c.writeToJson());
  }
}
