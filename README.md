# Foodics Market Insights Survey

A one-question-at-a-time survey (English and Arabic) that saves answers to Supabase and is hosted free on GitHub Pages.

## Files

| File | What it is |
|---|---|
| `index.html` | The whole survey: design, questions, English and Arabic text, logic |
| `config.js` | Your two Supabase values (URL and public key) |
| `supabase/schema.sql` | One-time database setup |
| `assets/foodics-logo.svg` | Optional. Add the Foodics logo here (see below). Without it the page shows a text wordmark. |

## Set up (about 15 minutes)

### 1. Supabase (where the answers are stored)
1. Create a project at supabase.com (free plan is enough). Choose a region close to your merchants.
2. Open **SQL Editor > New query**, paste all of `supabase/schema.sql`, click **Run**.
3. Open **Project Settings > API**. Copy the **Project URL** and the **anon / publishable** key.
   Never use the `service_role` key in this project.
4. Paste both into `config.js`.

### 2. GitHub (where the website lives)
1. Create a new repository (for example `foodics-market-survey`).
2. Upload the contents of this folder (`index.html`, `config.js`, `supabase/`, and `assets/` if you add the logo).
3. Open **Settings > Pages**. Under "Build and deployment" choose **Deploy from a branch**, branch `main`, folder `/ (root)`, and Save.
4. After about a minute the site is live at `https://<your-github-username>.github.io/<repo-name>/`.

### 3. Add the logo (optional)
Save the Foodics logo as `assets/foodics-logo.svg`. It is shown in white automatically on the purple background.

## Where the answers are
Supabase dashboard > **Table Editor**:
- `responses_flat`: one row per respondent, one readable column per question. Use this one. **Export > CSV** is in the top right of the table.
- `responses`: the raw data.

## Tracking where answers come from
Add `?src=` to any link you send, for example `.../?src=whatsapp` or `.../?src=association`. The value is saved with each response.

## Changing questions
All questions and both languages live in the `QUESTIONS` list inside `index.html`. Each question has `req: true` if it must be answered. Remove or add `req: true` to change which are required.
