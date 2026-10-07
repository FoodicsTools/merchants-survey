'use strict';

const test = require('node:test');
const assert = require('node:assert');
const { validateResponse } = require('../server/validate');

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
