import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Firebase Auth wrapper.
/// If Firebase not configured (google-services.json missing/invalid),
/// all methods fall back gracefully and return an error string.
class FirebaseAuthService extends GetxService {
  static FirebaseAuthService get to => Get.find();

  bool _available = false;

  User? get currentUser => _auth.currentUser;
  bool get isAvailable => _available;

  // Lazily resolve Firebase/Google instances so constructor doesn't
  // throw before Firebase.initializeApp() completes.
  FirebaseAuth get _auth => FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  /// Init Google Sign-In (call after Firebase is ready).
  Future<void> initGoogleSignIn() async {
    if (!_available) return;
    try {
      await _googleSignIn.initialize();
    } catch (_) {
      // Google sign-in won't work — that's OK
    }
  }

  // ── Apple ──

  Future<String?> loginWithApple() async {
    if (!_available) return 'Firebase not configured';
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
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

  // ── Google ──

  Future<String?> loginWithGoogle() async {
    if (!_available) return 'Firebase not configured';
    try {
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) return 'No ID token received from Google';

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await _auth.signInWithCredential(credential);
      return null;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      return 'Google sign-in failed: ${e.code.name}';
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (e) {
      return e.toString();
    }
  }

  /// Call after Firebase.initializeApp() succeeds.
  void markAvailable() => _available = true;

  // ── Email/Password ──

  Future<String?> registerWithEmail(String email, String password) async {
    if (!_available) return 'Firebase not configured';
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    } catch (e) {
      return e.toString();
    }
  }

  // ── Logout ──

  Future<void> signOut() async {
    if (!_available) return;
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // ── Error mapping ──

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
