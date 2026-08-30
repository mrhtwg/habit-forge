import 'dart:convert';

import 'package:hive/hive.dart';

class BaseBox {
  final _json = const JsonCodec();

  T? readJson<T>(Box box, String key, T Function(Map<String, dynamic>) fromJson) {
    final raw = box.get(key);
    if (raw == null) {
      return null;
    }
    if (raw is Map<String, dynamic>) {
      return fromJson(raw);
    }
    final map = _decodeMap(raw);
    if (map == null) return null;
    return fromJson(map);
  }

  /// Decodes a stored JSON value into a map, unwrapping the legacy
  /// double-encoded string format (written by the old `writeToJson()` path).
  Map<String, dynamic>? _decodeMap(String raw) {
    try {
      final decoded = _json.decode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      // Legacy format: the value was json-encoded again after writeToJson()
      // returned a JSON string, so decoding yields a String of JSON.
      final inner = _json.decode(decoded as String);
      return inner is Map<String, dynamic> ? inner : null;
    } catch (_) {
      return null;
    }
  }
}
