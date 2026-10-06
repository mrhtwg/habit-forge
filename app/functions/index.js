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
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { logger } = require('firebase-functions');
const admin = require('firebase-admin');
const { google } = require('googleapis');
const crypto = require('crypto');

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
      accountId: data.obfuscatedExternalAccountId || '',
      needsAcknowledgement: data.acknowledgementState === 0,
    };
  }

  const { data } = await publisher.purchases.subscriptionsv2.get({
    packageName: PLAY_PACKAGE_NAME,
    token: purchaseToken,
  });
  const lineItem = data.lineItems?.find((item) => item.productId === productId);
  if (!lineItem) throw new Error('purchase_product_mismatch');
  const expiry = lineItem.expiryTime;
  return {
    tier,
    active: ENTITLED_STATES.has(data.subscriptionState),
    expiresAt: expiry ? Date.parse(expiry) : 0,
    state: data.subscriptionState,
    orderId: data.latestOrderId || '',
    accountId: data.externalAccountIdentifiers?.obfuscatedExternalAccountId || '',
    needsAcknowledgement: data.acknowledgementState === 'ACKNOWLEDGEMENT_STATE_PENDING',
  };
}

function tokenHash(purchaseToken) {
  return crypto.createHash('sha256').update(purchaseToken).digest('hex');
}

function accountHash(uid) {
  return crypto.createHash('sha256').update(uid).digest('hex');
}

async function claimPurchase(uid, productId, store, purchaseToken) {
  const ref = db.doc(`purchaseClaims/${tokenHash(purchaseToken)}`);
  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    if (snapshot.exists) {
      const claim = snapshot.data();
      if (claim.uid !== uid) throw new Error('purchase_already_claimed');
      if (claim.productId !== productId) throw new Error('purchase_product_mismatch');
      return;
    }
    transaction.create(ref, {
      uid,
      productId,
      store,
      claimedAt: Date.now(),
    });
  });
}

async function acknowledgeWithPlay(productId, purchaseToken, result) {
  if (!result.active || !result.needsAcknowledgement) return;
  const auth = new google.auth.GoogleAuth({ scopes: ['https://www.googleapis.com/auth/androidpublisher'] });
  const client = await auth.getClient();
  const publisher = google.androidpublisher({ version: 'v3', auth: client });
  if (result.tier === 'lifetime') {
    await publisher.purchases.products.acknowledge({
      packageName: PLAY_PACKAGE_NAME,
      productId,
      token: purchaseToken,
      requestBody: {},
    });
    return;
  }
  await publisher.purchases.subscriptions.acknowledge({
    packageName: PLAY_PACKAGE_NAME,
    subscriptionId: productId,
    token: purchaseToken,
    requestBody: {},
  });
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

/**
 * Permanently deletes one Firebase account and all of its cloud game data.
 *
 * The recent-auth check makes a stolen long-lived ID token insufficient for
 * this destructive operation. Purchase claims are retained only as anonymous
 * anti-replay tombstones: the uid is removed before Firebase Auth is deleted.
 */
exports.deleteAccount = onCall({ timeoutSeconds: 120 }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'sign_in_required');

  const authTime = Number(request.auth.token.auth_time || 0) * 1000;
  if (!authTime || Date.now() - authTime > 5 * 60 * 1000) {
    throw new HttpsError('failed-precondition', 'recent_login_required');
  }

  try {
    await db.recursiveDelete(db.doc(`users/${uid}`));

    const claims = await db.collection('purchaseClaims').where('uid', '==', uid).get();
    if (!claims.empty) {
      const batch = db.batch();
      for (const claim of claims.docs) {
        batch.update(claim.ref, {
          uid: admin.firestore.FieldValue.delete(),
          accountDeleted: true,
          deletedAt: Date.now(),
        });
      }
      await batch.commit();
    }

    await admin.auth().deleteUser(uid);
    logger.info('account deleted', { uid, anonymizedPurchaseClaims: claims.size });
    return { deleted: true };
  } catch (error) {
    logger.error('account deletion failed', { uid, message: error.message });
    throw new HttpsError('internal', 'account_deletion_failed');
  }
});

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
    if (result.accountId && result.accountId !== accountHash(uid)) {
      throw new Error('purchase_account_mismatch');
    }
    await claimPurchase(uid, productId, store, purchaseToken);
    await publishEntitlement(uid, productId, store, { ...result, orderId: result.orderId || orderId });
    let acknowledgement = result.needsAcknowledgement ? 'client_required' : 'already_acknowledged';
    try {
      await acknowledgeWithPlay(productId, purchaseToken, result);
      if (result.needsAcknowledgement) acknowledgement = 'server';
    } catch (ackError) {
      // The verified entitlement is already published. The client receives the
      // verified status below and calls completePurchase as a fallback.
      logger.error('server acknowledgement failed', { uid, productId, message: ackError.message });
    }
    await requestRef.set(
      {
        status: result.active ? 'verified' : 'not_entitled',
        reason: result.state,
        acknowledgement,
        checkedAt: Date.now(),
      },
      { merge: true },
    );
    logger.info('verification done', { uid, productId, active: result.active, state: result.state });
  } catch (error) {
    // Verification, account binding or token claiming failed: no access.
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

  const claim = await db.doc(`purchaseClaims/${tokenHash(purchaseToken)}`).get();
  if (!claim.exists) {
    logger.warn('RTDN for an unknown purchase token (no request on record)');
    return;
  }
  const { uid, productId, accountDeleted } = claim.data();
  if (accountDeleted || !uid) {
    logger.info('RTDN ignored for a deleted account', { productId });
    return;
  }

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
