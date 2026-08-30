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

  static const String hive = 'hive';

  static const String firebase = 'firebase';
  static const String server = 'server';
  static const String _networkMode = String.fromEnvironment('network', defaultValue: environment);

  /// Where game data is stored: 'hive' (local on-device), 'firebase', or 'server'.
  static get networkMode => switch (_networkMode) {
        'hive' => NetworkMode.hive,
        'firebase' => NetworkMode.firebase,
        'server' => NetworkMode.server,
        _ => throw ArgumentError('Invalid network mode: $_networkMode'),
      };

  /// Whether auth runs against Firebase.
  static bool isAuthFirebase() => authMode == firebase;

  /// Whether auth runs against the local mock (guest mode).
  static bool isAuthLocal() => authMode == 'local';

  /// Whether auth runs against the self-hosted backend.
  static bool isAuthServer() => authMode == server;

  /// Whether Firebase is used for cloud data and auth.
  static bool isFirebase() => networkMode == firebase;

  /// Whether game data lives in local Hive storage.
  static bool isHive() => networkMode == hive;

  /// Whether the self-hosted backend is used for data and auth.
  static bool isServer() => networkMode == server;
}
