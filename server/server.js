'use strict';

// Serves the static survey and accepts submissions. Replaces the browser's direct
// Supabase call: every submission is checked with Cloudflare Turnstile, shape-checked,
// rate limited, and inserted as the insert-only role survey_writer.

const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const { Pool } = require('pg');
const { validateResponse } = require('./validate');

const PORT = Number(process.env.PORT || 8080);
const PUBLIC_DIR = path.join(__dirname, '..', 'public');
const TURNSTILE_SITE_KEY = process.env.TURNSTILE_SITE_KEY || '';
const TURNSTILE_SECRET_KEY = process.env.TURNSTILE_SECRET_KEY || '';
const TURNSTILE_DISABLED = process.env.TURNSTILE_DISABLED === '1'; // local development only
const PUBLIC_HOSTNAME = process.env.PUBLIC_HOSTNAME || ''; // when set, Turnstile tokens must be issued for it
const RATE_LIMIT = Number(process.env.SUBMIT_RATE_LIMIT || 10); // submissions per IP per window
const RATE_WINDOW_MS = 10 * 60 * 1000;
const MAX_BODY_BYTES = 64 * 1024;

if (!TURNSTILE_DISABLED && (!TURNSTILE_SITE_KEY || !TURNSTILE_SECRET_KEY)) {
  console.error('TURNSTILE_SITE_KEY and TURNSTILE_SECRET_KEY are required (or TURNSTILE_DISABLED=1 for local use)');
  process.exit(1);
}
if (!process.env.DATABASE_URL) {
  console.error('DATABASE_URL is required');
  process.exit(1);
}

const pool = new Pool({ connectionString: process.env.DATABASE_URL, max: 5 });
pool.on('error', (err) => log('error', 'pg pool error', { err: err.message }));

function log(level, msg, extra) {
  process.stdout.write(JSON.stringify({ t: new Date().toISOString(), level, msg, ...extra }) + '\n');
}

// ---------------------------------------------------------------- static files (loaded once; no path traversal possible)
const TYPES = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.css': 'text/css; charset=utf-8',
  '.svg': 'image/svg+xml', '.png': 'image/png', '.jpg': 'image/jpeg', '.ico': 'image/x-icon', '.webp': 'image/webp',
};
const files = new Map();
(function load(dir, prefix) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) load(full, prefix + e.name + '/');
    else if (TYPES[path.extname(e.name)]) files.set('/' + prefix + e.name, { body: fs.readFileSync(full), type: TYPES[path.extname(e.name)] });
  }
})(PUBLIC_DIR, '');

const configJs = Buffer.from('window.SURVEY_CONFIG = ' + JSON.stringify({
  SUBMIT_URL: '/api/responses',
  TURNSTILE_SITE_KEY: TURNSTILE_DISABLED ? '' : TURNSTILE_SITE_KEY,
}) + ';\n');

// CSP: inline scripts are allowed by hash only, computed from index.html at start.
const indexHtml = files.get('/index.html').body.toString('utf8');
const scriptHashes = [...indexHtml.matchAll(/<script>([\s\S]*?)<\/script>/g)]
  .map((m) => `'sha256-${crypto.createHash('sha256').update(m[1]).digest('base64')}'`);
const CSP = [
  "default-src 'self'",
  `script-src 'self' https://challenges.cloudflare.com ${scriptHashes.join(' ')}`,
  "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
  "font-src https://fonts.gstatic.com",
  "img-src 'self' data:",
  "connect-src 'self'",
  "frame-src https://challenges.cloudflare.com",
  "frame-ancestors 'none'",
  "base-uri 'none'",
  "form-action 'none'",
].join('; ');
const SECURITY_HEADERS = {
  'Content-Security-Policy': CSP,
  'X-Content-Type-Options': 'nosniff',
  'Referrer-Policy': 'strict-origin-when-cross-origin',
  'Strict-Transport-Security': 'max-age=31536000',
  'Permissions-Policy': 'camera=(), microphone=(), geolocation=()',
};

function send(res, status, body, type, extra) {
  res.writeHead(status, { ...SECURITY_HEADERS, 'Content-Type': type || 'application/json', ...extra });
  res.end(body);
}
const json = (res, status, obj) => send(res, status, JSON.stringify(obj), 'application/json', { 'Cache-Control': 'no-store' });

// ---------------------------------------------------------------- rate limit (per client IP, in memory)
// The app port is bound to 127.0.0.1 and only cloudflared reaches it, so CF-Connecting-IP is set by Cloudflare.
const hits = new Map();
function rateLimited(ip) {
  const now = Date.now();
  const h = hits.get(ip);
  if (!h || h.reset <= now) { hits.set(ip, { n: 1, reset: now + RATE_WINDOW_MS }); return false; }
  h.n += 1;
  return h.n > RATE_LIMIT;
}
setInterval(() => { const now = Date.now(); for (const [k, v] of hits) if (v.reset <= now) hits.delete(k); }, 60_000).unref();

// ---------------------------------------------------------------- Turnstile
async function verifyTurnstile(token, ip) {
  if (TURNSTILE_DISABLED) return { ok: true };
  if (typeof token !== 'string' || !token || token.length > 2048) return { ok: false, reason: 'missing token' };
  const form = new URLSearchParams({ secret: TURNSTILE_SECRET_KEY, response: token });
  if (ip) form.set('remoteip', ip);
  const r = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
    method: 'POST', body: form, signal: AbortSignal.timeout(10_000),
  });
  const out = await r.json();
  if (!out.success) return { ok: false, reason: (out['error-codes'] || []).join(',') || 'rejected' };
  if (out.action && out.action !== 'submit') return { ok: false, reason: 'wrong action' };
  if (PUBLIC_HOSTNAME && out.hostname !== PUBLIC_HOSTNAME) return { ok: false, reason: 'wrong hostname' };
  return { ok: true };
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let size = 0;
    const chunks = [];
    req.on('data', (c) => {
      size += c.length;
      if (size > MAX_BODY_BYTES) { reject(Object.assign(new Error('too large'), { status: 413 })); req.destroy(); return; }
      chunks.push(c);
    });
    req.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
    req.on('error', reject);
  });
}

async function submit(req, res) {
  const ip = req.headers['cf-connecting-ip'] || req.socket.remoteAddress || '';
  if (!/^application\/json\b/i.test(req.headers['content-type'] || '')) return json(res, 415, { error: 'json only' });
  if (rateLimited(ip)) return json(res, 429, { error: 'too many submissions' });

  let body;
  try { body = JSON.parse(await readBody(req)); } catch (e) { return json(res, e.status || 400, { error: 'bad body' }); }
  if (!body || typeof body !== 'object') return json(res, 400, { error: 'bad body' });

  const v = validateResponse(body.response);
  if (v.error) { log('warn', 'rejected submission', { reason: v.error }); return json(res, 400, { error: v.error }); }

  let t;
  try { t = await verifyTurnstile(body.token, ip); } catch (e) {
    log('error', 'turnstile verify failed', { err: e.message });
    return json(res, 503, { error: 'verification unavailable' });
  }
  if (!t.ok) { log('warn', 'turnstile rejected', { reason: t.reason }); return json(res, 403, { error: 'verification failed' }); }

  const r = v.value;
  await pool.query(
    `insert into public.responses (survey_version, language, consent, is_customer, duration_seconds, source, answers, contact)
     values ($1, $2, $3, $4, $5, $6, $7, $8)`,
    [r.survey_version, r.language, r.consent, r.is_customer, r.duration_seconds, r.source, r.answers, r.contact],
  );
  log('info', 'response stored', { lang: r.language, source: r.source });
  return json(res, 201, { ok: true });
}

const server = http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url, 'http://x');
    if (url.pathname === '/api/responses') {
      if (req.method !== 'POST') return json(res, 405, { error: 'method not allowed' });
      return await submit(req, res);
    }
    if (url.pathname === '/healthz') {
      await pool.query('select 1');
      return json(res, 200, { ok: true });
    }
    if (req.method !== 'GET' && req.method !== 'HEAD') return json(res, 405, { error: 'method not allowed' });
    if (url.pathname === '/config.js') return send(res, 200, configJs, TYPES['.js'], { 'Cache-Control': 'no-cache' });
    const f = files.get(url.pathname === '/' ? '/index.html' : url.pathname);
    if (!f) return send(res, 404, 'Not found', 'text/plain; charset=utf-8');
    return send(res, 200, req.method === 'HEAD' ? '' : f.body, f.type, { 'Cache-Control': 'no-cache' });
  } catch (e) {
    log('error', 'request failed', { path: req.url, err: e.message });
    if (!res.headersSent) json(res, 500, { error: 'server error' });
  }
});

server.listen(PORT, () => log('info', 'listening', { port: PORT, turnstile: !TURNSTILE_DISABLED }));

function shutdown() { server.close(() => pool.end().finally(() => process.exit(0))); setTimeout(() => process.exit(0), 5000).unref(); }
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
