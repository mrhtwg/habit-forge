import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/constants/env_constants.dart';
import 'package:habit_forge_app/core/services/subscription_tier.dart';

/// Server-owned premium entitlement (`docs/data-ledger-plan.md` §3.3).
///
/// The plan's second rule: 订阅权益改成"服务端说了算". In
/// `--dart-define=entitlement=server` builds the tier comes from
/// `users/{uid}/entitlement/{store}` — a document only Cloud Functions can
/// write, because `firebase/firestore.rules` denies every client write to that
/// subcollection. So patching the app or editing local files no longer buys
/// premium, which is the entire point: premium unlockers are a real business.
///
/// This service only ever *reads*. Verification is requested by writing to
/// `users/{uid}/purchaseRequests/{requestId}` (create-only for clients); the
/// Cloud Function re-checks the receipt with the store and is the sole writer of
/// the entitlement.
///
/// The default build (`entitlement=local`) keeps the pre-ledger behaviour
/// (entitlement cached in `shared_preferences`), because switching authority
/// requires the Function to be deployed and the Blaze plan to be enabled.
class EntitlementService extends GetxService {
  static EntitlementService get to => Get.find();

  /// Highest active tier the server reports; null while free, signed out or
  /// still loading.
  final serverTier = Rxn<SubscriptionTier>();
  final isListening = false.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  /// Whether the server is the authority for premium in this build.
  static bool get isServerAuthoritative => EnvConstants.usesServerEntitlement();

  /// Subscribes to the entitlement documents of the signed-in user.
  ///
  /// Called whenever a cloud identity becomes active (see `FirebaseSession`).
  /// Local-first and offline play are unaffected: no identity means no premium
  /// claim to verify, and Firestore serves the last known entitlement from its
  /// own cache while offline.
  Future<void> start() async {
    if (!isServerAuthoritative) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      Log.w('entitlement=server but no cloud identity yet — premium stays unverified');
      _set(null);
      return;
    }
    await _sub?.cancel();
    _sub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('entitlement')
        .snapshots()
        .listen(
          (snapshot) => _set(tierOf(snapshot.docs.map((doc) => doc.data()))),
          onError: (Object error) => Log.w('entitlement listener: $error'),
        );
    isListening.value = true;
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    isListening.value = false;
    _set(null);
  }

  @override
  void onClose() {
    unawaited(stop());
    super.onClose();
  }

  void _set(SubscriptionTier? tier) {
    if (serverTier.value == tier) return;
    serverTier.value = tier;
    Log.d('server entitlement → ${tier?.name ?? 'free'}');
  }

  /// Asks the server to verify a store purchase.
  ///
  /// The client can only *request*: the request document is created with a
  /// deterministic id derived from the receipt, so retrying is a no-op (a second
  /// `set` would be an update, which the rules deny — that is the "request
  /// already in flight" case, reported as true). Nothing here can grant premium;
  /// the Function decides after checking with the store.
  ///
  /// Returns false when the request could not be written at all.
  Future<bool> requestVerification({
    required String store,
    required String productId,
    required String purchaseToken,
    String orderId = '',
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      Log.w('purchase verification needs a signed-in user (FirebaseSession first)');
      return false;
    }
    if (purchaseToken.isEmpty) {
      Log.w('purchase has no receipt to verify (productId=$productId)');
      return false;
    }
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('purchaseRequests')
          .doc(requestIdFor(store: store, purchaseToken: purchaseToken))
          .set(<String, Object>{
        'store': store,
        'productId': productId,
        'purchaseToken': purchaseToken,
        'orderId': orderId,
        'requestedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } on FirebaseException catch (e) {
      // permission-denied == the document already exists (create-only rules).
      Log.w('verification request for $productId: ${e.code}');
      return e.code == 'permission-denied' || e.code == 'already-exists';
    } catch (e) {
      Log.w('verification request for $productId failed: $e');
      return false;
    }
  }

  /// Deterministic request id: one verification per receipt, and re-asking for
  /// the same receipt cannot flood the Function.
  static String requestIdFor({required String store, required String purchaseToken}) =>
      '$store-${_fingerprint(purchaseToken)}';

  /// Small stable hash of the receipt — the token itself (`serverVerificationData`
  /// can be a multi-KB Play token or an iOS receipt blob) is too long for a
  /// document id.
  static String _fingerprint(String value) {
    var hash = 0x811C9DC5;
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  /// The highest tier that is currently active among [docs], or null for free.
  ///
  /// A document with `active: false` (revoked / refunded) never counts, and a
  /// subscription whose `expiresAt` has passed stops counting without waiting for
  /// the store to notify us — that keeps a refunded or lapsed subscription from
  /// working merely because the client never refreshed.
  static SubscriptionTier? tierOf(Iterable<Map<String, dynamic>> docs, {DateTime? now}) {
    final at = (now ?? DateTime.now()).millisecondsSinceEpoch;
    SubscriptionTier? best;
    for (final data in docs) {
      final tier = _activeTier(data, at);
      if (tier == null) continue;
      if (best == null || tier.rank > best.rank) best = tier;
    }
    return best;
  }

  static SubscriptionTier? _activeTier(Map<String, dynamic> data, int nowMs) {
    if (data['active'] == false) return null;
    final tier = switch ('${data['tier']}') {
      'monthly' => SubscriptionTier.monthly,
      'yearly' => SubscriptionTier.yearly,
      'lifetime' => SubscriptionTier.lifetime,
      _ => null,
    };
    if (tier == null) return null;
    // Lifetime is a one-time purchase and never expires; subscriptions carry the
    // end of the paid period.
    if (tier == SubscriptionTier.lifetime) return tier;
    final expiresAt = (data['expiresAt'] as num?)?.toInt() ?? 0;
    if (expiresAt <= 0) return tier;
    return expiresAt > nowMs ? tier : null;
  }
}
