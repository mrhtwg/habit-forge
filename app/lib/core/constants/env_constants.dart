class EnvConstants {
  // Data/backend mode selected by --dart-define-from-file=env/<mode>.json.
  // One of: 'hive' (default), 'firebase', 'server'.
  static const String environment = String.fromEnvironment('env', defaultValue: 'hive');

  /// Where game data is stored: 'hive' (local on-device), 'firebase', or 'server'.
  static const String storageMode = String.fromEnvironment('storage', defaultValue: environment);

  /// Auth backend: 'local' (guest/mock), 'firebase', or 'server'.
  static const String authMode = String.fromEnvironment('auth', defaultValue: storageMode);

  /// Base URL of the self-hosted backend (used when storage == 'server').
  static const String apiBaseUrl = String.fromEnvironment('apiUrl', defaultValue: 'http://localhost:8080');

  static const String hive = 'hive';
  static const String firebase = 'firebase';
  static const String server = 'server';

  /// Whether game data lives in local Hive storage.
  static bool isHive() => storageMode == hive;

  /// Whether Firebase is used for cloud data and auth.
  static bool isFirebase() => storageMode == firebase;

  /// Whether the self-hosted backend is used for data and auth.
  static bool isServer() => storageMode == server;

  /// Whether auth runs against the local mock (guest mode).
  static bool isAuthLocal() => authMode == 'local';

  /// Whether auth runs against Firebase.
  static bool isAuthFirebase() => authMode == firebase;

  /// Whether auth runs against the self-hosted backend.
  static bool isAuthServer() => authMode == server;
}
