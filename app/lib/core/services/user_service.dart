import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/animation/frame_sequence_player.dart';
import 'package:habit_forge_app/core/common/utils/sp_keys.dart';
import 'package:habit_forge_app/core/common/utils/sp_utils.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:habit_forge_app/generated/protos/task/v1/task.pb.dart';
import 'package:habit_forge_app/generated/protos/user/v1/user.pb.dart';

class UserService extends GetxService {
  static UserService get to => Get.find();

  final userPrefs = UserPrefs().obs;

  final token = ''.obs;

  final soundEnabled = true.obs;

  // Initial class, show on splash
  final initialClass = Rxn<CharacterClass>(CharacterClass.CHARACTER_CLASS_WARRIOR);

  final character = Rxn<Character>();

  final tasks = <Task>[].obs;

  Future<void> loadUserPrefs() async {
    final result = await NetworkRegistry.ins.getPrefs();
    if (result.isSuccess) {
      userPrefs.value = result.data?.prefs ?? UserPrefs();
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

  /// Persists the session token (SharedPreferences) and mirrors it into the
  /// reactive [token]. Pass null/empty to clear the session.
  Future<void> setSessionToken(String? token) async {
    final value = token ?? '';
    if (value.isEmpty) {
      await SpUtils.ins.remove(SpKeys.token);
    } else {
      await SpUtils.ins.putString(SpKeys.token, value);
    }
    this.token.value = value;
  }

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

  /// Resets the in-memory session state (used by "Reset All Data" so the
  /// next splash run starts as a brand-new player).
  Future<void> clearData() async {
    token.value = '';
    userPrefs.value = UserPrefs();
    character.value = null;
    tasks.clear();
    initialClass.value = CharacterClass.CHARACTER_CLASS_WARRIOR;
  }
}
