# Purchase verification (Cloud Functions)

C1 of `docs/data-ledger-plan.md` §3.3: **订阅权益改成"服务端说了算"**.

The app currently caches the premium tier in `shared_preferences`
(`entitlement=local`, the default). That is a forgeable value on a rooted device
or a patched APK, and premium unlockers are a real business. This directory holds
the server half of the fix: a receipt check with Google Play whose result is the
only thing that grants premium.

```
client buys/restores ──▶ users/{uid}/purchaseRequests/{requestId}   (client: create only)
                                   │
                                   ▼  onDocumentCreated
                         verifyPurchaseRequest ──▶ Play Developer API
                                   │
                                   ▼
                         users/{uid}/entitlement/{productId}       (server only; client: read only)
```

`firebase/firestore.rules` enforces the two arrows that matter: a client can
create a request but never update it, and can never write an entitlement. The
emulator tests in `firebase/test/firestore.rules.test.mjs` prove both.

## Status: written, not deployed

Two external prerequisites, both of which the plan already flags (§3.3, §11):

1. **Blaze (pay-as-you-go) billing must be enabled** on the Firebase project.
   Functions cannot be deployed on the free Spark plan. Expected cost at this
   scale is inside the free tier, but a billing account must be attached.
2. **The Play Developer API must be reachable by the Function's service account**
   (Play Console → Users & permissions → invite the Functions service account,
   grant *View financial data*), and **RTDN** must be configured
   (Play Console → Monetization setup → a Pub/Sub topic).

Until then the app keeps `entitlement=local` and this code is inert. That is
deliberate: switching the client to server authority *before* the Function exists
would make a real purchase unlock nothing.

## Deploy

```bash
# from app/
npm --prefix functions install          # firebase-admin, firebase-functions, googleapis
npm run deploy:rules                    # firestore rules (events + entitlement)
firebase deploy --only functions
```

Then build the store app with server authority:

```bash
flutter build appbundle --dart-define-from-file=env/firebase.json --dart-define=entitlement=server
```

`env/firebase.json` may carry `"entitlement": "server"` instead of the extra
`--dart-define`; both work (see `env_constants.dart`).

## Verify it works

1. Buy the monthly plan with a **license-test account** (Play Console → License
   testing). The request document appears under `users/{uid}/purchaseRequests`,
   then `status` flips to `verified` and `users/{uid}/entitlement/<product>`
   appears.
2. Uninstall and reinstall, sign in with the same account, tap **Restore
   purchases**: premium comes back from the server, not from the device.
3. Refund the order in Play Console → the RTDN handler flips `active` to false
   and premium disappears within a minute or two.
4. Sanity check that local editing is now worthless: with `entitlement=server`,
   changing `shared_preferences` does not unlock anything
   (`SubscriptionService._setTier` refuses to persist a client-decided tier).

## What is deliberately not here

- **App Store verification** — the shipped build is Android-only. A request with
  `store: apple_app_store` is rejected with `store_not_supported_yet` rather than
  silently granting or denying; add `verifyWithAppStore` before shipping iOS.
- **Server-authoritative *game* economy** — no. The plan keeps game rules on the
  client and only moves the paid entitlement; the ledger's security rules
  (`events`) exist so that this can be revisited without rewriting history.
