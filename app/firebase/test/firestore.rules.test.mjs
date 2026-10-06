// Firestore security-rule tests for the ledger (docs/data-ledger-plan.md §6.5, T4).
//
// The three invariants the plan asks to be automated, plus the cross-language
// guard that keeps the Dart caps and the rules from drifting:
//
//   1. append-only      — update/delete of a row is denied;
//   2. ownership        — another user, or nobody, cannot touch your events;
//   3. caps + shape      — a row the client would never write is denied;
//   4. entitlement      — a client may read its purchases, never write them;
//   5. purchase claims   — token ownership is invisible and immutable to clients;
//   6. fixtures          — every row shape GameLedger produces IS accepted.
//
// Deliberately dependency-free: it talks to the emulator's REST API and mints
// unsigned JWTs, which the emulator accepts (it does not verify signatures, it
// only reads `sub`/`user_id`). So this runs with plain `node --test` — no npm
// install, which also keeps it usable in CI where the registry is unreachable.
//
// Run from `app/`:
//   npm run test:rules
//   # or: firebase emulators:exec --only firestore --project demo-habitforge \
//   #       "node --test firebase/test/"

import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const HERE = dirname(fileURLToPath(import.meta.url));
const PROJECT = process.env.GCLOUD_PROJECT || 'demo-habitforge';
const HOST = process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';
const BASE = `http://${HOST}/v1/projects/${PROJECT}/databases/(default)/documents`;
const RUN = `run${Date.now().toString(36)}`;

const OWNER = `owner-${RUN}`;
const STRANGER = `stranger-${RUN}`;

/** Unsigned JWT the emulator treats as `uid`. */
function token(uid) {
  const enc = (payload) => Buffer.from(JSON.stringify(payload)).toString('base64url');
  const now = Math.floor(Date.now() / 1000);
  const header = enc({ alg: 'none', typ: 'JWT' });
  const claims = enc({
    sub: uid,
    user_id: uid,
    aud: PROJECT,
    iss: `https://securetoken.google.com/${PROJECT}`,
    iat: now,
    exp: now + 3600,
  });
  return `${header}.${claims}.`;
}

/** Plain JSON -> Firestore REST typed values. */
function toValue(value) {
  if (value === null) return { nullValue: null };
  if (typeof value === 'string') return { stringValue: value };
  if (typeof value === 'boolean') return { booleanValue: value };
  if (Number.isInteger(value)) return { integerValue: String(value) };
  if (typeof value === 'number') return { doubleValue: value };
  if (Array.isArray(value)) return { arrayValue: { values: value.map(toValue) } };
  if (typeof value === 'object') return { mapValue: { fields: toFields(value) } };
  throw new Error(`unsupported fixture value: ${value}`);
}

function toFields(object) {
  return Object.fromEntries(Object.entries(object).map(([key, value]) => [key, toValue(value)]));
}

function auth(uid) {
  return { authorization: `Bearer ${token(uid)}`, 'content-type': 'application/json' };
}

/** A signed-out device: no credentials at all (a placeholder token would be a
 *  malformed-JWT 400 rather than the 401 we want to assert). */
const noAuth = { 'content-type': 'application/json' };

const eventPath = (uid, eventId) => `${BASE}/users/${uid}/events/${encodeURIComponent(eventId)}`;

async function createEvent(uid, row, { documentId = row.eventId, uidOverride } = {}) {
  return fetch(`${BASE}/users/${uid}/events?documentId=${encodeURIComponent(documentId)}`, {
    method: 'POST',
    headers: auth(uidOverride === undefined ? uid : uidOverride),
    body: JSON.stringify({ fields: toFields(row) }),
  });
}

const fixtures = JSON.parse(readFileSync(join(HERE, 'fixtures', 'ledger_events.json'), 'utf8')).events;

let fixtureCounter = 0;

/**
 * Fresh copy of a fixture row, with the id rewritten to a per-call id so one
 * test can never collide with a document another test already created.
 */
function fixture(type) {
  const row = structuredClone(fixtures.find((event) => event.type === type));
  assert.ok(row, `no fixture for ${type}`);
  row.eventId = `${row.eventId}-${RUN}-${fixtureCounter++}`;
  return row;
}

function assertDenied(response, what) {
  assert.ok(
    response.status === 403 || response.status === 401,
    `${what}: expected a rules denial, got HTTP ${response.status}`,
  );
}

test('accepts every row shape GameLedger writes', async () => {
  for (const event of fixtures) {
    const row = structuredClone(event);
    row.eventId = `${row.eventId}-${RUN}`;
    const response = await createEvent(OWNER, row);
    assert.equal(response.status, 200, `${row.type} must be accepted (HTTP ${response.status})`);
  }
});

test('the ledger is append-only: rows cannot be updated or deleted', async () => {
  const row = fixture('task_completed');
  assert.equal((await createEvent(OWNER, row)).status, 200);

  const patched = structuredClone(row);
  patched.gold = 1;
  const update = await fetch(`${eventPath(OWNER, row.eventId)}?updateMask.fieldPaths=gold`, {
    method: 'PATCH',
    headers: auth(OWNER),
    body: JSON.stringify({ fields: toFields(patched) }),
  });
  assertDenied(update, 'update');

  const removed = await fetch(eventPath(OWNER, row.eventId), { method: 'DELETE', headers: auth(OWNER) });
  assertDenied(removed, 'delete');
});

test('a row without the event id in the path is rejected', async () => {
  const row = fixture('purchase');
  const response = await createEvent(OWNER, row, { documentId: `mismatched-${RUN}` });
  assertDenied(response, 'eventId != documentId');
});

test('a row outside the caps is rejected', async () => {
  for (const [field, value] of [
    ['gold', 999999],
    ['exp', 999999],
    ['gems', 999999],
    ['hp', 999999],
  ]) {
    const row = fixture('task_completed');
    row[field] = value;
    assertDenied(await createEvent(OWNER, row), `${field}=${value}`);
  }
});

test('opening_balance keeps its own, larger cap', async () => {
  // A long-lived save may hold a lot: the opening row must pass where a normal
  // event would not…
  const opening = fixture('opening_balance');
  opening.gold = 50000;
  assert.equal((await createEvent(OWNER, opening)).status, 200, 'opening_balance must allow a large snapshot');

  // …but not an unbounded one.
  const absurd = structuredClone(opening);
  absurd.eventId = `${absurd.eventId}-absurd`;
  absurd.gold = 999999999;
  assertDenied(await createEvent(OWNER, absurd), 'opening_balance above its own cap');
});

test('shape violations are rejected', async () => {
  const unknownType = fixture('purchase');
  unknownType.type = 'free_gold';
  assertDenied(await createEvent(OWNER, unknownType), 'unknown type');

  const extraField = fixture('purchase');
  extraField.adminNote = 'hello';
  assertDenied(await createEvent(OWNER, extraField), 'extra field');

  const badDate = fixture('purchase');
  badDate.localDate = '29/09/2026';
  assertDenied(await createEvent(OWNER, badDate), 'localDate not YYYY-MM-DD');

  const badSchema = fixture('purchase');
  badSchema.schemaVersion = 99;
  assertDenied(await createEvent(OWNER, badSchema), 'unknown schemaVersion');

  const goldAsString = fixture('purchase');
  goldAsString.gold = '-350';
  assertDenied(await createEvent(OWNER, goldAsString), 'gold as string');
});

test('events are private to their owner', async () => {
  const row = fixture('revive');
  assert.equal((await createEvent(OWNER, row)).status, 200);

  const listOwn = await fetch(`${BASE}/users/${OWNER}/events`, { headers: auth(OWNER) });
  assert.equal(listOwn.status, 200);

  const listOthers = await fetch(`${BASE}/users/${OWNER}/events`, { headers: auth(STRANGER) });
  assertDenied(listOthers, 'read another user’s ledger');

  // Signed in as STRANGER, but writing into OWNER's ledger: the path decides
  // ownership, so this must be refused.
  const writeOthers = await createEvent(
    OWNER,
    { ...structuredClone(row), eventId: `stranger-${RUN}` },
    { uidOverride: STRANGER },
  );
  assertDenied(writeOthers, 'write another user’s ledger');

  const anonymous = await fetch(`${BASE}/users/${OWNER}/events`, { headers: noAuth });
  assertDenied(anonymous, 'unauthenticated read');
});

test('entitlement is readable by its owner and writable by nobody', async () => {
  // Cloud Functions write it with the Admin SDK, which bypasses rules — the
  // emulator's `Bearer owner` stands in for that here.
  const seeded = await fetch(`${BASE}/users/${OWNER}/entitlement/habitforge_premium_lifetime`, {
    method: 'PATCH',
    headers: { authorization: 'Bearer owner', 'content-type': 'application/json' },
    body: JSON.stringify({
      fields: toFields({ tier: 'lifetime', store: 'google_play', productId: 'habitforge_premium_lifetime' }),
    }),
  });
  assert.equal(seeded.status, 200, 'admin seed must succeed');

  const read = await fetch(`${BASE}/users/${OWNER}/entitlement/habitforge_premium_lifetime`, {
    headers: auth(OWNER),
  });
  assert.equal(read.status, 200, 'owner must be able to read the entitlement');

  const forged = await fetch(`${BASE}/users/${OWNER}/entitlement/habitforge_premium_lifetime`, {
    method: 'PATCH',
    headers: auth(OWNER),
    body: JSON.stringify({
      fields: toFields({ tier: 'lifetime', store: 'google_play', productId: 'habitforge_premium_lifetime' }),
    }),
  });
  assertDenied(forged, 'client granting itself premium');

  const create = await fetch(`${BASE}/users/${OWNER}/entitlement?documentId=habitforge_premium_monthly`, {
    method: 'POST',
    headers: auth(OWNER),
    body: JSON.stringify({
      fields: toFields({ tier: 'monthly', store: 'google_play', productId: 'habitforge_premium_monthly' }),
    }),
  });
  assertDenied(create, 'client creating an entitlement');
});

test('a client can ask for receipt verification but not publish the result', async () => {
  const request = {
    store: 'google_play',
    productId: 'habitforge_premium_monthly',
    purchaseToken: `token-${RUN}`,
    orderId: `order-${RUN}`,
    requestedAt: Date.now(),
  };

  const asked = await fetch(`${BASE}/users/${OWNER}/purchaseRequests?documentId=req-${RUN}`, {
    method: 'POST',
    headers: auth(OWNER),
    body: JSON.stringify({ fields: toFields(request) }),
  });
  assert.equal(asked.status, 200, 'a verification request must be accepted');

  // The Function writes the outcome with the Admin SDK…
  const outcome = await fetch(`${BASE}/users/${OWNER}/purchaseRequests/req-${RUN}?updateMask.fieldPaths=status`, {
    method: 'PATCH',
    headers: { authorization: 'Bearer owner', 'content-type': 'application/json' },
    body: JSON.stringify({ fields: toFields({ ...request, status: 'verified' }) }),
  });
  assert.equal(outcome.status, 200, 'admin outcome must be allowed');

  // …while the client may only read it, never rewrite it (e.g. to "verified").
  const forged = await fetch(`${BASE}/users/${OWNER}/purchaseRequests/req-${RUN}`, {
    method: 'PATCH',
    headers: auth(OWNER),
    body: JSON.stringify({ fields: toFields({ ...request, status: 'verified' }) }),
  });
  assertDenied(forged, 'client forging a verification outcome');

  const emptyToken = await fetch(`${BASE}/users/${OWNER}/purchaseRequests?documentId=empty-${RUN}`, {
    method: 'POST',
    headers: auth(OWNER),
    body: JSON.stringify({ fields: toFields({ ...request, purchaseToken: '' }) }),
  });
  assertDenied(emptyToken, 'request without a receipt');
});

test('global purchase-token claims are inaccessible to clients', async () => {
  const path = `${BASE}/purchaseClaims/token-${RUN}`;
  const read = await fetch(path, { headers: auth(OWNER) });
  assertDenied(read, 'client reading purchase-token ownership');

  const write = await fetch(path, {
    method: 'PATCH',
    headers: auth(OWNER),
    body: JSON.stringify({
      fields: toFields({ uid: OWNER, productId: 'habitforge_premium_lifetime' }),
    }),
  });
  assertDenied(write, 'client claiming a purchase token');
});
