import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/network/network_bootstrap.dart';
import 'package:habit_forge_app/core/network/network_firebase_impl.dart';
import 'package:habit_forge_app/core/network/network_hive_impl.dart';
import 'package:habit_forge_app/core/network/network_interface.dart';
import 'package:habit_forge_app/core/network/network_server_impl.dart';

/// Creates the storage implementation for the active mode
/// (see `EnvConstants.storageMode`):
///  - hive     → local Hive storage
///  - firebase → Firestore storage
///  - server   → gRPC to the self-hosted backend
abstract class Storage {
  Storage._();

  static Future<NetworkInterface> create() async {
    switch (EnvConstants.networkMode) {
      case NetworkMode.firebase:
        return NetworkFirebaseImpl();
      case NetworkMode.server:
        return NetworkServerImpl();
      default:
        return NetworkHiveImpl();
    }
  }
}
