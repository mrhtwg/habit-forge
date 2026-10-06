class SpKeys {
  static const String locale = 'locale';
  static const String token = 'token';
  static const String characterClass = 'character_class';
  static const String soundEnabled = 'sound_enable';
  static const String hapticEnabled = 'haptic_enable';
  /// Optional cloud identity email (hive can link without migrating data).
  static const String linkedEmail = 'linked_email';
  /// Stable id of this install's save, used to make the guest → account merge
  /// idempotent (the account records what this device already contributed).
  static const String mergeDeviceId = 'merge_device_id';
}
