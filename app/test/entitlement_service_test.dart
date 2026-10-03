import 'package:flutter_test/flutter_test.dart';
import 'package:habit_forge_app/core/services/entitlement_service.dart';
import 'package:habit_forge_app/core/services/subscription_tier.dart';

/// The server entitlement is the one thing standing between a paying user and a
/// patched APK, so its rules are pinned here: a document that is revoked, lapsed
/// or simply malformed must never read as premium.
void main() {
  final now = DateTime(2026, 9, 29, 12);
  final nowMs = now.millisecondsSinceEpoch;
  final inADay = nowMs + 86400000;

  test('no documents means free', () {
    expect(EntitlementService.tierOf(const [], now: now), isNull);
  });

  test('picks the highest active tier when several are owned', () {
    final tier = EntitlementService.tierOf(
      [
        {'tier': 'monthly', 'active': true, 'expiresAt': inADay},
        {'tier': 'lifetime', 'active': true, 'expiresAt': 0},
        {'tier': 'yearly', 'active': true, 'expiresAt': inADay},
      ],
      now: now,
    );
    expect(tier, SubscriptionTier.lifetime);
  });

  test('yearly outranks monthly (yearly exclusives follow the tier)', () {
    final tier = EntitlementService.tierOf(
      [
        {'tier': 'monthly', 'active': true, 'expiresAt': inADay},
        {'tier': 'yearly', 'active': true, 'expiresAt': inADay},
      ],
      now: now,
    );
    expect(tier, SubscriptionTier.yearly);
    expect(tier!.hasYearlyExtras, isTrue);
  });

  test('a revoked or refunded document does not count', () {
    expect(EntitlementService.tierOf([{'tier': 'lifetime', 'active': false}], now: now), isNull);
  });

  test('a lapsed subscription stops counting without a store notification', () {
    expect(EntitlementService.tierOf([{'tier': 'monthly', 'active': true, 'expiresAt': nowMs - 1}], now: now), isNull);
  });

  test('lifetime never expires, even with a stale expiry field', () {
    expect(
      EntitlementService.tierOf([{'tier': 'lifetime', 'active': true, 'expiresAt': 1}], now: now),
      SubscriptionTier.lifetime,
    );
  });

  test('unknown or empty documents are ignored instead of throwing', () {
    expect(
      EntitlementService.tierOf(
        [
          {'tier': 'ultra', 'active': true},
          {'active': true},
          const <String, dynamic>{},
        ],
        now: now,
      ),
      isNull,
    );
    // A subscription without an expiry is trusted until the server replaces it
    // (the verification Function always writes one for subscriptions).
    expect(EntitlementService.tierOf([{'tier': 'monthly', 'active': true}], now: now), SubscriptionTier.monthly);
  });

  test('the request id is deterministic and fits a document id', () {
    final receipt = 'a' * 5000;
    final id = EntitlementService.requestIdFor(store: 'google_play', purchaseToken: receipt);
    expect(id.length, lessThan(64), reason: 'a Play token is far too long to use as-is');
    expect(id, startsWith('google_play-'));
    expect(
      id,
      EntitlementService.requestIdFor(store: 'google_play', purchaseToken: receipt),
      reason: 'retrying the same receipt must reuse the same request',
    );
    expect(id, isNot(EntitlementService.requestIdFor(store: 'google_play', purchaseToken: '${receipt}b')));
    expect(id, isNot(EntitlementService.requestIdFor(store: 'apple_app_store', purchaseToken: receipt)));
  });
}
