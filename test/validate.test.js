'use strict';

const test = require('node:test');
const assert = require('node:assert');
const { validateResponse, validateProgress } = require('../server/validate');

const good = () => ({
  survey_version: 'v2', language: 'en', consent: true, is_customer: true,
  duration_seconds: 300, source: 'whatsapp', answers: { position: 'owner' }, contact: {},
});

test('accepts a normal submission', () => {
  const r = validateResponse(good());
  assert.ifError(r.error);
  assert.strictEqual(r.value.source, 'whatsapp');
});

test('rejects missing consent', () => {
  assert.ok(validateResponse({ ...good(), consent: false }).error);
});

test('rejects unknown language', () => {
  assert.ok(validateResponse({ ...good(), language: 'fr' }).error);
});

test('rejects oversized answers', () => {
  assert.ok(validateResponse({ ...good(), answers: { x: 'a'.repeat(31000) } }).error);
});

test('rejects non-object answers and contact', () => {
  assert.ok(validateResponse({ ...good(), answers: [] }).error);
  assert.ok(validateResponse({ ...good(), contact: 'x' }).error);
});

test('drops unknown top-level fields', () => {
  const r = validateResponse({ ...good(), id: 'abc', created_at: '2000-01-01' });
  assert.ifError(r.error);
  assert.ok(!('id' in r.value) && !('created_at' in r.value));
});

test('empty source becomes null', () => {
  assert.strictEqual(validateResponse({ ...good(), source: '' }).value.source, null);
});

const goodProgress = () => ({
  sid: '2f6c1c1e-5a0d-4d7e-9f35-1b7d0f0c9a11', survey_version: 'v13', language: 'ar', q_id: 'saasSpend', q_index: 13, q_total: 34,
  grp: 'yes', country: 'oman', source: 'whatsapp', seconds: 215,
});

test('accepts a normal progress report', () => {
  const r = validateProgress(goodProgress());
  assert.ifError(r.error);
  assert.strictEqual(r.value.q_id, 'saasSpend');
  assert.strictEqual(r.value.grp, 'yes');
});

test('progress: optional fields may be missing', () => {
  const r = validateProgress({ ...goodProgress(), grp: undefined, country: undefined, source: '', seconds: undefined });
  assert.ifError(r.error);
  assert.strictEqual(r.value.grp, null);
  assert.strictEqual(r.value.source, null);
});

test('progress: rejects bad session id, question id, numbers and group', () => {
  assert.ok(validateProgress({ ...goodProgress(), sid: 'x' }).error);
  assert.ok(validateProgress({ ...goodProgress(), sid: 'a b c d e f g h' }).error);
  assert.ok(validateProgress({ ...goodProgress(), q_id: "x'; drop table" }).error);
  assert.ok(validateProgress({ ...goodProgress(), q_index: -1 }).error);
  assert.ok(validateProgress({ ...goodProgress(), q_total: 999 }).error);
  assert.ok(validateProgress({ ...goodProgress(), grp: 'maybe' }).error);
  assert.ok(validateProgress({ ...goodProgress(), language: 'fr' }).error);
  assert.ok(validateProgress({ ...goodProgress(), survey_version: 'x' }).error);
});

test('progress: drops unknown fields and never carries answers', () => {
  const r = validateProgress({ ...goodProgress(), answers: { secret: 1 }, id: 'abc' });
  assert.ifError(r.error);
  assert.ok(!('answers' in r.value) && !('id' in r.value));
});