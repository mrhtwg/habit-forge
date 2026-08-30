import 'package:habit_forge_app/core/network/network_firebase_impl.dart';
import 'package:habit_forge_app/core/network/network_hive_impl.dart';
import 'package:habit_forge_app/core/network/network_registry.dart';
import 'package:habit_forge_app/core/network/network_server_impl.dart';

void registerNetworkMode(NetworkMode mode) {
  switch (mode) {
    case NetworkMode.hive:
      NetworkRegistry.register(NetworkHiveImpl());
      break;
    case NetworkMode.firebase:
      NetworkRegistry.register(NetworkFirebaseImpl());
      break;
    case NetworkMode.server:
      NetworkRegistry.register(NetworkServerImpl());
      break;
  }
}

enum NetworkMode { hive, firebase, server }
