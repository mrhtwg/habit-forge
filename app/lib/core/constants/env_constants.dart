import 'package:habit_forge_app/core/network/network_bootstrap.dart';

class EnvConstants {
  // Data/backend mode selected by --dart-define-from-file=env/<mode>.json.
  // One of: 'hive' (default), 'firebase', 'server'.
  static const String environment = String.fromEnvironment('env', defaultValue: 'hive');

  /// Auth backend: 'local' (guest/mock), 'firebase', or 'server'.
  static const String authMode = String.fromEnvironment('auth', defaultValue: _networkMode);

  /// Base URL of the self-hosted backend (used when storage == 'server').
  static const String apiBaseUrl = String.fromEnvironment('apiUrl', defaultValue: 'http://localhost:8080');

  /// gRPC endpoint of the self-hosted backend (server mode), host:port.
  static const String grpcUrl = String.fromEnvironment('grpcUrl', defaultValue: 'localhost:9000');

  // ── Firebase options (from env/firebase.json via --dart-define-from-file) ──
  static const String firebaseApiKey = String.fromEnvironment('apiKey', defaultValue: '');
  static const String firebaseAppId = String.fromEnvironment('appId', defaultValue: '');
  static const String firebaseMessagingSenderId = String.fromEnvironment('messagingSenderId', defaultValue: '');
  static const String firebaseProjectId = String.fromEnvironment('projectId', defaultValue: '');
  static const String firebaseStorageBucket = String.fromEnvironment('storageBucket', defaultValue: '');

  static const String hive = 'hive';

  static const String firebase = 'firebase';
  static const String server = 'server';
  static const String _networkMode = String.fromEnvironment('network', defaultValue: environment);

  /// Where game data is stored: 'hive' (local on-device), 'firebase', or 'server'.
  static NetworkMode get networkMode => switch (_networkMode) {
        'hive' => NetworkMode.hive,
        'firebase' => NetworkMode.firebase,
        'server' => NetworkMode.server,
        _ => throw ArgumentError('Invalid network mode: $_networkMode'),
      };

  /// Who owns the premium entitlement (`docs/data-ledger-plan.md` §3.3):
  /// 'local' (default — the tier is cached in shared_preferences, which a
  /// modified client or a rooted device can edit) or 'server' (the tier comes
  /// from `users/{uid}/entitlement`, written only by Cloud Functions).
  ///
  /// Store builds should switch this to 'server' once the purchase-verification
  /// Function is deployed — see `functions/README.md`. It needs the Blaze plan.
  static const String entitlement = String.fromEnvironment('entitlement', defaultValue: 'local');

  /// Whether the server is the authority for premium in this build.
  static bool usesServerEntitlement() => entitlement == 'server';

  /// Whether auth runs against Firebase.
  static bool isAuthFirebase() => authMode == firebase;

  /// Whether auth runs against the local mock (guest mode).
  static bool isAuthLocal() => authMode == 'local';

  /// Whether auth runs against the self-hosted backend.
  static bool isAuthServer() => authMode == server;

  /// Whether Firebase is used for cloud data and auth.
  static bool isFirebase() => networkMode == NetworkMode.firebase;

  /// Whether game data lives in local Hive storage.
  static bool isHive() => networkMode == NetworkMode.hive;

  /// Whether the self-hosted backend is used for data and auth.
  static bool isServer() => networkMode == NetworkMode.server;
}
