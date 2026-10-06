# Purchase verification (Cloud Functions)

C1 of `docs/data-ledger-plan.md` §3.3: **订阅权益改成"服务端说了算"**.

The app no longer has a local or debug entitlement. A receipt check with Google
Play whose result is written by this Function is the only thing that grants
premium.

```
client buys/restores ──▶ users/{uid}/purchaseRequests/{requestId}   (client: create only)
                                   │
                                   ▼  onDocumentCreated
                         verifyPurchaseRequest ──▶ Play Developer API
                                   │
                                   ▼
                         users/{uid}/entitlement/{productId}       (server only; client: read only)
                                   │
                                   ├── acknowledges the verified order with Play
                                   └── claims purchaseClaims/{sha256(token)} globally
```

`firebase/firestore.rules` enforces the two arrows that matter: a client can
create a request but never update it, and can never write an entitlement. The
emulator tests in `firebase/test/firestore.rules.test.mjs` prove both.

The global claim prevents one Play purchase token from being replayed into a
different HabitForge account. New purchases also carry a SHA-256 account id;
the Function rejects a mismatched account when Google returns that identifier.

## Deployment required

Two external prerequisites, both of which the plan already flags (§3.3, §11):

1. **Blaze (pay-as-you-go) billing must be enabled** on the Firebase project.
   Functions cannot be deployed on the free Spark plan. Expected cost at this
   scale is inside the free tier, but a billing account must be attached.
2. **The Play Developer API must be reachable by the Function's service account**
   (Play Console → Users & permissions → invite the Functions service account,
   grant the app's *View financial data* and *Manage orders and subscriptions*
   permissions), and **RTDN** must be configured
   (Play Console → Monetization setup → a Pub/Sub topic).
3. Play Console must contain active products with the exact ids
   `habitforge_premium_monthly`, `habitforge_premium_yearly`, and
   `habitforge_premium_lifetime`. The first two are subscriptions; Lifetime is
   a one-time, non-consumable product. Activate their countries and prices
   before testing.

Until these Functions and the matching Firestore rules are deployed, purchases
will not unlock premium. Do not ship a store build before completing the checks
below.

## Deploy

```bash
# from app/
npm --prefix functions install          # firebase-admin, firebase-functions, googleapis
npx firebase use --add                   # select the production Firebase project once
npm run deploy:rules                    # firestore rules (events + entitlement)
firebase deploy --only functions
```

The deployment includes `deleteAccount`, an authenticated callable Function.
The app requires a Google reauthentication from the last five minutes before
the Function recursively deletes `users/{uid}`, anonymizes purchase-token
anti-replay claims, and deletes the Firebase Auth user.

Then build the store app with server authority:

```bash
flutter build appbundle --dart-define-from-file=.env/firebase.json
```

## Verify it works

1. Buy the monthly plan with a **license-test account** (Play Console → License
   testing). The request document appears under `users/{uid}/purchaseRequests`,
   then `status` flips to `verified` and `users/{uid}/entitlement/<product>`
   appears.
2. Uninstall and reinstall, sign in with the same account, tap **Restore
   purchases**: premium comes back from the server, not from the device.
3. Refund the order in Play Console → the RTDN handler flips `active` to false
   and premium disappears within a minute or two.
4. Sanity check that local editing is worthless: there is no locally persisted
   tier and paid gates only read the Function-owned entitlement collection.

## What is deliberately not here

- **App Store verification** — the shipped build is Android-only. A request with
  `store: apple_app_store` is rejected with `store_not_supported_yet` rather than
  silently granting or denying; add `verifyWithAppStore` before shipping iOS.
- **Server-authoritative *game* economy** — no. The plan keeps game rules on the
  client and only moves the paid entitlement; the ledger's security rules
  (`events`) exist so that this can be revisited without rewriting history.
