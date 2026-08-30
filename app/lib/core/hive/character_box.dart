import 'package:fixnum/fixnum.dart';
import 'package:habit_forge_app/generated/protos/character/v1/character.pb.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class CharacterBox {
  static CharacterBox? _instance;
  static CharacterBox get ins {
    if (_instance == null) {
      _instance = CharacterBox._();
    }
    return _instance!;
  }

  final _boxKey = 'characterBox';
  final _characterKey = 'character';

  late Box _characterBox;
  CharacterBox._();

  Future<Character> createCharacter(CharacterClass characterClass) async {
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

  Future<Character?> getCharacter() async {
    final raw = _characterBox.get(_characterKey);
    if (raw == null) {
      return null;
    }
    final character = raw == null ? null : Character()
      ?..mergeFromBuffer(raw);
    return character;
  }

  Future init() async {
    _characterBox = await Hive.openBox(_boxKey);
  }
}
