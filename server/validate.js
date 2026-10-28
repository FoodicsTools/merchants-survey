'use strict';

// Shape check for one survey submission. The browser is untrusted, so anything
// outside this shape is rejected rather than stored. The CHECK constraints in
// migrations/001_init.sql are the second line of defence.

const MAX_ANSWERS_BYTES = 30000;
const MAX_CONTACT_BYTES = 4000;

const isPlainObject = (v) => v !== null && typeof v === 'object' && !Array.isArray(v);

function validateResponse(r) {
  if (!isPlainObject(r)) return { error: 'body must be an object' };
  if (r.consent !== true) return { error: 'consent is required' };
  if (r.language !== 'en' && r.language !== 'ar') return { error: 'language must be en or ar' };
  if (r.is_customer != null && typeof r.is_customer !== 'boolean') return { error: 'is_customer must be boolean' };
  if (r.duration_seconds != null &&
      !(Number.isInteger(r.duration_seconds) && r.duration_seconds >= 0 && r.duration_seconds <= 7200)) {
    return { error: 'duration_seconds out of range' };
  }
  if (r.source != null && !(typeof r.source === 'string' && r.source.length <= 60)) return { error: 'source too long' };
  if (typeof r.survey_version !== 'string' || !/^v\d{1,3}$/.test(r.survey_version)) return { error: 'bad survey_version' };
  if (!isPlainObject(r.answers)) return { error: 'answers must be an object' };
  if (!isPlainObject(r.contact)) return { error: 'contact must be an object' };
  if (Buffer.byteLength(JSON.stringify(r.answers)) > MAX_ANSWERS_BYTES) return { error: 'answers too large' };
  if (Buffer.byteLength(JSON.stringify(r.contact)) > MAX_CONTACT_BYTES) return { error: 'contact too large' };

  return {
    value: {
      survey_version: r.survey_version,
      language: r.language,
      consent: true,
      is_customer: r.is_customer ?? null,
      duration_seconds: r.duration_seconds ?? null,
      source: r.source || null,
      answers: r.answers,
      contact: r.contact,
    },
  };
}

// One "the merchant reached question X" report. It carries no answers, only the question id and position,
// so we can see where people stop. Sent by the browser without the human check, so it is strictly shape-checked.
const GROUPS = ['yes', 'former', 'no'];
function validateProgress(r) {
  if (!isPlainObject(r)) return { error: 'body must be an object' };
  if (typeof r.sid !== 'string' || !/^[A-Za-z0-9-]{8,64}$/.test(r.sid)) return { error: 'bad sid' };
  if (typeof r.survey_version !== 'string' || !/^v\d{1,3}$/.test(r.survey_version)) return { error: 'bad survey_version' };
  if (r.language !== 'en' && r.language !== 'ar') return { error: 'language must be en or ar' };
  if (typeof r.q_id !== 'string' || !/^[A-Za-z0-9_]{1,40}$/.test(r.q_id)) return { error: 'bad q_id' };
  if (!Number.isInteger(r.q_index) || r.q_index < 0 || r.q_index > 200) return { error: 'bad q_index' };
  if (!Number.isInteger(r.q_total) || r.q_total < 0 || r.q_total > 200) return { error: 'bad q_total' };
  if (r.grp != null && !GROUPS.includes(r.grp)) return { error: 'bad grp' };
  if (r.country != null && !(typeof r.country === 'string' && /^[a-z]{2,20}$/.test(r.country))) return { error: 'bad country' };
  if (r.source != null && !(typeof r.source === 'string' && r.source.length <= 60)) return { error: 'source too long' };
  if (r.seconds != null && !(Number.isInteger(r.seconds) && r.seconds >= 0 && r.seconds <= 86400)) return { error: 'bad seconds' };
  return {
    value: {
      sid: r.sid, survey_version: r.survey_version, language: r.language,
      grp: r.grp ?? null, country: r.country ?? null, source: r.source || null,
      q_id: r.q_id, q_index: r.q_index, q_total: r.q_total, seconds: r.seconds ?? null,
    },
  };
}
module.exports = { validateResponse, validateProgress };
