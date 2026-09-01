import 'package:habit_forge_app/core/di/injection_container.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

@singleton
class CharacterBox {
  static CharacterBox get ins => getIt<CharacterBox>();

  CharacterBox();

  final _boxKey = 'characterBox';
  final _characterKey = 'character';

  late Box _characterBox;

  Future init() async {
    _characterBox = await Hive.openBox(_boxKey);
  }

  void createCharacter(Character character) {
    _characterBox.put(_characterKey, character.writeToBuffer());
  }

  void updateCharacter(Character character) {
    _characterBox.put(_characterKey, character.writeToBuffer());
    // final _c = getCharacter();
    // if (_c == null) {
    //   return;
    // }

    // final _character = _c.rebuild(
    //   (_character) => _character
    //     ..characterClass = character.characterClass
    //     ..level = character.level
    //     ..currentExp = character.currentExp
    //     ..currentHp = character.currentHp
    //     ..baseStats = character.baseStats
    //     ..availableStatPoints = character.availableStatPoints
    //     ..equipment.clear()
    //     ..equipment.addAll(character.equipment)
    //     ..isDead = character.isDead
    //     ..deathRecoveryUntil = character.deathRecoveryUntil,
    // );

    // _characterBox.put(_characterKey, _character.writeToBuffer());
  }

  Character? getCharacter() {
    final raw = _characterBox.get(_characterKey);
    if (raw == null) {
      return null;
    }
    final character = raw == null ? null : Character()
      ?..mergeFromBuffer(raw);
    return character;
  }

  void clear() {
    _characterBox.clear();
  }
}
