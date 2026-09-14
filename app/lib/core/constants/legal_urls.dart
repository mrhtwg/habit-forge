/// Official legal document URLs (placeholders until the site is live).
class LegalUrls {
  LegalUrls._();

  /// User agreement / Terms of Service.
  static const termsOfService = 'https://habitforge.app/terms';

  /// Privacy Policy.
  static const privacyPolicy = 'https://habitforge.app/privacy';
}

enum LegalDocType { terms, privacy }

extension LegalDocTypeX on LegalDocType {
  String get route => switch (this) {
        LegalDocType.terms => '/legal/terms',
        LegalDocType.privacy => '/legal/privacy',
      };

  String get url => switch (this) {
        LegalDocType.terms => LegalUrls.termsOfService,
        LegalDocType.privacy => LegalUrls.privacyPolicy,
      };
}
