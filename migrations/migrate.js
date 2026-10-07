'use strict';

// One-shot: ensures the two login roles exist with the passwords from the environment,
// then applies migrations/NNN_*.sql in order, each once, inside a transaction.
// Runs as the Postgres superuser from the compose `migrate` service before the app starts.

const fs = require('node:fs');
const path = require('node:path');
const { Client } = require('pg');

const need = (k) => process.env[k] || (console.error(`${k} is required`), process.exit(1));

async function main() {
  const db = new Client({ connectionString: need('MIGRATE_DATABASE_URL') });
  await db.connect();
  try {
    await db.query('select pg_advisory_lock(424242)');

    const roles = {
      survey_writer: need('SURVEY_WRITER_PASSWORD'),
      survey_reader: need('SURVEY_READER_PASSWORD'),
    };
    for (const [role, pw] of Object.entries(roles)) {
      const { rowCount } = await db.query('select 1 from pg_roles where rolname = $1', [role]);
      const verb = rowCount ? 'alter' : 'create';
      const { rows } = await db.query(`select format('${verb} role %I login password %L', $1::text, $2::text) as sql`, [role, pw]);
      await db.query(rows[0].sql);
    }
    // The reader can never write, even if a grant is added by mistake, and cannot run away with the instance.
    await db.query("alter role survey_reader set default_transaction_read_only = on");
    await db.query("alter role survey_reader set statement_timeout = '60s'");
    await db.query('alter role survey_reader connection limit 5');
    await db.query("alter role survey_writer set statement_timeout = '10s'");

    await db.query(`create table if not exists schema_migrations (
      name text primary key, applied_at timestamptz not null default now())`);
    const done = new Set((await db.query('select name from schema_migrations')).rows.map((r) => r.name));

    const files = fs.readdirSync(__dirname).filter((f) => /^\d{3}_.+\.sql$/.test(f)).sort();
    for (const f of files) {
      if (done.has(f)) continue;
      console.log(`applying ${f}`);
      await db.query('begin');
      try {
        await db.query(fs.readFileSync(path.join(__dirname, f), 'utf8'));
        await db.query('insert into schema_migrations (name) values ($1)', [f]);
        await db.query('commit');
      } catch (e) {
        await db.query('rollback');
        throw new Error(`${f}: ${e.message}`);
      }
    }
    console.log('migrations up to date');
  } finally {
    await db.end();
  }
}

main().catch((e) => { console.error(e.message); process.exit(1); });
