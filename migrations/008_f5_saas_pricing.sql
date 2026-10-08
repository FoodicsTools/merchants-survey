-- 008: F5 ID asked up front, software (SaaS) spend, after-sales rating, price follow-ups, new pricing question wording.
-- Older rows keep working: the old contact.f5_id still shows in "F5 ID"; 'A lower price' stays in option_labels for old answers.

insert into public.option_labels (question, code, label) values
('saasSpendOn','accounting','Accounting and e-invoicing (ZATCA)'),
('saasSpendOn','payroll','Payroll and HR'),
('saasSpendOn','inventory','Inventory and supplier ordering'),
('saasSpendOn','online','Online ordering website or app'),
('saasSpendOn','delivery','Delivery-app management'),
('saasSpendOn','marketing','Marketing and WhatsApp messaging'),
('saasSpendOn','loyalty','Loyalty and CRM'),
('saasSpendOn','payments','Payment gateways'),
('saasSpendOn','reporting','Reporting and analytics'),
('saasSpendOn','scheduling','Staff scheduling'),
('saasSpendOn','reservations','Table reservations'),
('saasSpendOn','office','Office and communication tools'),
('saasSpendOn','other','Other'),
('saasSpendOn','none','None'),
('priceWhy','price','The price itself'),
('priceWhy','capability','Product capability'),
('priceWhy','support','Customer support'),
('priceWhy','account','Account management'),
('priceWhy','onboarding','Onboarding'),
('priceWhy','other','Other'),
('priceView','good','Good value for the price'),
('priceView','same','About the same as other providers'),
('priceView','higher','Price is higher than the value I would expect'),
('priceView','cheaper','Other providers give me what I need for less'),
('priceView','unsure','I do not know Foodics well enough to say'),
('priceViewWhy','price','The price itself'),
('priceViewWhy','products','What I have heard about the products'),
('priceViewWhy','support','What I have heard about the support'),
('priceViewWhy','offers','Offers from other providers'),
('priceViewWhy','merchants','What other merchants say'),
('priceViewWhy','other','Other'),
('pricingPref','monthly','Monthly installments')
on conflict (question, code) do update set label = excluded.label;

-- the pricing question wording/headers
update public.question_names set name = 'Preferred way to pay for the POS' where question = 'pricingPref';

insert into public.question_names (question, ord, name) values
('f5Id',2,'F5 ID'),
('saasSpend',13,'Software (SaaS) spend per year (SAR)'),
('saasSpendOn',14,'Software spend goes on'),
('afterSales',22,'After-sales service rating (1-5)'),
('priceWhy',24,'Why prices are not fully justified'),
('priceView',25,'Foodics price vs value (their view)'),
('priceViewWhy',26,'What gives that impression'),
('pricingPref',27,'Preferred way to pay for the POS')
on conflict (question) do update set ord = excluded.ord, name = excluded.name;
update public.question_names n set ord = v.ord from (values
('isCustomer',1),
('f5Id',2),
('position',3),
('entityType',4),
('branches',5),
('channels',6),
('salesTrend',7),
('plan',8),
('margins',9),
('onlineShare',10),
('salesDrivers',11),
('techSpend',12),
('saasSpend',13),
('saasSpendOn',14),
('aiUse',15),
('trend',16),
('nps',17),
('leaveReason',18),
('satisfaction',19),
('products',20),
('unhappy',21),
('afterSales',22),
('priceValue',23),
('priceWhy',24),
('priceView',25),
('priceViewWhy',26),
('pricingPref',27),
('wanted',28),
('finInterest',29),
('otherProvider',30),
('comeBack',31),
('foodicsPayWhy',32),
('workshop',33),
('techSat',34),
('challenges',35),
('manualWhere',36),
('unmet',37),
('guestTool',38),
('guestSat',39)
) as v(question, ord) where n.question = v.question;

update public.survey_question_text t set num = v.ord from (values
('isCustomer',1),
('f5Id',2),
('position',3),
('entityType',4),
('branches',5),
('channels',6),
('salesTrend',7),
('plan',8),
('margins',9),
('onlineShare',10),
('salesDrivers',11),
('techSpend',12),
('saasSpend',13),
('saasSpendOn',14),
('aiUse',15),
('trend',16),
('nps',17),
('leaveReason',18),
('satisfaction',19),
('products',20),
('unhappy',21),
('afterSales',22),
('priceValue',23),
('priceWhy',24),
('priceView',25),
('priceViewWhy',26),
('pricingPref',27),
('wanted',28),
('finInterest',29),
('otherProvider',30),
('comeBack',31),
('foodicsPayWhy',32),
('workshop',33),
('techSat',34),
('challenges',35),
('manualWhere',36),
('unmet',37),
('guestTool',38),
('guestSat',39)
) as v(question, ord) where t.question = v.question;

insert into public.survey_question_text (question, num, header, customers, stopped, never) values
('f5Id',2,'F5 ID','What is your F5 ID? (We may already know some details about your business through your F5 ID. We still ask the next questions so we can double-check them and make sure we have the full picture.)',null,null),
('saasSpend',13,'Software (SaaS) spend per year (SAR)','How much does your business spend on software subscriptions (SaaS) in a year, in SAR?','How much does your business spend on software subscriptions (SaaS) in a year, in SAR?','How much does your business spend on software subscriptions (SaaS) in a year, in SAR?'),
('saasSpendOn',14,'Software spend goes on','Which kinds of software do you pay for? (Besides your POS system. Select all that apply.)','Which kinds of software do you pay for? (Besides your POS system. Select all that apply.)','Which kinds of software do you pay for? (Besides your POS system. Select all that apply.)'),
('afterSales',22,'After-sales service rating (1-5)','How would you rate Foodics'' after-sales service?','How did you rate Foodics'' after-sales service?',null),
('priceWhy',24,'Why prices are not fully justified','What makes the price feel less than fully justified? (shown if they rate prices 1 to 3)','What made the price feel less than fully justified? (shown if they rate prices 1 to 3)',null),
('priceView',25,'Foodics price vs value (their view)',null,null,'From what you know or have heard, how does Foodics'' price compare with the value it offers?'),
('priceViewWhy',26,'What gives that impression',null,null,'What gives you that impression? (shown if they answer: price higher than the value, or other providers for less)')
on conflict (question) do update set num = excluded.num, header = excluded.header, customers = excluded.customers, stopped = excluded.stopped, never = excluded.never;

update public.survey_question_text set header = 'Preferred way to pay for the POS',
  customers = 'How would you prefer to pay for your POS subscription? (current customers see it only if they rate prices 1 to 3)', stopped = 'How would you prefer to pay for your POS subscription?', never = 'How would you prefer to pay for your POS subscription?'
where question = 'pricingPref';

-- results views: append the new columns to the base view, then rebuild the group views
create or replace view public.responses_base with (security_invoker = true) as
select
  id,
  (created_at at time zone 'Asia/Riyadh') as submitted,
  case language when 'ar' then 'Arabic' when 'en' then 'English' else language end as language,
  coalesce(answers->>'isCustomer', case when is_customer then 'yes' else 'no' end) as status_code,
  case coalesce(answers->>'isCustomer', case when is_customer then 'yes' else 'no' end) when 'yes' then 'Foodics customer' when 'former' then 'Former Foodics customer' else 'Never used Foodics' end as customer_status,
  case when duration_seconds is null then null else (duration_seconds / 60) || ' min ' || (duration_seconds % 60) || ' sec' end as time_spent,
  coalesce(nullif(source, ''), '(no tag)') as link_tag,
  public.ans(answers,'position') as position,
  public.ans(answers,'entityType') as business_type,
  public.ans(answers,'branches') as branches,
  public.ans(answers,'channels') as channels,
  public.ans(answers,'salesTrend') as sales_trend,
  public.ans(answers,'plan') as plan_12m,
  public.ans(answers,'margins') as margins,
  public.ans(answers,'onlineShare') as online_share,
  public.ans(answers,'salesDrivers') as sales_drivers,
  public.ans(answers,'techSpend') as tech_spend,
  public.ans(answers,'aiUse') as ai_use,
  public.ans(answers,'trend') as biggest_change,
  public.to_int(answers->>'nps') as nps,
  public.ans(answers,'leaveReason') as leave_reason,
  public.to_int(answers->>'satisfaction') as satisfaction,
  public.ans(answers,'products') as products_used,
  public.cell(answers,'unhappy', public.unhappy_text(answers) || coalesce(' | Note: ' || nullif(trim(answers->>'unhappy_note'), ''), '')) as unhappy,
  public.to_int(answers->>'priceValue') as price_justified,
  public.ans(answers,'pricingPref') as preferred_pricing,
  public.ans(answers,'wanted') as wanted,
  public.to_int(answers->>'finInterest') as banking_interest,
  public.ans(answers,'otherProvider') as other_provider,
  public.ans(answers,'comeBack') as come_back,
  public.ans(answers,'foodicsPayWhy') as foodics_pay_why,
  public.to_int(answers->>'workshop') as workshop,
  public.to_int(answers->>'techSat') as tech_sat,
  public.ans(answers,'challenges') as challenges,
  public.ans(answers,'manualWhere') as manual_where,
  public.ans(answers,'unmet') as unmet,
  public.ans(answers,'guestTool') as guest_tool,
  public.to_int(answers->>'guestSat') as guest_sat,
  coalesce(nullif(trim(contact->>'name'), ''), 'Not provided') as contact_name,
  coalesce(nullif(trim(contact->>'entity'), ''), 'Not provided') as contact_business,
  coalesce(nullif(trim(contact->>'email'), ''), 'Not provided') as contact_email,
  coalesce(nullif(trim(contact->>'phone'), ''), 'Not provided') as contact_phone,
  coalesce(nullif(trim(contact->>'foodics_account'), ''), 'Not provided') as foodics_account,
  coalesce(nullif(trim(contact->>'f5_id'), ''), 'Not provided') as f5_id,
  coalesce(public.lbls('contactPrefs', contact->'prefs'), 'None selected') as contact_prefs,
  coalesce(nullif(trim(contact->>'f5_id'), ''), case when answers->>'f5Id' = '__skip' then 'Does not know' else nullif(trim(answers->>'f5Id'), '') end) as f5_answer,
  public.cell(answers, 'saasSpend', case when answers->>'saasSpend' = '__skip' then 'Not sure' else answers->>'saasSpend' end) as saas_spend,
  public.ans(answers, 'saasSpendOn') as saas_spend_on,
  public.to_int(answers->>'afterSales') as after_sales,
  public.ans(answers, 'priceWhy') as price_why,
  public.ans(answers, 'priceView') as price_view,
  public.ans(answers, 'priceViewWhy') as price_view_why
from public.responses;

drop view if exists public.responses_flat_with_questions;
drop view if exists public.responses_customers_with_questions;
drop view if exists public.responses_former_with_questions;
drop view if exists public.responses_never_with_questions;
drop view if exists public.responses_flat;
drop view if exists public.responses_customers;
drop view if exists public.responses_former;
drop view if exists public.responses_never;

create view public.responses_flat with (security_invoker = true) as
select
  submitted as "Submitted (Riyadh time)",
  language as "Language",
  customer_status as "Customer status",
  time_spent as "Time spent",
  link_tag as "Link tag",
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
  saas_spend as "Software (SaaS) spend per year (SAR)",
  saas_spend_on as "Software spend goes on",
  ai_use as "Where AI is used",
  biggest_change as "Biggest change coming (their words)",
  wanted as "Product or service wanted",
  banking_interest as "Interest in banking-type services (1-5)",
  other_provider as "Other provider / current system",
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
  contact_prefs as "Contact preferences"
from public.responses_base
order by submitted desc;

create view public.responses_customers with (security_invoker = true) as
select
  submitted as "Submitted (Riyadh time)",
  language as "Language",
  time_spent as "Time spent",
  f5_answer as "F5 ID",
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
  saas_spend as "Software (SaaS) spend per year (SAR)",
  saas_spend_on as "Software spend goes on",
  ai_use as "Where AI is used",
  biggest_change as "Biggest change coming (their words)",
  nps as "Recommend Foodics (0-10)",
  satisfaction as "Satisfaction with Foodics (1-10)",
  products_used as "Foodics products used",
  unhappy as "Products not fully satisfied with (and why)",
  after_sales as "After-sales service rating (1-5)",
  price_justified as "Foodics prices justified (1-5)",
  price_why as "Why prices are not fully justified",
  preferred_pricing as "Preferred way to pay for the POS",
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
  contact_prefs as "Contact preferences"
from public.responses_base
where status_code = 'yes'
order by submitted desc;

create view public.responses_former with (security_invoker = true) as
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
  saas_spend as "Software (SaaS) spend per year (SAR)",
  saas_spend_on as "Software spend goes on",
  ai_use as "Where AI is used",
  biggest_change as "Biggest change coming (their words)",
  leave_reason as "Main reason for leaving Foodics",
  satisfaction as "Satisfaction with Foodics (1-10)",
  products_used as "Foodics products used",
  unhappy as "Products not fully satisfied with (and why)",
  after_sales as "After-sales service rating (1-5)",
  price_justified as "Foodics prices justified (1-5)",
  price_why as "Why prices are not fully justified",
  preferred_pricing as "Preferred way to pay for the POS",
  wanted as "Product or service wanted",
  banking_interest as "Interest in banking-type services (1-5)",
  other_provider as "Other provider / current system",
  come_back as "What would bring them back",
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
  contact_prefs as "Contact preferences"
from public.responses_base
where status_code = 'former'
order by submitted desc;

create view public.responses_never with (security_invoker = true) as
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
  saas_spend as "Software (SaaS) spend per year (SAR)",
  saas_spend_on as "Software spend goes on",
  ai_use as "Where AI is used",
  biggest_change as "Biggest change coming (their words)",
  price_view as "Foodics price vs value (their view)",
  price_view_why as "What gives that impression",
  preferred_pricing as "Preferred way to pay for the POS",
  wanted as "Product or service wanted",
  banking_interest as "Interest in banking-type services (1-5)",
  other_provider as "Other provider / current system",
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
  contact_prefs as "Contact preferences"
from public.responses_base
where status_code = 'no'
order by submitted desc;


revoke all on public.responses_base, public.responses_flat, public.responses_customers, public.responses_former, public.responses_never from public;
grant select on public.responses_base, public.responses_flat, public.responses_customers, public.responses_former, public.responses_never to survey_reader;

-- "with questions" versions (row 2 = full question), then the Excel UTF-8 marker, exactly as in 006 and 007
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
    -- invisible UTF-8 marker (U+FEFF) at the start of the first header: Excel then reads the CSV as UTF-8 (Arabic shows correctly)
    cols := format('%I as %I', firstcol, chr(65279) || firstcol) || substr(cols, length(format('%I', firstcol)) + 1);
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
do $do$
declare v text; c text;
begin
  foreach v in array array['responses_flat','responses_customers','responses_former','responses_never'] loop
    select column_name into c from information_schema.columns
     where table_schema = 'public' and table_name = v order by ordinal_position limit 1;
    if c is not null and left(c, 1) <> chr(65279) then
      execute format('alter view public.%I rename column %I to %I', v, c, chr(65279) || c);
    end if;
  end loop;
end
$do$;