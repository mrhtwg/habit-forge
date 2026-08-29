import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/interface/network_firebase_impl.dart';
import 'package:habit_forge_app/core/interface/network_hive_impl.dart';
import 'package:habit_forge_app/core/interface/network_interface.dart';
import 'package:habit_forge_app/core/interface/network_server_impl.dart';

/// Creates the storage implementation for the active mode
/// (see `EnvConstants.storageMode`):
///  - hive     → local Hive storage
///  - firebase → Firestore storage
///  - server   → gRPC to the self-hosted backend
abstract class Storage {
  Storage._();

  static Future<NetworkInterface> create() async {
    switch (EnvConstants.networkMode) {
      case EnvConstants.firebase:
        return NetworkFirebaseImpl();
      case EnvConstants.server:
        return NetworkServerImpl();
      default:
        return NetworkHiveImpl();
    }
  }
}
