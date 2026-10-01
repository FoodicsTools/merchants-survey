-- Foodics Market Insights Survey: database setup
-- Run this once in Supabase: SQL Editor > New query > paste > Run.

-- 1. Table that stores one row per submitted survey
create table if not exists public.responses (
  id               uuid primary key default gen_random_uuid(),
  created_at       timestamptz not null default now(),
  survey_version   text        not null default 'v1',
  language         text        check (language in ('en','ar')),
  consent          boolean     not null,
  is_customer      boolean,
  duration_seconds integer,
  source           text,                              -- from ?src=... in the survey link
  answers          jsonb       not null default '{}'::jsonb,
  contact          jsonb       not null default '{}'::jsonb,   -- optional name, email, phone, preferences
  constraint consent_required check (consent = true),
  constraint answers_size     check (pg_column_size(answers) < 30000),
  constraint contact_size     check (pg_column_size(contact) < 4000)
);

-- 2. Security: visitors (the public "anon" key) may ONLY add rows. They can never read them.
alter table public.responses enable row level security;

drop policy if exists "survey visitors can submit" on public.responses;
create policy "survey visitors can submit"
  on public.responses for insert to anon
  with check (consent = true);

revoke all on public.responses from anon;
grant insert on public.responses to anon;

-- 3. A readable, flat version of the data for you (one column per question).
create or replace function public.jsonb_list(j jsonb) returns text
language sql immutable as $$
  select case
    when j is null then null
    when jsonb_typeof(j) = 'array' then (select string_agg(x, '; ') from jsonb_array_elements_text(j) x)
    else j #>> '{}'
  end
$$;

create or replace view public.responses_flat with (security_invoker = true) as
select
  id, created_at, language, is_customer, duration_seconds, source,
  -- Section 1
  answers->>'position'            as position,
  answers->>'position_other'      as position_other,
  answers->>'entityType'          as entity_type,
  answers->>'entityType_other'    as entity_type_other,
  answers->>'branches'            as branches,
  jsonb_list(answers->'markets')  as markets,
  answers->>'markets_other'       as markets_other,
  jsonb_list(answers->'channels') as channels,
  -- Section 2
  answers->>'satisfaction'        as satisfaction_1_10,
  jsonb_list(answers->'products') as products,
  answers->'unhappy'              as unhappy_products_and_reasons,
  answers->>'unhappy_all'         as satisfied_with_all,
  answers->>'unhappy_note'        as unhappy_note,
  jsonb_list(answers->'wanted')   as wanted_products,
  answers->>'wanted_other'        as wanted_other,
  answers->>'finInterest'         as financial_services_interest_1_5,
  answers->>'otherProvider'       as other_provider,
  answers->>'otherProvider_other' as other_provider_name,
  answers->>'foodicsPayWhy'       as foodics_pay_barrier,
  answers->>'foodicsPayWhy_other' as foodics_pay_barrier_other,
  answers->>'workshop'            as workshop_interest_1_10,
  -- Section 3
  answers->>'techSat'             as tech_satisfaction_1_5,
  jsonb_list(answers->'challenges')  as challenges,
  answers->>'challenges_other'    as challenges_other,
  jsonb_list(answers->'manualWhere') as manual_work_pain,
  jsonb_list(answers->'unmet')    as unmet_needs,
  answers->>'unmet_other'         as unmet_other,
  answers->>'guestTool'           as guest_tool,
  answers->>'guestTool_other'     as guest_tool_other,
  answers->>'guestSat'            as guest_engagement_satisfaction_1_5,
  -- Section 4
  answers->>'salesTrend'          as sales_trend_12m,
  answers->>'plan'                as plan_next_12m,
  jsonb_list(answers->'margins')  as margin_pressures,
  answers->>'onlineShare'         as online_share_of_sales,
  jsonb_list(answers->'salesDrivers') as sales_drivers,
  answers->>'techSpend'           as tech_spend_next_12m,
  jsonb_list(answers->'aiUse')    as ai_use,
  answers->>'aiUse_other'         as ai_use_other,
  answers->>'trend'               as biggest_change_coming,
  -- Contact (optional)
  contact->>'name'                as contact_name,
  contact->>'entity'              as contact_business,
  contact->>'email'               as contact_email,
  contact->>'phone'               as contact_phone,
  contact->>'foodics_account'     as foodics_account,
  jsonb_list(contact->'prefs')    as contact_preferences
from public.responses;
