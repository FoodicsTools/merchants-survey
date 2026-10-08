-- 005: customers who say prices are not justified (1-2) are now also asked about preferred pricing,
-- and every group gets a new answer option: 'A lower price'.
insert into public.option_labels (question, code, label) values ('pricingPref','lower','A lower price');

update public.survey_question_text set customers = stopped where question = 'pricingPref';

drop view if exists public.responses_customers_with_questions;
drop view if exists public.responses_customers;
create view public.responses_customers with (security_invoker = true) as
select
  submitted as "Submitted (Riyadh time)",
  language as "Language",
  time_spent as "Time spent",
  position as "Position",
  business_type as "Business type",
  branches as "Number of branches",
  channels as "Sales channels",
  sales_trend as "Sales vs last 12 months",
  plan_12m as "Plan for next 12 months",
  margins as "What squeezes margins",
  online_share as "Online and delivery share of sales",
  sales_drivers as "What drove sales",
  tech_spend as "Technology spend next 12 months",
  ai_use as "Where AI is used",
  biggest_change as "Biggest change coming (their words)",
  nps as "Recommend Foodics (0-10)",
  satisfaction as "Satisfaction with Foodics (1-10)",
  products_used as "Foodics products used",
  unhappy as "Products not fully satisfied with (and why)",
  price_justified as "Foodics prices justified (1-5)",
  preferred_pricing as "Preferred pricing",
  wanted as "Product or service wanted",
  banking_interest as "Interest in banking-type services (1-5)",
  other_provider as "Other provider / current system",
  foodics_pay_why as "Why not using Foodics Pay",
  workshop as "Interest in workshops (1-10)",
  tech_sat as "Technology satisfaction (1-5)",
  challenges as "Biggest challenges",
  manual_where as "Where manual work hurts",
  unmet as "Unmet needs",
  guest_tool as "How guests are brought back",
  guest_sat as "Guest engagement satisfaction (1-5)",
  contact_name as "Name",
  contact_business as "Business name",
  contact_email as "Email",
  contact_phone as "Phone",
  foodics_account as "Foodics account number",
  f5_id as "F5 ID",
  contact_prefs as "Contact preferences"
from public.responses_base
where status_code = 'yes'
order by submitted desc;
revoke all on public.responses_customers from public;
grant select on public.responses_customers to survey_reader;

-- 004: "with questions" versions of the results views. Row 1 = short column header, row 2 = the full question
-- (word for word), then the answers. Needed because Postgres cuts column names at 63 characters.
do $do$
declare
  v text; qcol text; qrow text; drow text; cols text; firstcol text; vn text;
begin
  foreach v in array array['responses_flat','responses_customers','responses_former','responses_never'] loop
    qcol := case v when 'responses_customers' then 't.customers'
                   when 'responses_former'    then 't.stopped'
                   when 'responses_never'     then 't.never'
                   else 'coalesce(t.customers, t.stopped, t.never)' end;
    select string_agg(format('(select %s from public.survey_question_text t where %L like t.header || ''%%'' order by length(t.header) desc limit 1)::text as %I', qcol, c.column_name, c.column_name), ', ' order by c.ordinal_position),
           string_agg(format('%I::text', c.column_name), ', ' order by c.ordinal_position),
           string_agg(format('%I', c.column_name), ', ' order by c.ordinal_position),
           (array_agg(c.column_name order by c.ordinal_position))[1]
      into qrow, drow, cols, firstcol
      from information_schema.columns c
     where c.table_schema = 'public' and c.table_name = v;
    vn := v || '_with_questions';
    execute format('drop view if exists public.%I', vn);
    execute format(
      'create view public.%I with (security_invoker = true) as select %s from (select 0 as k, %s union all select 1 as k, %s from public.%I) x order by k, %I',
      vn, cols, qrow, drow, v, firstcol);
    execute format('revoke all on public.%I from public', vn);
    execute format('grant select on public.%I to survey_reader', vn);
  end loop;
end
$do$;