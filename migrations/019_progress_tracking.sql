-- 019: where do merchants stop? The survey reports each question a merchant reaches (question id and position only,
-- never answers). Two views turn that into: one row per visit, and one row per question with how many stopped there.
create table public.survey_progress (
  id             uuid primary key default gen_random_uuid(),
  created_at     timestamptz not null default now(),
  sid            text        not null,   -- one id per visit, also saved inside the final answers as answers._sid
  survey_version text        not null,
  language       text        check (language in ('en','ar')),
  grp            text        check (grp in ('yes','former','no')),
  country        text,
  source         text,
  q_id           text        not null,   -- question reached ('intro' = opened the link)
  q_index        integer     not null,   -- its position on this merchant's path
  q_total        integer     not null,   -- how many questions are on this merchant's path
  seconds        integer,
  constraint progress_sid_len check (length(sid) between 8 and 64)
);
create index survey_progress_sid_idx on public.survey_progress (sid);
create index survey_progress_created_idx on public.survey_progress (created_at);

revoke all on public.survey_progress from public;
grant insert on public.survey_progress to survey_writer;
grant select on public.survey_progress to survey_reader;

-- one row per visit: how far did they get?
create view public.visitor_journeys with (security_invoker = true) as
with last_ev as (
  select distinct on (sid) sid, q_id, q_index, q_total, grp, language, source
  from public.survey_progress
  order by sid, q_index desc, created_at desc
),
span as (
  select sid, min(created_at) as first_seen, max(created_at) as last_seen, max(seconds) as secs
  from public.survey_progress group by sid
),
done as (
  select distinct answers->>'_sid' as sid from public.responses where answers ? '_sid'
)
select
  (s.first_seen at time zone 'Asia/Riyadh') as "Visit started (Riyadh time)",
  (s.last_seen at time zone 'Asia/Riyadh')  as "Last activity (Riyadh time)",
  case l.grp when 'yes' then 'Foodics customer' when 'former' then 'Former Foodics customer'
             when 'no' then 'Never used Foodics' else 'Not yet answered' end as "Type of merchant",
  case l.language when 'ar' then 'Arabic' when 'en' then 'English' end as "Language",
  coalesce(l.source, '(no tag)') as "Link tag",
  case l.q_id when 'intro' then 'Opened the link (front page)'
              when 'contact' then 'Last page (contact details)'
              else coalesce(n.name, l.q_id) end as "Furthest question reached",
  l.q_index as "Question number reached",
  l.q_total as "Questions on their path",
  case when d.sid is not null then 'Completed'
       when s.last_seen > now() - interval '30 minutes' then 'Still answering (active in the last 30 minutes)'
       else 'Stopped' end as "Status",
  round(s.secs / 60.0, 1) as "Minutes in the survey"
from last_ev l
join span s on s.sid = l.sid
left join done d on d.sid = l.sid
left join public.question_names n on n.question = l.q_id
order by s.first_seen desc;

-- one row per question: how many reached it and how many gave up right there
create view public.dropoff_by_question with (security_invoker = true) as
with last_ev as (
  select distinct on (sid) sid, q_id from public.survey_progress order by sid, q_index desc, created_at desc
),
status as (
  select l.sid, l.q_id,
         case when d.sid is not null then 'done'
              when s.last_seen > now() - interval '30 minutes' then 'active'
              else 'stopped' end as st
  from last_ev l
  join (select sid, max(created_at) as last_seen from public.survey_progress group by sid) s on s.sid = l.sid
  left join (select distinct answers->>'_sid' as sid from public.responses where answers ? '_sid') d on d.sid = l.sid
),
reach as (select q_id, count(distinct sid) as n from public.survey_progress group by q_id),
stop as (select q_id, count(*) filter (where st = 'stopped') as n_stop from status group by q_id),
names as (
  select 'intro'::text as q_id, 0 as ord, 'Opened the link (front page)'::text as name
  union all select question, ord, name from public.question_names
  union all select 'contact', 999, 'Last page (contact details)'
)
select
  n.ord  as "Order in survey",
  n.name as "Question",
  coalesce(r.n, 0) as "Merchants who reached it",
  coalesce(s.n_stop, 0) as "Stopped here",
  round(100.0 * coalesce(s.n_stop, 0) / nullif(r.n, 0)) as "Stopped here, % of those who reached it"
from names n
left join reach r on r.q_id = n.q_id
left join stop s on s.q_id = n.q_id
where coalesce(r.n, 0) > 0
order by n.ord;

revoke all on public.visitor_journeys, public.dropoff_by_question from public;
grant select on public.visitor_journeys, public.dropoff_by_question to survey_reader;