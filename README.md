# Foodics Market Insights Survey

A one-question-at-a-time survey (English and Arabic) for merchants. It runs on its own EC2 instance on the
tools-* pattern: a small Node server serves the page and stores answers in Postgres on the same instance,
and the developer reads the data in pgweb. There are no inbound ports. Both hostnames go through a
Cloudflare Tunnel, and only the database hostname sits behind Cloudflare Access.

## How it fits together

| Piece | What it does |
|---|---|
| `public/index.html` | The whole survey: design, questions, both languages, logic |
| `server/` | Serves the page and `config.js`, and accepts `POST /api/responses`. Each submission is checked with Cloudflare Turnstile, validated, rate limited per IP, then inserted as `survey_writer`, which can only INSERT |
| `migrations/` | `001_init.sql` holds the schema, ported from the old Supabase `schema.sql`. `migrate.js` creates the roles and applies migrations once each |
| `pgweb` (compose) | Web SQL client. It connects as `survey_reader`, which is read-only at the role level. pgweb's `--readonly` flag adds a second layer, and the session is locked to this database |
| `deploy/` | `provision.sh` (AWS CLI) and `user_data.sh` (first boot) |
| `.github/workflows/deploy.yml` | Runs on push to `main`: tests, then an arm64 image to ECR, then a deploy over SSM |

Hostnames:
- **Survey** (public, for merchants): tunnel to `http://localhost:8080`. No Access.
- **Database** (internal): tunnel to `http://localhost:8081`, behind an Access application.

## Where the answers are

Open the database hostname to get pgweb. Use the `responses_flat` view, which has one row per respondent and one
column per question; its Export button downloads CSV. The `responses` table holds the raw data.

## Tracking where answers come from

Add `?src=` to any link you send, for example `/?src=whatsapp`. The value is saved with each response.

## Changing questions

All questions and both languages live in the `QUESTIONS` list inside `public/index.html`. To change the database, add a new
`migrations/NNN_*.sql`. Never edit one that has already run.

## Run locally

```bash
cat > .env <<'EOF'
POSTGRES_PASSWORD=localdev01
SURVEY_WRITER_PASSWORD=localdev02
SURVEY_READER_PASSWORD=localdev03
TURNSTILE_SITE_KEY=1x00000000000000000000AA
TURNSTILE_SECRET_KEY=1x0000000000000000000000000000000AA
EOF
docker compose up --build    # survey on http://localhost:8080, pgweb on http://localhost:8081
npm ci && npm test
```

The keys above are Cloudflare's always-pass test keys. Leave `PUBLIC_HOSTNAME` unset with them.

## First-time setup (infrastructure)

1. **AWS.** Run `GITHUB_REPO_ID=$(gh api repos/FoodicsTools/merchants-survey --jq .id) ./deploy/provision.sh` with an admin profile. Then set the repo **variables** `INSTANCE_ID` and `AWS_ROLE_ARN` from its output. Use repository variables, not environment variables.
2. **Turnstile.** In Cloudflare, go to Turnstile and add a widget for the survey hostname in Managed mode. Copy the site key and the secret key.
3. **Tunnel.** Create a new tunnel and add two public hostnames: survey to `http://localhost:8080`, database to `http://localhost:8081`.
   On the database hostname, turn on *Access → Protect with Access* (Additional application settings), so cloudflared itself rejects requests without a valid Access token.
4. **Access.** Create a self-hosted application for the database hostname. Its policy should allow only the developer's email(s), because pgweb shows merchants' names, emails and phones.
5. **Rate limiting (WAF).** Add a rule: `http.request.uri.path eq "/api/responses"` and method POST, 10 requests per minute per IP, action Block. The app also limits 10 per IP per 10 minutes.
6. **SSM parameters** (SecureString). The passwords must be hex only, e.g. `openssl rand -hex 24`:
   - `/merchants-survey/cloudflared-token`: the tunnel token
   - `/merchants-survey/env`:
     ```
     POSTGRES_PASSWORD=<hex>
     SURVEY_WRITER_PASSWORD=<hex>
     SURVEY_READER_PASSWORD=<hex>
     TURNSTILE_SITE_KEY=<site key>
     TURNSTILE_SECRET_KEY=<secret key>
     PUBLIC_HOSTNAME=<survey hostname>
     ```
   Then on the instance run `sudo survey-sync; sudo systemctl start cloudflared`.
7. Push to `main`. The workflow deploys, and `survey-deploy` waits for `/healthz` and rolls back the app image if it fails.

## Operating

- **Apply a changed SSM parameter:** run `sudo survey-deploy "$(cat /opt/merchants-survey/.current-image)"`. `POSTGRES_PASSWORD` only takes effect on first init, so never change it. The other two passwords are re-applied on every deploy.
- **Shell access:** SSM Session Manager only. Logs go to the CloudWatch group `/merchants-survey`, and first-boot output is in `/var/log/user-data.log`.
- **Logical backup:** `cd /opt/merchants-survey && sudo docker compose exec -T postgres pg_dump -U survey_admin -Fc survey > survey.dump`
