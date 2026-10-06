import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/common/utils/log.dart';
import 'package:habit_forge_app/core/services/subscription_tier.dart';

/// Server-owned premium entitlement (`docs/data-ledger-plan.md` §3.3).
///
/// The plan's second rule: 订阅权益改成"服务端说了算". The tier comes from
/// `users/{uid}/entitlement/{productId}` — documents only Cloud Functions can
/// write, because `firebase/firestore.rules` denies every client write to that
/// subcollection. So patching the app or editing local files no longer buys
/// premium, which is the entire point: premium unlockers are a real business.
///
/// This service only ever *reads*. Verification is requested by writing to
/// `users/{uid}/purchaseRequests/{requestId}` (create-only for clients); the
/// Cloud Function re-checks the receipt with the store and is the sole writer of
/// the entitlement.
///
class EntitlementService extends GetxService {
  static EntitlementService get to => Get.find();

  /// Highest active tier the server reports; null while free, signed out or
  /// still loading.
  final serverTier = Rxn<SubscriptionTier>();
  final isListening = false.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  Timer? _expiryTimer;

  /// Subscribes to the entitlement documents of the signed-in user.
  ///
  /// Called whenever a cloud identity becomes active (see `FirebaseSession`).
  /// Local-first and offline play are unaffected: no identity means no premium
  /// claim to verify, and Firestore serves the last known entitlement from its
  /// own cache while offline.
  Future<void> start() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      Log.w('no cloud identity yet — premium stays unverified');
      _set(null);
      return;
    }
    await _sub?.cancel();
    _sub = FirebaseFirestore.instance.collection('users').doc(uid).collection('entitlement').snapshots().listen(
          (snapshot) => _applyDocuments(snapshot.docs.map((doc) => doc.data()).toList()),
          onError: (Object error) => Log.w('entitlement listener: $error'),
        );
    isListening.value = true;
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _expiryTimer?.cancel();
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

  void _applyDocuments(List<Map<String, dynamic>> documents) {
    _expiryTimer?.cancel();
    _set(tierOf(documents));
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiries = documents
        .where((data) => data['active'] == true && data['tier'] != 'lifetime')
        .map((data) => (data['expiresAt'] as num?)?.toInt() ?? 0)
        .where((expiresAt) => expiresAt > now)
        .toList();
    if (expiries.isEmpty) return;
    expiries.sort();
    _expiryTimer = Timer(Duration(milliseconds: expiries.first - now + 1000), () => _applyDocuments(documents));
  }

  /// Asks the server to verify a store purchase.
  ///
  /// The client can only *request*. Every attempt gets a new document while the
  /// Function enforces purchase-token uniqueness globally, so transient backend
  /// failures remain retryable without allowing receipt replay.
  Future<PurchaseVerificationStatus> requestVerification({
    required String store,
    required String productId,
    required String purchaseToken,
    String orderId = '',
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      Log.w('purchase verification needs a signed-in user (FirebaseSession first)');
      return PurchaseVerificationStatus.failed;
    }
    if (purchaseToken.isEmpty) {
      Log.w('purchase has no receipt to verify (productId=$productId)');
      return PurchaseVerificationStatus.failed;
    }
    final requestId = requestIdFor(
      store: store,
      purchaseToken: purchaseToken,
      nonce: DateTime.now().microsecondsSinceEpoch.toString(),
    );
    final request =
        FirebaseFirestore.instance.collection('users').doc(uid).collection('purchaseRequests').doc(requestId);
    try {
      await request.set(<String, Object>{
        'store': store,
        'productId': productId,
        'purchaseToken': purchaseToken,
        'orderId': orderId,
        'requestedAt': DateTime.now().millisecondsSinceEpoch,
      });
      final snapshot = await request.snapshots().firstWhere((event) {
        final status = event.data()?['status'];
        return status == 'verified' || status == 'not_entitled' || status == 'rejected' || status == 'error';
      }).timeout(const Duration(seconds: 45));
      return switch (snapshot.data()?['status']) {
        'verified' => PurchaseVerificationStatus.verified,
        'not_entitled' || 'rejected' => PurchaseVerificationStatus.rejected,
        _ => PurchaseVerificationStatus.failed,
      };
    } on FirebaseException catch (e) {
      Log.w('verification request for $productId: ${e.code}');
      return PurchaseVerificationStatus.failed;
    } on TimeoutException {
      Log.w('verification request for $productId timed out');
      return PurchaseVerificationStatus.pending;
    } catch (e) {
      Log.w('verification request for $productId failed: $e');
      return PurchaseVerificationStatus.failed;
    }
  }

  /// SHA-256 receipt fingerprint plus a nonce. The Function's global claim is
  /// the source of idempotency; unique request ids keep transient errors retryable.
  static String requestIdFor({required String store, required String purchaseToken, String nonce = ''}) =>
      '$store-${_fingerprint(purchaseToken)}${nonce.isEmpty ? '' : '-$nonce'}';

  /// Stable Play Billing account id. The raw Firebase uid never leaves the app.
  static String accountTokenFor(String uid) => sha256.convert(utf8.encode(uid)).toString();

  /// Small stable hash of the receipt — the token itself (`serverVerificationData`
  /// can be a multi-KB Play token or an iOS receipt blob) is too long for a
  /// document id.
  static String _fingerprint(String value) => sha256.convert(utf8.encode(value)).toString();

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
    if (expiresAt <= 0) return null;
    return expiresAt > nowMs ? tier : null;
  }
}

enum PurchaseVerificationStatus { verified, rejected, pending, failed }
