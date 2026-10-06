/// Classifies Google Sign-In failures.
///
/// Android's Credential Manager reports failures in a confusing shape: the
/// *reason* lives in the description as a bracketed platform code, while the
/// exception itself is often labelled `canceled`. Observed on a real device
/// (Android 17, google_sign_in 7.2.0):
///
///     code: GoogleSignInExceptionCode.canceled
///     message: [16] Account reauth failed.
///
/// and underneath it, in the GMS log:
///
///     [AccountReauth_flowRunner] Flow failed.
///     ctst: [7] Network error.
///
/// Treating that as "the user dismissed the sheet" hides a real, actionable
/// failure — Google's own account service was unreachable, which is what a
/// blocked or throttled network produces (`accounts.google.com` dropping packets,
/// no VPN). So the classification has three outcomes, not two.
library;

/// What a Google Sign-In failure actually means.
enum GoogleSignInFailure {
  /// The user or the system dismissed the sign-in UI: nothing to report.
  dismissed,

  /// Google's account services could not be reached or re-authenticated
  /// (`[16] Account reauth failed.`, `[7] Network error.`). The player needs a
  /// network that can actually reach Google, or a VPN.
  googleServicesUnreachable,

  /// Anything else: configuration, provider mismatch, SDK errors.
  other,
}

/// Cancellation phrases seen from the Android/iOS credential UIs.
///
/// Substring matching (case-insensitive) on purpose: this is platform text we do
/// not control, and a false positive only means "stay silent", while a false
/// negative means a scary dialog about something the user did themselves.
const List<String> _cancelPhrases = <String>[
  'phase_client_already_hidden',
  'oncancelled',
  'oncanceled',
  'getcredentialcancellationexception',
  'user_canceled',
  'user_cancelled',
  'canceled',
  'cancelled',
];

/// Plugin codes that mean "nothing to report": `canceled` is the user closing
/// the sheet, `interrupted` is another credential request taking over the UI,
/// and `uiUnavailable` means the activity was not visible any more.
const List<String> _quietCodes = <String>['canceled', 'interrupted', 'uiunavailable'];

class GoogleSignInErrors {
  GoogleSignInErrors._();

  /// Phrase list, exposed for tests and logging.
  static List<String> get cancelPhrases => _cancelPhrases;

  /// Splits a failure into a [GoogleSignInFailure].
  static GoogleSignInFailure classify(
    Object? error, {
    String? code,
    String? description,
    Object? details,
  }) {
    final normalizedCode = (code ?? '').toLowerCase();
    final text = <String>[
      error?.toString() ?? '',
      description ?? '',
      details?.toString() ?? '',
    ].join(' ').toLowerCase();

    final hasCancelPhrase = _cancelPhrases.any(text.contains);
    final platformCode = RegExp(r'\[\d+\]').firstMatch(text);

    // A bracketed code is a platform failure *reason*, not a dismissal — even
    // when the plugin labels the exception "canceled".
    if (platformCode != null && !hasCancelPhrase) {
      final platform = platformCode.group(0);
      final accountService =
          text.contains('reauth') || text.contains('network error') || platform == '[16]' || platform == '[7]';
      return accountService ? GoogleSignInFailure.googleServicesUnreachable : GoogleSignInFailure.other;
    }

    if (_quietCodes.contains(normalizedCode) || normalizedCode.contains('cancel') || hasCancelPhrase) {
      return GoogleSignInFailure.dismissed;
    }
    return GoogleSignInFailure.other;
  }

  /// Whether [error] means the sign-in UI was dismissed rather than failing.
  static bool isCancel(
    Object? error, {
    String? code,
    String? description,
    Object? details,
  }) =>
      classify(error, code: code, description: description, details: details) == GoogleSignInFailure.dismissed;

  /// Whether [error] means Google's account services were unreachable.
  static bool needsGoogleConnectivity(
    Object? error, {
    String? code,
    String? description,
    Object? details,
  }) =>
      classify(error, code: code, description: description, details: details) ==
      GoogleSignInFailure.googleServicesUnreachable;
}
