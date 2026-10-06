import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/services/google_signin_errors.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Result of a Google sign-in / link attempt from Settings.
class GoogleLinkResult {
  final String? error;
  final bool canceled;

  /// True when the Google credential belonged to an account that already
  /// existed (anonymous upgrade failed with credential-already-in-use).
  final bool usedExistingAccount;

  /// True when the failure was Google's *account service* being unreachable
  /// (`[16] Account reauth failed.` / `[7] Network error.`). The player needs a
  /// working route to Google — a VPN on a blocked network — rather than a
  /// different account.
  final bool googleServicesUnreachable;

  const GoogleLinkResult({
    this.error,
    this.canceled = false,
    this.usedExistingAccount = false,
    this.googleServicesUnreachable = false,
  });

  const GoogleLinkResult.canceled() : this(canceled: true);
  const GoogleLinkResult.linked() : this();
  const GoogleLinkResult.existing() : this(usedExistingAccount: true);
  GoogleLinkResult.failed(String message) : this(error: message);
  GoogleLinkResult.noGoogleConnectivity(String message) : this(error: message, googleServicesUnreachable: true);
}

/// Firebase Auth wrapper.
class FirebaseAuthService extends GetxService {
  static FirebaseAuthService get to => Get.find();

  bool _available = false;

  /// True while a Google sheet is on screen. Credential Manager shows one at a
  /// time, so a duplicate request has to be ignored rather than started.
  bool _googleFlowInFlight = false;

  User? get currentUser => _available ? _auth.currentUser : null;
  bool get isAvailable => _available;
  bool get isAnonymous => _available && (_auth.currentUser?.isAnonymous ?? false);

  FirebaseAuth get _auth => FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  Future<void> initGoogleSignIn({required String serverClientId}) async {
    await _googleSignIn.initialize(serverClientId: serverClientId);
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

  /// Settings → Firebase **and** the startup gate: Google picker only.
  ///
  /// Two guards matter here, both learned the hard way on Android:
  ///
  ///  * **one flow at a time** — Credential Manager can only show one selector, so
  ///    a second request while the first sheet is closing comes back as
  ///    `onCancelled at PHASE_CLIENT_ALREADY_HIDDEN`;
  ///  * **cancellation is not an error** — dismissing the sheet must not produce a
  ///    red toast (see [GoogleSignInErrors]).
  Future<GoogleLinkResult> linkOrSignInWithGoogle() async {
    if (!_available) return GoogleLinkResult.failed('Firebase not configured');
    if (_googleFlowInFlight) {
      Log.d('Google Sign-In already in flight — ignoring the duplicate request');
      return const GoogleLinkResult.canceled();
    }
    _googleFlowInFlight = true;
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
      debugPrint("==== GoogleSignIn Exception ====");
      debugPrint("code: ${e.code}");
      debugPrint("message: ${e.description}");
      debugPrint("details: ${e.details}");
      final failure = GoogleSignInErrors.classify(
        e,
        code: e.code.name,
        description: e.description,
        details: e.details,
      );
      switch (failure) {
        case GoogleSignInFailure.dismissed:
          Log.d('Google Sign-In dismissed (${e.code.name}): ${e.description}');
          return const GoogleLinkResult.canceled();
        case GoogleSignInFailure.googleServicesUnreachable:
          Log.w('Google Sign-In blocked: Google account services unreachable (${e.description})');
          return GoogleLinkResult.noGoogleConnectivity(e.description ?? e.code.name);
        case GoogleSignInFailure.other:
          return GoogleLinkResult.failed('Google sign-in failed: ${e.code.name}');
      }
    } on FirebaseAuthException catch (e) {
      return GoogleLinkResult.failed(_mapError(e));
    } catch (e) {
      // The sheet can also surface as a bare platform exception, with the real
      // reason (and its bracketed code) only in the message.
      final failure = GoogleSignInErrors.classify(e);
      switch (failure) {
        case GoogleSignInFailure.dismissed:
          Log.d('Google Sign-In dismissed: $e');
          return const GoogleLinkResult.canceled();
        case GoogleSignInFailure.googleServicesUnreachable:
          Log.w('Google Sign-In blocked: $e');
          return GoogleLinkResult.noGoogleConnectivity(e.toString());
        case GoogleSignInFailure.other:
          return GoogleLinkResult.failed(e.toString());
      }
    } finally {
      _googleFlowInFlight = false;
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
    // Same one-sheet rule as the sign-in flow: two Google prompts at once make
    // Android answer one of them with PHASE_CLIENT_ALREADY_HIDDEN.
    if (_googleFlowInFlight) {
      return 'Another Google prompt is already open — try again in a moment.';
    }
    _googleFlowInFlight = true;

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
      if (GoogleSignInErrors.needsGoogleConnectivity(
        e,
        code: e.code.name,
        description: e.description,
        details: e.details,
      )) {
        return 'Reauthentication needs a connection to Google (${e.description})';
      }
      if (GoogleSignInErrors.isCancel(e, code: e.code.name, description: e.description, details: e.details)) {
        return 'Reauthentication canceled';
      }
      return 'Google sign-in failed: ${e.code.name}';
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (e) {
      // A dismissed sheet can arrive as a bare platform exception; report it as a
      // cancellation instead of leaking "…onCancelled at PHASE_…" to the player.
      if (GoogleSignInErrors.isCancel(e)) return 'Reauthentication canceled';
      return e.toString();
    } finally {
      _googleFlowInFlight = false;
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
