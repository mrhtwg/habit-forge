import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/storage/storage_service.dart';

/// Self-hosted backend auth client (server mode).
///
/// Talks to the Go backend:
///   POST {apiBaseUrl}/api/v1/auth/login    → {token, user}
///   POST {apiBaseUrl}/api/v1/auth/register → {token, user}
///
/// Registration does NOT require email verification — the backend creates
/// the account and issues a JWT immediately.
class ServerAuthService extends GetxService {
  static ServerAuthService get to => Get.find();

  final HttpClient _client = HttpClient();

  String get apiBaseUrl => EnvConstants.apiBaseUrl;

  /// Returns an error message on failure, or null on success.
  Future<String?> loginWithEmail(String email, String password) async {
    final result = await _post('/api/v1/auth/login', {'email': email, 'password': password});
    if (result.error != null) return result.error;
    StorageService.to.saveAuthToken(result.token);
    return null;
  }

  /// Registers a new account. No email verification is required.
  /// Returns an error message on failure, or null on success.
  Future<String?> registerWithEmail(String email, String password) async {
    final result = await _post('/api/v1/auth/register', {
      'email': email,
      'password': password,
      'nickname': email.split('@').first,
    });
    if (result.error != null) return result.error;
    StorageService.to.saveAuthToken(result.token);
    return null;
  }

  /// Clears the locally stored token (server sessions are stateless JWT).
  Future<void> signOut() async {
    StorageService.to.saveAuthToken(null);
  }

  String _mapStatus(int status, String message) {
    switch (status) {
      case 400:
        return 'Invalid request: $message';
      case 401:
        return 'Invalid email or password';
      case 409:
        return message; // e.g. "email already registered"
      default:
        return message;
    }
  }

  Future<_ServerAuthResult> _post(String path, Map<String, dynamic> body) async {
    try {
      final req = await _client.postUrl(Uri.parse('$apiBaseUrl$path'));
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(body));
      final res = await req.close();
      final raw = await res.transform(utf8.decoder).join();
      final data = raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw) as Map<String, dynamic>;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return _ServerAuthResult(token: data['token'] as String?);
      }

      final message = (data['message'] as String?) ?? 'Server error (${res.statusCode})';
      return _ServerAuthResult(error: _mapStatus(res.statusCode, message));
    } catch (e) {
      return _ServerAuthResult(error: 'Cannot reach server at $apiBaseUrl ($e)');
    }
  }
}

class _ServerAuthResult {
  final String? token;
  final String? error;

  const _ServerAuthResult({this.token, this.error});
}
