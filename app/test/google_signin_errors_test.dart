import 'package:flutter_test/flutter_test.dart';
import 'package:habit_forge_app/core/services/google_signin_errors.dart';

/// Classifying the Android Credential Manager's very confusing failures.
///
/// On a real device (Android 17, google_sign_in 7.2.0) a sign-in that could not
/// reach Google arrived as:
///
///     code: GoogleSignInExceptionCode.canceled
///     message: [16] Account reauth failed.
///
/// and the GMS log underneath said `[AccountReauth_flowRunner] Flow failed.` /
/// `ctst: [7] Network error.`. Getting this wrong is expensive in both
/// directions: treat it as a dismissal and the player sees *nothing* while
/// sign-in is quietly broken; treat every dismissal as an error and they get a
/// red toast for tapping outside the sheet.
void main() {
  group('dismissals are not errors', () {
    test('the Android Credential Manager cancellation is a dismissal', () {
      expect(
        GoogleSignInErrors.classify(
          'com.habitforge.habitforge:2616a192: onCancelled at PHASE_CLIENT_ALREADY_HIDDEN',
        ),
        GoogleSignInFailure.dismissed,
      );
    });

    test('plugin codes for "nothing to report" are dismissals', () {
      for (final code in ['canceled', 'interrupted', 'uiUnavailable']) {
        expect(GoogleSignInErrors.classify('anything', code: code), GoogleSignInFailure.dismissed, reason: code);
      }
    });

    test('a bare platform exception with a cancel code is a dismissal', () {
      expect(
        GoogleSignInErrors.classify('PlatformException(sign_in_canceled)', code: 'sign_in_canceled'),
        GoogleSignInFailure.dismissed,
      );
      expect(GoogleSignInErrors.classify('GetCredentialCancellationException'), GoogleSignInFailure.dismissed);
    });

    test('description and details are searched too', () {
      expect(
        GoogleSignInErrors.classify(null, code: 'unknown', description: 'onCanceled at PHASE_...'),
        GoogleSignInFailure.dismissed,
      );
      expect(
        GoogleSignInErrors.classify(null, code: 'unknown', details: 'USER_CANCELED'),
        GoogleSignInFailure.dismissed,
      );
    });
  });

  group('Google being unreachable is surfaced, not swallowed', () {
    test('the observed real-device failure is classified as a connectivity problem', () {
      final failure = GoogleSignInErrors.classify(
        null,
        code: 'canceled',
        description: '[16] Account reauth failed.',
      );
      expect(failure, GoogleSignInFailure.googleServicesUnreachable);
      expect(
        GoogleSignInErrors.isCancel(null, code: 'canceled', description: '[16] Account reauth failed.'),
        isFalse,
        reason: 'the player must be told, not shown nothing',
      );
      expect(
        GoogleSignInErrors.needsGoogleConnectivity(null, code: 'canceled', description: '[16] Account reauth failed.'),
        isTrue,
      );
    });

    test('the underlying network error from the GMS log is recognised too', () {
      expect(GoogleSignInErrors.classify('[7] Network error.'), GoogleSignInFailure.googleServicesUnreachable);
    });

    test('an explicit dismissal still wins when both are present', () {
      expect(
        GoogleSignInErrors.classify('onCancelled at PHASE_CLIENT_ALREADY_HIDDEN [16] Account reauth failed.'),
        GoogleSignInFailure.dismissed,
      );
    });
  });

  group('real failures stay visible', () {
    test('configuration problems are reported as errors', () {
      expect(
        GoogleSignInErrors.classify(
          'PlatformException(10: DEVELOPER_ERROR)',
          code: 'clientConfigurationError',
          description: 'serverClientId must be provided on Android',
        ),
        GoogleSignInFailure.other,
      );
    });

    test('unknown bracketed codes are errors, not connectivity problems', () {
      expect(GoogleSignInErrors.classify('[28444] Something specific happened'), GoogleSignInFailure.other);
    });

    test('an empty or unrelated error is not swallowed', () {
      expect(GoogleSignInErrors.classify(null), GoogleSignInFailure.other);
      expect(GoogleSignInErrors.classify('no credential available'), GoogleSignInFailure.other);
      expect(
        GoogleSignInErrors.classify('Firebase not configured', code: 'failed-precondition'),
        GoogleSignInFailure.other,
      );
    });
  });
}
