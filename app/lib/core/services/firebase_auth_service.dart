import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Result of a Google sign-in / link attempt from Settings.
class GoogleLinkResult {
  final String? error;
  final bool canceled;

  /// True when the Google credential belonged to an account that already
  /// existed (anonymous upgrade failed with credential-already-in-use).
  final bool usedExistingAccount;

  const GoogleLinkResult({
    this.error,
    this.canceled = false,
    this.usedExistingAccount = false,
  });

  const GoogleLinkResult.canceled() : this(canceled: true);
  const GoogleLinkResult.linked() : this();
  const GoogleLinkResult.existing() : this(usedExistingAccount: true);
  GoogleLinkResult.failed(String message) : this(error: message);
}

/// Firebase Auth wrapper.
class FirebaseAuthService extends GetxService {
  static FirebaseAuthService get to => Get.find();

  bool _available = false;

  User? get currentUser => _available ? _auth.currentUser : null;
  bool get isAvailable => _available;
  bool get isAnonymous => _available && (_auth.currentUser?.isAnonymous ?? false);

  FirebaseAuth get _auth => FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  Future<void> initGoogleSignIn() async {
    if (!_available) return;
    try {
      await _googleSignIn.initialize();
    } catch (_) {}
  }

  void markAvailable() => _available = true;

  /// Ensures a Firebase session exists so Firestore game data can be written
  /// without showing a login page (anonymous guest).
  ///
  /// Prefer [FirebaseSession.useLocalBackend] for cold start / Settings-cancel
  /// paths — anonymous Auth is no longer used at splash.
  @Deprecated('Use FirebaseSession.useLocalBackend instead of anonymous Auth')
  Future<String?> ensureAnonymousSession() async {
    if (!_available) return 'Firebase not configured';
    if (_auth.currentUser != null) return null;
    try {
      await _auth.signInAnonymously();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (e) {
      return e.toString();
    }
  }

  /// Clears Firebase + Google sessions. Caller should switch to local Hive.
  Future<void> restoreAnonymousSession() async {
    await signOut();
  }

  /// Settings Google entry: link anonymous → Google when possible; otherwise
  /// sign into the existing Google account (caller handles overwrite confirm).
  Future<GoogleLinkResult> linkOrSignInWithGoogle() async {
    if (!_available) return GoogleLinkResult.failed('Firebase not configured');
    try {
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) return GoogleLinkResult.failed('No ID token received from Google');

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final user = _auth.currentUser;

      if (user != null && user.isAnonymous) {
        try {
          await user.linkWithCredential(credential);
          return const GoogleLinkResult.linked();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use' || e.code == 'email-already-in-use') {
            await _auth.signInWithCredential(credential);
            return const GoogleLinkResult.existing();
          }
          return GoogleLinkResult.failed(_mapError(e));
        }
      }

      final signedIn = await _auth.signInWithCredential(credential);
      if (signedIn.additionalUserInfo?.isNewUser == true) {
        return const GoogleLinkResult.linked();
      }
      return const GoogleLinkResult.existing();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const GoogleLinkResult.canceled();
      }
      return GoogleLinkResult.failed('Google sign-in failed: ${e.code.name}');
    } on FirebaseAuthException catch (e) {
      return GoogleLinkResult.failed(_mapError(e));
    } catch (e) {
      return GoogleLinkResult.failed(e.toString());
    }
  }

  Future<String?> loginWithApple() async {
    if (!_available) return 'Firebase not configured';
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      final credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await _auth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> loginWithEmail(String email, String password) async {
    if (!_available) return 'Firebase not configured';
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> registerWithEmail(String email, String password) async {
    if (!_available) return 'Firebase not configured';
    try {
      final user = _auth.currentUser;
      if (user != null && user.isAnonymous) {
        final cred = EmailAuthProvider.credential(email: email, password: password);
        await user.linkWithCredential(cred);
        return null;
      }
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    if (!_available) return;
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  /// Reauthenticates with Google, asks the trusted Cloud Function to recursively
  /// delete cloud data and Firebase Auth, then clears the local provider session.
  Future<String?> deleteAccount() async {
    if (!_available) return 'Firebase not configured';
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return 'No linked account';
    if (!user.providerData.any((provider) => provider.providerId == GoogleAuthProvider.PROVIDER_ID)) {
      return 'This account must be deleted after signing in with Google.';
    }

    try {
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) return 'No ID token received from Google';

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await user.reauthenticateWithCredential(credential);
      final freshToken = await user.getIdToken(true);
      if (freshToken == null || freshToken.isEmpty) return 'Unable to verify your identity';

      final projectId = Firebase.app().options.projectId;
      final uri = Uri.parse('https://us-central1-$projectId.cloudfunctions.net/deleteAccount');
      final client = HttpClient();
      try {
        final request = await client.postUrl(uri).timeout(const Duration(seconds: 15));
        request.headers.contentType = ContentType.json;
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $freshToken');
        request.write(jsonEncode({'data': <String, Object?>{}}));
        final response = await request.close().timeout(const Duration(seconds: 120));
        final body = await utf8.decoder.bind(response).join();
        final payload = body.isEmpty ? const <String, dynamic>{} : jsonDecode(body) as Map<String, dynamic>;
        if (response.statusCode != HttpStatus.ok || payload['error'] != null) {
          final error = payload['error'];
          final message = error is Map ? error['message']?.toString() : null;
          return message ?? 'Account deletion failed';
        }
      } finally {
        client.close(force: true);
      }

      await _auth.signOut();
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      return null;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return 'Reauthentication canceled';
      return 'Google sign-in failed: ${e.code.name}';
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (e) {
      return e.toString();
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'email-already-in-use':
        return 'Email already registered';
      case 'weak-password':
        return 'Password too weak (min 6 characters)';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'Account disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'account-exists-with-different-credential':
        return 'Account exists with a different sign-in method.';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
