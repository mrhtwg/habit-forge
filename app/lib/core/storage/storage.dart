import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/services/hive_service.dart';
import 'package:habit_forge_app/core/storage/firebase_storage.dart';
import 'package:habit_forge_app/core/storage/server_storage.dart';
import 'package:habit_forge_app/core/storage/storage_service.dart';

/// Creates the storage implementation for the active mode
/// (see `EnvConstants.storageMode`):
///  - hive     → local Hive storage
///  - firebase → Firestore storage
///  - server   → gRPC to the self-hosted backend
abstract class Storage {
  Storage._();

  static Future<StorageService> create() async {
    switch (EnvConstants.storageMode) {
      case EnvConstants.firebase:
        return FirebaseStorage();
      case EnvConstants.server:
        return ServerStorage();
      default:
        return HiveService();
    }
  }
}
