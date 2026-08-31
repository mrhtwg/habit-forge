import 'package:fixnum/fixnum.dart';
import 'package:habit_forge_app/core/di/injection_container.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

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

  Character createCharacter(CharacterClass characterClass) {
    Character character = Character()
      ..id = Uuid().v4()
      ..characterClass = characterClass
      ..level = 1
      ..currentExp = Int64(0)
      ..currentHp = 100
      ..baseStats = CharacterStats()
      ..availableStatPoints = 0;
    _characterBox.put(_characterKey, character.writeToBuffer());
    return character;
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
