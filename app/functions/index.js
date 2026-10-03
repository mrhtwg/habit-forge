/**
 * Purchase verification for HabitForge — C1 of `docs/data-ledger-plan.md` §3.3.
 *
 * Why this exists: a tier kept in the client is worth nothing. Anyone with a
 * rooted device or a patched APK could set `shared_preferences` to "lifetime",
 * and premium unlockers are an actual business. So the store receipt is checked
 * *here*, and this Function is the only writer of:
 *
 *     users/{uid}/entitlement/{productId}
 *
 * The client can only read that document (see `firebase/firestore.rules`) and
 * can only *ask* for a verification by creating
 * `users/{uid}/purchaseRequests/{requestId}` — which it cannot update, so it
 * cannot fake an outcome either.
 *
 * Flow
 *   1. client buys / restores with Play Billing, then creates a request doc
 *      holding the receipt (deterministic id → retries are no-ops);
 *   2. `verifyPurchaseRequest` re-checks the receipt with the Play Developer API
 *      and publishes the entitlement;
 *   3. `playRealTimeNotifications` keeps it fresh: renewals extend `expiresAt`,
 *      expiry/revocation/refunds flip `active` to false.
 *
 * NOT deployed by this repository: Cloud Functions require the Firebase **Blaze**
 * (pay-as-you-go) plan, which needs a billing account. See README.md.
 */

const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { onMessagePublished } = require('firebase-functions/v2/pubsub');
const { logger } = require('firebase-functions');
const admin = require('firebase-admin');
const { google } = require('googleapis');

admin.initializeApp();
const db = admin.firestore();

/** Must match SubscriptionProducts in app/lib/core/services/subscription_tier.dart. */
const PRODUCT_TIERS = {
  habitforge_premium_monthly: 'monthly',
  habitforge_premium_yearly: 'yearly',
  habitforge_premium_lifetime: 'lifetime',
};

const PLAY_PACKAGE_NAME = process.env.PLAY_PACKAGE_NAME || 'com.habitforge.habitforge';

/** Play subscription states that still grant access (grace period included). */
const ENTITLED_STATES = new Set(['SUBSCRIPTION_STATE_ACTIVE', 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD']);

/**
 * Checks a receipt against Google Play.
 *
 * Uses the Function's own service account (`google.auth.getClient()` via the
 * googleapis default), which must be granted access to the app in the Play
 * Console (Users & permissions → grant "View financial data" + the app).
 * Play subscriptions and one-time products are different endpoints, so the
 * lifetime SKU (a non-consumable) takes the `products` path.
 */
async function verifyWithPlay(productId, purchaseToken) {
  const auth = new google.auth.GoogleAuth({ scopes: ['https://www.googleapis.com/auth/androidpublisher'] });
  const client = await auth.getClient();
  const publisher = google.androidpublisher({ version: 'v3', auth: client });
  const tier = PRODUCT_TIERS[productId];

  if (tier === 'lifetime') {
    // playNonConsumable: purchaseState 0 = purchased, 1 = canceled.
    const { data } = await publisher.purchases.products.get({
      packageName: PLAY_PACKAGE_NAME,
      productId,
      token: purchaseToken,
    });
    return {
      tier,
      active: data.purchaseState === 0,
      expiresAt: 0, // one-time purchase: never expires
      state: `products.purchaseState=${data.purchaseState}`,
      orderId: data.orderId || '',
    };
  }

  const { data } = await publisher.purchases.subscriptionsv2.get({
    packageName: PLAY_PACKAGE_NAME,
    token: purchaseToken,
  });
  const expiry = data.lineItems?.[0]?.expiryTime;
  return {
    tier,
    active: ENTITLED_STATES.has(data.subscriptionState),
    expiresAt: expiry ? Date.parse(expiry) : 0,
    state: data.subscriptionState,
    orderId: data.latestOrderId || '',
  };
}

/**
 * Publishes (or revokes) one entitlement document.
 *
 * Keyed by productId, so a user who bought monthly and later lifetime keeps both
 * rows and the client picks the highest active tier. Idempotent by construction:
 * the same receipt always produces the same document.
 */
async function publishEntitlement(uid, productId, store, result, extra = {}) {
  await db.doc(`users/${uid}/entitlement/${productId}`).set(
    {
      tier: result.tier,
      store,
      productId,
      active: result.active,
      expiresAt: result.expiresAt || 0,
      state: result.state || '',
      orderId: result.orderId || '',
      verifiedAt: Date.now(),
      ...extra,
    },
    { merge: true },
  );
}

/** Handles a client-created verification request. */
exports.verifyPurchaseRequest = onDocumentCreated('users/{uid}/purchaseRequests/{requestId}', async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;
  const { uid } = event.params;
  const request = snapshot.data();
  const { store, productId, purchaseToken, orderId = '' } = request;
  const requestRef = snapshot.ref;

  const tier = PRODUCT_TIERS[productId];
  if (!tier) {
    logger.warn('unknown product', { uid, productId });
    await requestRef.set({ status: 'rejected', reason: 'unknown_product', checkedAt: Date.now() }, { merge: true });
    return;
  }
  if (store !== 'google_play') {
    // The Android build is the only shipped one; claiming to verify an App Store
    // receipt we cannot check would be worse than refusing.
    await requestRef.set({ status: 'rejected', reason: 'store_not_supported_yet', checkedAt: Date.now() }, { merge: true });
    return;
  }

  try {
    const result = await verifyWithPlay(productId, purchaseToken);
    await publishEntitlement(uid, productId, store, { ...result, orderId: result.orderId || orderId });
    await requestRef.set(
      { status: result.active ? 'verified' : 'not_entitled', reason: result.state, checkedAt: Date.now() },
      { merge: true },
    );
    logger.info('verification done', { uid, productId, active: result.active, state: result.state });
  } catch (error) {
    // Do not publish anything on failure: no access is the safe default.
    logger.error('verification failed', { uid, productId, message: error.message });
    await requestRef.set(
      { status: 'error', reason: String(error.message || error).slice(0, 200), checkedAt: Date.now() },
      { merge: true },
    );
  }
});

/**
 * Real-time developer notifications (Play Console → Monetization setup → RTDN,
 * topic wired to this Function by `onMessagePublished`).
 *
 * Without this, a renewed subscription would only be re-checked when the user
 * happens to reopen the Premium screen, and a refund would never revoke access.
 * That is exactly the "查不清 / 改不动" failure the plan warns about.
 */
exports.playRealTimeNotifications = onMessagePublished('play-rtdn', async (event) => {
  const message = event.data?.message;
  if (!message?.data) return;
  const payload = JSON.parse(Buffer.from(message.data, 'base64').toString('utf8'));

  const packageName = payload.packageName;
  if (packageName && packageName !== PLAY_PACKAGE_NAME) {
    logger.warn('RTDN for another package, ignoring', { packageName });
    return;
  }

  const subscription = payload.subscriptionNotification;
  const voided = payload.voidedPurchaseNotification;
  const purchaseToken = subscription?.purchaseToken || voided?.purchaseToken;
  if (!purchaseToken) return;

  // Which user does this token belong to? The request that carried it is our
  // only link, so look it up by the receipt we already stored.
  const query = await db.collectionGroup('purchaseRequests').where('purchaseToken', '==', purchaseToken).limit(1).get();
  if (query.empty) {
    logger.warn('RTDN for an unknown purchase token (no request on record)');
    return;
  }
  const uid = query.docs[0].ref.parent.parent.id;
  const productId = query.docs[0].data().productId;

  try {
    const result = await verifyWithPlay(productId, purchaseToken);
    // A voided purchase (refund) must revoke access even though the Play API may
    // still report the subscription as active for a while.
    const active = voided ? false : result.active;
    await publishEntitlement(uid, productId, 'google_play', { ...result, active }, { revokedAt: voided ? Date.now() : 0 });
    logger.info('RTDN applied', { uid, productId, notification: payload.notificationType, active });
  } catch (error) {
    logger.error('RTDN verification failed', { uid, productId, message: error.message });
  }
});
