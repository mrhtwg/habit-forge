import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/animation/frame_sequence_player.dart';
import 'package:habit_forge_app/core/common/utils/sp_keys.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();

  final gold = 0.obs;
  final gem = 0.obs;

  final token = ''.obs;

  final soundEnabled = true.obs;

  // Initial class, show on splash
  final initialClass = Rxn<CharacterClass>(CharacterClass.CHARACTER_CLASS_WARRIOR);

  final character = Rxn<Character>();

  final tasks = <Task>[].obs;

  Future<void> loadUserPrefs() async {
    final result = await NetworkRegistry.ins.getPrefs();
    if (result.isSuccess) {
      gold.value = result.data?.prefs.currentGold.toInt() ?? 0;
    }
  }

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
    initialClass.value = CharacterClass.valueOf(
      SpUtils.ins.getInt(SpKeys.characterClass) ?? CharacterClass.CHARACTER_CLASS_WARRIOR.value,
    );
    token.value = SpUtils.ins.getString(SpKeys.token) ?? '';
    return this;
  }

  bool isLoggedIn() => token.value.isNotEmpty;

  Future loadCharacter() async {
    final result = await NetworkRegistry.ins.getCharacter();
    if (result.isSuccess) {
      character.value = result.data?.character;
      await SpUtils.ins.putInt(SpKeys.characterClass, character.value!.characterClass.value);
    }
  }

  Future<void> saveCharacter(Character c) async {
    character.value = c;
    await SpUtils.ins.putInt(SpKeys.characterClass, c.characterClass.value);
  }
}
