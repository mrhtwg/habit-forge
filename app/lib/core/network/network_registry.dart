import 'package:habit_forge_app/core/network/network_interface.dart';

class NetworkRegistry {
  static NetworkInterface? _instance;

  static NetworkInterface get ins {
    final instance = _instance;
    if (instance == null) {
      throw StateError('NetworkInterface has not been registered.');
    }
    return instance;
  }

  NetworkRegistry._();

  static void register(NetworkInterface interface) {
    _instance = interface;
  }
}
