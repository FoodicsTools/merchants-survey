-- 002: readable results. Full wording instead of codes, clear column headers, one view per group of merchants
-- (so there are no empty columns), plus skipped-question tracking. Raw data in public.responses is untouched.
-- Wording is generated from the survey's own option list.

create table public.option_labels (
  question text not null,
  code     text not null,
  label    text not null,
  primary key (question, code)
);
insert into public.option_labels (question, code, label) values
('isCustomer','yes','Yes, I use Foodics'),
('isCustomer','former','I stopped using Foodics (not a Foodics merchant anymore)'),
('isCustomer','no','No, I''ve never used Foodics'),
('position','owner','Owner / founder'),
('position','gm','General manager / operations'),
('position','finance','Finance'),
('position','it','IT / technology'),
('position','marketing','Marketing'),
('position','other','Other'),
('entityType','restaurant','Restaurant'),
('entityType','cafe','Café'),
('entityType','bakery','Bakery or sweets'),
('entityType','cloud','Cloud kitchen'),
('entityType','catering','Catering'),
('entityType','other','Other'),
('branches','1','1 branch'),
('branches','2-3','2 to 3'),
('branches','4-9','4 to 9'),
('branches','10-24','10 to 24'),
('branches','25-99','25 to 99'),
('branches','100+','100 or more'),
('channels','dinein','Dine-in'),
('channels','takeaway','Takeaway'),
('channels','delivery','Delivery apps'),
('channels','own','Own website or app'),
('channels','qr','QR ordering'),
('channels','paytable','Pay-at-table'),
('channels','kiosk','Kiosk'),
('channels','reservations','Reservations'),
('salesTrend','up2','Up a lot'),
('salesTrend','up1','Up slightly'),
('salesTrend','flat','About the same'),
('salesTrend','dn1','Down slightly'),
('salesTrend','dn2','Down a lot'),
('plan','open','Open new branches'),
('plan','same','Stay as we are'),
('plan','close','Close some'),
('margins','food','Food costs'),
('margins','rent','Rent'),
('margins','labour','Labour and hiring'),
('margins','commissions','Delivery commissions'),
('margins','fees','Payment fees'),
('margins','competition','Competition'),
('margins','regulation','Regulation and e-invoicing'),
('margins','demand','Weaker demand'),
('onlineShare','lt10','Less than 10%'),
('onlineShare','10-25','10–25%'),
('onlineShare','26-50','26–50%'),
('onlineShare','gt50','More than 50%'),
('onlineShare','unsure','Not sure'),
('salesDrivers','promos','Promotions and discounts'),
('salesDrivers','loyalty','Loyalty program'),
('salesDrivers','delivery','Delivery apps'),
('salesDrivers','social','Social media and influencers'),
('salesDrivers','pricing','Pricing changes'),
('salesDrivers','branches','Opening new branch(es)'),
('salesDrivers','other','Other'),
('techSpend','up','Increase'),
('techSpend','same','Stay the same'),
('techSpend','down','Decrease'),
('aiUse','marketing','Marketing content'),
('aiUse','guests','Replying to guests'),
('aiUse','forecast','Forecasting and ordering'),
('aiUse','accounting','Accounting'),
('aiUse','menu','Menu and pricing'),
('aiUse','other','Other tools'),
('aiUse','none','I don''t use AI yet'),
('aiUse','want','I''d like to, but don''t know where to start'),
('leaveReason','price','Price or subscription cost'),
('leaveReason','lowuse','We weren''t using enough features to justify the cost'),
('leaveReason','support','Support quality or slow problem resolution'),
('leaveReason','stability','Instability'),
('leaveReason','ease','Hard to use or weak training'),
('leaveReason','missing','Missing products or features we need'),
('leaveReason','integration','Weak integration with other systems'),
('leaveReason','switched','We moved to a system that suits our needs better'),
('leaveReason','closed','The business closed or changed its model'),
('leaveReason','other','Other'),
('pricingPref','annual','Full amount per year'),
('pricingPref','installments','Installments'),
('pricingPref','bundle3','3-year bundle with a discount'),
('pricingPref','other','Other'),
('wanted','hr','HR'),
('wanted','forecast','Demand forecasting'),
('wanted','procure','Supplier ordering and procurement'),
('wanted','marketing','Marketing services'),
('wanted','reports','Deeper reports and benchmarks'),
('wanted','other','Other'),
('wanted','none','Nothing more for now'),
('comeBack','pricing','More flexible pricing or plans'),
('comeBack','onboarding','Better explanation and activation of products and features'),
('comeBack','training','Hands-on training for my team'),
('comeBack','support','Faster and more effective support'),
('comeBack','stability','Higher system stability'),
('comeBack','features','Better features or integrations'),
('comeBack','manager','Stronger account manager follow-up'),
('comeBack','none','I''m not considering coming back'),
('comeBack','other','Other'),
('foodicsPayWhy','unconvinced','I''m not convinced it''s worth it'),
('foodicsPayWhy','unaware','I don''t know about it'),
('foodicsPayWhy','benefits','I don''t know what the benefits are'),
('foodicsPayWhy','other','Other'),
('challenges','devices','My devices don''t connect to each other'),
('challenges','manual','Too much manual work'),
('challenges','costs','Rising operating costs'),
('challenges','loan','Difficulty getting a loan'),
('challenges','accounting','Accounting problems'),
('challenges','inventory','Inventory problems'),
('challenges','other','Other'),
('manualWhere','menu','Menu and price updates'),
('manualWhere','recon','Reconciling orders'),
('manualWhere','inventory','Inventory'),
('manualWhere','payments','Payments and settlement'),
('manualWhere','accounting','Accounting'),
('manualWhere','reporting','Reporting'),
('manualWhere','scheduling','Staff scheduling'),
('unmet','profit','Knowing my real profit per branch'),
('unmet','waste','Cutting food waste and stock-outs'),
('unmet','staff','Finding and keeping good staff'),
('unmet','guests','Bringing guests back more often'),
('unmet','commissions','Cutting delivery-app commissions'),
('unmet','cash','Cash flow and financing'),
('unmet','compliance','Keeping up with regulation and e-invoicing'),
('unmet','none','Nothing, I''m covered'),
('unmet','other','Other'),
('guestTool','loyalty','A loyalty program in my system'),
('guestTool','messages','WhatsApp, Instagram or manual messages'),
('guestTool','sheet','A spreadsheet or notes'),
('guestTool','other','Other'),
('guestTool','none','Nothing yet'),
('products','pos','Point of Sale Solution'),
('products','black','Foodics Black'),
('products','paytable','Pay at Table'),
('products','cds','Customer Display Screen'),
('products','pay','Foodics Pay'),
('products','self','Self Ordering'),
('products','waiter','Waiter App'),
('products','online','Online'),
('products','kds','Kitchen Display Screen'),
('products','acct','Foodics Accounting'),
('products','one','Foodics One'),
('products','capital','Foodics Capital'),
('products','notsure','Not sure'),
('reasons','price','Price vs value'),
('reasons','stability','Instability'),
('reasons','missing','Missing features'),
('reasons','ease','Hard to use'),
('reasons','support','Support'),
('reasons','training','Training'),
('contactPrefs','interview','Invite me to a short interview'),
('contactPrefs','testing','Invite me to test new products'),
('contactPrefs','contact','Have Foodics contact me'),
('contactPrefs','report','Send me the report when it''s published'),
('contactPrefs','none','Please don''t contact me'),
('otherProvider','none','No other provider (Foodics only, or no system yet)'),
('otherProvider','yes','Uses another provider'),
('branches','1-5','1 to 5 (old band)'),
('branches','6-50','6 to 50 (old band)'),
('branches','51+','51 or more (old band)');

create table public.question_names (
  question text primary key,
  ord      integer not null,
  name     text not null
);
insert into public.question_names (question, ord, name) values
('isCustomer',1,'Customer status'),
('position',2,'Position'),
('entityType',3,'Business type'),
('branches',4,'Number of branches'),
('channels',5,'Sales channels'),
('salesTrend',6,'Sales vs last 12 months'),
('plan',7,'Plan for next 12 months'),
('margins',8,'What squeezes margins'),
('onlineShare',9,'Online and delivery share of sales'),
('salesDrivers',10,'What drove sales'),
('techSpend',11,'Technology spend next 12 months'),
('aiUse',12,'Where AI is used'),
('trend',13,'Biggest change coming'),
('nps',14,'Recommend Foodics (0-10)'),
('leaveReason',15,'Main reason for leaving Foodics'),
('satisfaction',16,'Satisfaction with Foodics (1-10)'),
('products',17,'Foodics products used'),
('unhappy',18,'Products not fully satisfied with'),
('priceValue',19,'Foodics prices justified (1-5)'),
('pricingPref',20,'Preferred pricing'),
('wanted',21,'Product or service wanted'),
('finInterest',22,'Interest in banking-type services (1-5)'),
('otherProvider',23,'Other provider / current system'),
('comeBack',24,'What would bring them back'),
('foodicsPayWhy',25,'Why not using Foodics Pay'),
('workshop',26,'Interest in workshops (1-10)'),
('techSat',27,'Technology satisfaction (1-5)'),
('challenges',28,'Biggest challenges'),
('manualWhere',29,'Where manual work hurts'),
('unmet',30,'Unmet needs'),
('guestTool',31,'How guests are brought back'),
('guestSat',32,'Guest engagement satisfaction (1-5)');

-- one code -> its wording (falls back to the code itself, so free text passes through unchanged)
create function public.lbl(q text, c text) returns text
language sql stable as $$
  select coalesce((select label from public.option_labels where question = q and code = c), c)
$$;

-- one answer or a list of answers -> wording, separated by ", "
create function public.lbls(q text, j jsonb) returns text
language sql stable as $$
  select case
    when j is null then null
    when jsonb_typeof(j) = 'array' then
      (select string_agg(public.lbl(q, x.v), ', ' order by x.ord)
         from jsonb_array_elements_text(j) with ordinality as x(v, ord))
    else public.lbl(q, j #>> '{}')
  end
$$;

-- puts what the merchant typed next to "Other"
create function public.with_other(t text, o text) returns text
language sql immutable as $$
  select case
    when nullif(trim(o), '') is null then t
    when t is null then 'Other: ' || trim(o)
    when exists (select 1 from unnest(string_to_array(t, ', ')) as x(v) where x.v in ('Other', 'Other tools')) then
      (select string_agg(case when x.v in ('Other', 'Other tools') then x.v || ': ' || trim(o) else x.v end, ', ' order by x.ord)
         from unnest(string_to_array(t, ', ')) with ordinality as x(v, ord))
    else t || ': ' || trim(o)
  end
$$;

create function public.to_int(t text) returns integer
language sql immutable as $$
  select case when t ~ '^[0-9]+$' then t::integer end
$$;

-- "Foodics Pay (Instability), Online (Price vs value)"
create function public.unhappy_text(a jsonb) returns text
language sql stable as $$
  select case
    when a->>'unhappy_all' = 'true' then 'Satisfied with all products'
    when jsonb_typeof(a->'unhappy') = 'object' and a->'unhappy' <> '{}'::jsonb then
      (select string_agg(public.lbl('products', e.key) || ' (' ||
                         coalesce(nullif(public.lbl('reasons', e.value), ''), 'no reason given') || ')', ', ' order by e.key)
         from jsonb_each_text(a->'unhappy') as e)
  end
$$;

-- was this question answered? (a skipped question was shown to the merchant but left empty)
create function public.is_answered(a jsonb, q text) returns boolean
language sql immutable as $$
  select coalesce(
    case q
      when 'unhappy' then coalesce(a->>'unhappy_all', 'false') = 'true'
                          or coalesce(jsonb_typeof(a->'unhappy') = 'object' and a->'unhappy' <> '{}'::jsonb, false)
      when 'branches' then a->>'branches' is not null or nullif(a->>'branches_exact', '') is not null
      else case jsonb_typeof(a->q)
             when 'array'  then jsonb_array_length(a->q) > 0
             when 'string' then nullif(trim(a->>q), '') is not null
             when 'number' then true
             when 'object' then true
             else false end
    end, false)
$$;

-- shows the answer, or says why it is blank: 'Skipped' (shown, left empty) or 'Not asked' (not part of this merchant's path)
create function public.cell(a jsonb, q text, v text) returns text
language sql immutable as $$
  select case
    when nullif(trim(v), '') is not null then v
    when a->'_shown' is null then null
    when (a->'_shown') ? q then 'Skipped'
    else 'Not asked'
  end
$$;

-- a question's answer in full wording, with any typed "Other" text
create function public.ans(a jsonb, q text) returns text
language sql stable as $$
  select public.cell(a, q, public.with_other(public.lbls(q, a->q), a->>(q || '_other')))
$$;

create function public.skipped_list(a jsonb) returns text
language sql stable as $$
  select string_agg(n.name, ', ' order by n.ord)
    from jsonb_array_elements_text(a->'_shown') as s(id)
    join public.question_names n on n.question = s.id
   where not public.is_answered(a, s.id)
$$;

-- every readable column for every merchant; the views below pick the columns that apply to each group
create view public.responses_base with (security_invoker = true) as
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
  coalesce(public.lbls('contactPrefs', contact->'prefs'), 'None selected') as contact_prefs
from public.responses;

drop view public.responses_flat;

-- all merchants together: only the questions everybody was asked
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

-- current Foodics customers
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

-- merchants who stopped using Foodics
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
  ai_use as "Where AI is used",
  biggest_change as "Biggest change coming (their words)",
  leave_reason as "Main reason for leaving Foodics",
  satisfaction as "Satisfaction with Foodics (1-10)",
  products_used as "Foodics products used",
  unhappy as "Products not fully satisfied with (and why)",
  price_justified as "Foodics prices justified (1-5)",
  preferred_pricing as "Preferred pricing",
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
  foodics_account as "Foodics account number",
  f5_id as "F5 ID",
  contact_prefs as "Contact preferences"
from public.responses_base
where status_code = 'former'
order by submitted desc;

-- merchants who never used Foodics
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
  ai_use as "Where AI is used",
  biggest_change as "Biggest change coming (their words)",
  preferred_pricing as "Preferred pricing",
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

-- per merchant: which questions were skipped
create view public.responses_skips with (security_invoker = true) as
select
  (r.created_at at time zone 'Asia/Riyadh') as "Submitted (Riyadh time)",
  case coalesce(r.answers->>'isCustomer', case when r.is_customer then 'yes' else 'no' end)
    when 'yes' then 'Foodics customer' when 'former' then 'Former Foodics customer' else 'Never used Foodics' end as "Customer status",
  case when r.answers->'_shown' is not null then jsonb_array_length(r.answers->'_shown') end as "Questions shown",
  case when r.answers->'_shown' is not null then
    (select count(*) from jsonb_array_elements_text(r.answers->'_shown') as s(id) where not public.is_answered(r.answers, s.id)) end as "Questions skipped",
  case when r.answers->'_shown' is not null then coalesce(public.skipped_list(r.answers), 'None skipped')
       else 'Not recorded (older survey version)' end as "Skipped questions"
from public.responses r
order by r.created_at desc;

-- per question: how often it was shown and skipped
create view public.question_skip_rates with (security_invoker = true) as
select
  n.ord as "Order in survey",
  n.name as "Question",
  count(*) filter (where (r.answers->'_shown') ? n.question) as "Times shown",
  count(*) filter (where (r.answers->'_shown') ? n.question and not public.is_answered(r.answers, n.question)) as "Times skipped",
  round(100.0 * count(*) filter (where (r.answers->'_shown') ? n.question and not public.is_answered(r.answers, n.question))
        / nullif(count(*) filter (where (r.answers->'_shown') ? n.question), 0)) as "Skipped %"
from public.question_names n
left join public.responses r on true
group by n.ord, n.name
order by n.ord;

revoke all on public.option_labels, public.question_names, public.responses_base, public.responses_flat,
  public.responses_customers, public.responses_former, public.responses_never,
  public.responses_skips, public.question_skip_rates from public;
grant select on public.option_labels, public.question_names, public.responses_base, public.responses_flat,
  public.responses_customers, public.responses_former, public.responses_never,
  public.responses_skips, public.question_skip_rates to survey_reader;
grant execute on function public.lbl(text, text), public.lbls(text, jsonb), public.with_other(text, text),
  public.to_int(text), public.unhappy_text(jsonb), public.is_answered(jsonb, text), public.cell(jsonb, text, text),
  public.ans(jsonb, text), public.skipped_list(jsonb) to survey_reader;