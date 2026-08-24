class CharacterClass {
  static const warrior = CharacterClass._('warrior');
  static const mage = CharacterClass._('mage');
  static const ranger = CharacterClass._('ranger');
  final String name;
  const CharacterClass._(this.name);
  @override
  String toString() => name;
}

class CharacterModel {
  final String id;
  final CharacterClass characterClass;
  final int level;
  final int currentExp;
  final int currentHp;
  final CharacterStats baseStats;
  final int availableStatPoints;
  final Map<String, String> equipment;
  final bool isDead;
  final DateTime? deathRecoveryUntil;

  const CharacterModel({
    required this.id,
    required this.characterClass,
    this.level = 1,
    this.currentExp = 0,
    this.currentHp = 100,
    required this.baseStats,
    this.availableStatPoints = 0,
    this.equipment = const {},
    this.isDead = false,
    this.deathRecoveryUntil,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) => CharacterModel(
        id: json['id'] as String,
        characterClass: CharacterClass._(json['class']),
        level: json['level'] as int? ?? 1,
        currentExp: json['exp'] as int? ?? 0,
        currentHp: json['hp'] as int? ?? 100,
        baseStats: CharacterStats.fromJson(json['stats'] as Map<String, dynamic>? ?? {}),
        availableStatPoints: json['statPoints'] as int? ?? 0,
        equipment: (json['equipment'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as String)) ?? {},
        isDead: json['dead'] as bool? ?? false,
        deathRecoveryUntil: json['recoveryUntil'] != null ? DateTime.parse(json['recoveryUntil'] as String) : null,
      );

  CharacterModel copyWith({
    String? id,
    CharacterClass? characterClass,
    int? level,
    int? currentExp,
    int? currentHp,
    CharacterStats? baseStats,
    int? availableStatPoints,
    Map<String, String>? equipment,
    bool? isDead,
    DateTime? deathRecoveryUntil,
  }) =>
      CharacterModel(
        id: id ?? this.id,
        characterClass: characterClass ?? this.characterClass,
        level: level ?? this.level,
        currentExp: currentExp ?? this.currentExp,
        currentHp: currentHp ?? this.currentHp,
        baseStats: baseStats ?? this.baseStats,
        availableStatPoints: availableStatPoints ?? this.availableStatPoints,
        equipment: equipment ?? this.equipment,
        isDead: isDead ?? this.isDead,
        deathRecoveryUntil: deathRecoveryUntil ?? this.deathRecoveryUntil,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'class': characterClass.name,
        'level': level,
        'exp': currentExp,
        'hp': currentHp,
        'stats': baseStats.toJson(),
        'statPoints': availableStatPoints,
        'equipment': equipment,
        'dead': isDead,
        'recoveryUntil': deathRecoveryUntil?.toIso8601String(),
      };
}

class CharacterStats {
  final int strength;
  final int intelligence;
  final int agility;
  final int defense;
  final int vitality;
  final int luck;

  const CharacterStats({
    this.strength = 10,
    this.intelligence = 10,
    this.agility = 10,
    this.defense = 10,
    this.vitality = 10,
    this.luck = 10,
  });

  factory CharacterStats.fromJson(Map<String, dynamic> json) => CharacterStats(
        strength: json['str'] as int? ?? 10,
        intelligence: json['int'] as int? ?? 10,
        agility: json['agi'] as int? ?? 10,
        defense: json['def'] as int? ?? 10,
        vitality: json['vit'] as int? ?? 10,
        luck: json['luk'] as int? ?? 10,
      );

  CharacterStats copyWith({
    int? strength,
    int? intelligence,
    int? agility,
    int? defense,
    int? vitality,
    int? luck,
  }) =>
      CharacterStats(
        strength: strength ?? this.strength,
        intelligence: intelligence ?? this.intelligence,
        agility: agility ?? this.agility,
        defense: defense ?? this.defense,
        vitality: vitality ?? this.vitality,
        luck: luck ?? this.luck,
      );

  Map<String, dynamic> toJson() => {
        'str': strength,
        'int': intelligence,
        'agi': agility,
        'def': defense,
        'vit': vitality,
        'luk': luck,
      };
}

class EquipSlot {
  static const weapon = EquipSlot._('weapon');
  static const helmet = EquipSlot._('helmet');
  static const armor = EquipSlot._('armor');
  static const accessory = EquipSlot._('accessory');
  final String name;
  const EquipSlot._(this.name);
  @override
  String toString() => name;
}
