-- 012: countries and currencies. The link carries the country (https://survey.foodics.com/?country=oman&src=whatsapp);
-- without it the survey asks 'Which country is your business in?'. Prices are answered in that country's currency.
-- Country + Currency columns now appear in every export view; 'survey_links' lists ready-made links.
insert into public.option_labels (question, code, label) values
('country','ksa','Saudi Arabia'),('country','oman','Oman'),('country','jordan','Jordan'),('country','uae','United Arab Emirates'),
('country','bahrain','Bahrain'),('country','kuwait','Kuwait'),('country','egypt','Egypt'),('country','other','Other country'),
('saasSpendOn','accounting','Accounting and e-invoicing')
on conflict (question, code) do update set label = excluded.label;

insert into public.question_names (question, ord, name) values ('country', 1, 'Country')
on conflict (question) do update set ord = excluded.ord, name = excluded.name;
update public.question_names n set ord = v.ord from (values
('country',1),
('isCustomer',2),
('f5Id',3),
('position',4),
('entityType',5),
('branches',6),
('channels',7),
('salesTrend',8),
('plan',9),
('margins',10),
('onlineShare',11),
('salesDrivers',12),
('techSpend',13),
('saasSpend',14),
('saasSpendOn',15),
('aiUse',16),
('trend',17),
('nps',18),
('leaveReason',19),
('satisfaction',20),
('products',21),
('unhappy',22),
('afterSales',23),
('priceValue',24),
('priceWhy',25),
('priceAcceptable',26),
('priceAcceptableWhy',27),
('priceView',28),
('priceViewWhy',29),
('pricingPref',30),
('wanted',31),
('finInterest',32),
('otherProvider',33),
('comeBack',34),
('foodicsPayWhy',35),
('workshop',36),
('techSat',37),
('challenges',38),
('manualWhere',39),
('unmet',40),
('guestTool',41),
('guestSat',42)
) as v(question, ord) where n.question = v.question;
update public.question_names set name = 'Software (SaaS) spend per year (local currency)' where question = 'saasSpend';
update public.question_names set name = 'Acceptable yearly POS price (local currency)' where question = 'priceAcceptable';

insert into public.survey_question_text (question, num, header, customers, stopped, never) values
('country', 1, 'Country', 'Which country is your business in? (only asked when the link has no country tag)', 'Which country is your business in? (only asked when the link has no country tag)', 'Which country is your business in? (only asked when the link has no country tag)')
on conflict (question) do update set num = excluded.num, header = excluded.header, customers = excluded.customers, stopped = excluded.stopped, never = excluded.never;
update public.survey_question_text t set num = v.ord from (values
('country',1),
('isCustomer',2),
('f5Id',3),
('position',4),
('entityType',5),
('branches',6),
('channels',7),
('salesTrend',8),
('plan',9),
('margins',10),
('onlineShare',11),
('salesDrivers',12),
('techSpend',13),
('saasSpend',14),
('saasSpendOn',15),
('aiUse',16),
('trend',17),
('nps',18),
('leaveReason',19),
('satisfaction',20),
('products',21),
('unhappy',22),
('afterSales',23),
('priceValue',24),
('priceWhy',25),
('priceAcceptable',26),
('priceAcceptableWhy',27),
('priceView',28),
('priceViewWhy',29),
('pricingPref',30),
('wanted',31),
('finInterest',32),
('otherProvider',33),
('comeBack',34),
('foodicsPayWhy',35),
('workshop',36),
('techSat',37),
('challenges',38),
('manualWhere',39),
('unmet',40),
('guestTool',41),
('guestSat',42)
) as v(question, ord) where t.question = v.question;
update public.survey_question_text set header = 'Software (SaaS) spend per year (local currency)',
  customers = 'How much does your business spend on software subscriptions (SaaS) in a year, in the merchant''s own currency (SAR, OMR, JOD, AED, BHD, KWD or EGP by country)?',
  stopped = 'How much does your business spend on software subscriptions (SaaS) in a year, in the merchant''s own currency (SAR, OMR, JOD, AED, BHD, KWD or EGP by country)?',
  never = 'How much does your business spend on software subscriptions (SaaS) in a year, in the merchant''s own currency (SAR, OMR, JOD, AED, BHD, KWD or EGP by country)?'
where question = 'saasSpend';
update public.survey_question_text set header = 'Acceptable yearly POS price (local currency)',
  customers = 'What price would you be willing to pay for your POS subscription yearly (in the merchant''s own currency)? (shown if prices are rated 1 to 3 and they pick The price itself as a reason)',
  stopped = 'What price would you have been willing to pay for your POS subscription yearly (in the merchant''s own currency)? (shown if prices are rated 1 to 3 and they pick The price itself as a reason)'
where question = 'priceAcceptable';

-- ready-made links, one per country and channel
create view public.survey_links with (security_invoker = true) as
select c."Country", c."Currency merchants answer in", c."Channel", c."Link"
from (values
(1,'KSA','SAR (Saudi riyal)','Any channel (no channel tag)','https://survey.foodics.com/?country=ksa'),
(1,'KSA','SAR (Saudi riyal)','whatsapp','https://survey.foodics.com/?country=ksa&src=whatsapp'),
(1,'KSA','SAR (Saudi riyal)','email','https://survey.foodics.com/?country=ksa&src=email'),
(1,'KSA','SAR (Saudi riyal)','sms','https://survey.foodics.com/?country=ksa&src=sms'),
(1,'KSA','SAR (Saudi riyal)','social','https://survey.foodics.com/?country=ksa&src=social'),
(2,'Oman','OMR (Omani rial)','Any channel (no channel tag)','https://survey.foodics.com/?country=oman'),
(2,'Oman','OMR (Omani rial)','whatsapp','https://survey.foodics.com/?country=oman&src=whatsapp'),
(2,'Oman','OMR (Omani rial)','email','https://survey.foodics.com/?country=oman&src=email'),
(2,'Oman','OMR (Omani rial)','sms','https://survey.foodics.com/?country=oman&src=sms'),
(2,'Oman','OMR (Omani rial)','social','https://survey.foodics.com/?country=oman&src=social'),
(3,'Jordan','JOD (Jordanian dinar)','Any channel (no channel tag)','https://survey.foodics.com/?country=jordan'),
(3,'Jordan','JOD (Jordanian dinar)','whatsapp','https://survey.foodics.com/?country=jordan&src=whatsapp'),
(3,'Jordan','JOD (Jordanian dinar)','email','https://survey.foodics.com/?country=jordan&src=email'),
(3,'Jordan','JOD (Jordanian dinar)','sms','https://survey.foodics.com/?country=jordan&src=sms'),
(3,'Jordan','JOD (Jordanian dinar)','social','https://survey.foodics.com/?country=jordan&src=social'),
(4,'UAE','AED (UAE dirham)','Any channel (no channel tag)','https://survey.foodics.com/?country=uae'),
(4,'UAE','AED (UAE dirham)','whatsapp','https://survey.foodics.com/?country=uae&src=whatsapp'),
(4,'UAE','AED (UAE dirham)','email','https://survey.foodics.com/?country=uae&src=email'),
(4,'UAE','AED (UAE dirham)','sms','https://survey.foodics.com/?country=uae&src=sms'),
(4,'UAE','AED (UAE dirham)','social','https://survey.foodics.com/?country=uae&src=social'),
(5,'Bahrain','BHD (Bahraini dinar)','Any channel (no channel tag)','https://survey.foodics.com/?country=bahrain'),
(5,'Bahrain','BHD (Bahraini dinar)','whatsapp','https://survey.foodics.com/?country=bahrain&src=whatsapp'),
(5,'Bahrain','BHD (Bahraini dinar)','email','https://survey.foodics.com/?country=bahrain&src=email'),
(5,'Bahrain','BHD (Bahraini dinar)','sms','https://survey.foodics.com/?country=bahrain&src=sms'),
(5,'Bahrain','BHD (Bahraini dinar)','social','https://survey.foodics.com/?country=bahrain&src=social'),
(6,'Kuwait','KWD (Kuwaiti dinar)','Any channel (no channel tag)','https://survey.foodics.com/?country=kuwait'),
(6,'Kuwait','KWD (Kuwaiti dinar)','whatsapp','https://survey.foodics.com/?country=kuwait&src=whatsapp'),
(6,'Kuwait','KWD (Kuwaiti dinar)','email','https://survey.foodics.com/?country=kuwait&src=email'),
(6,'Kuwait','KWD (Kuwaiti dinar)','sms','https://survey.foodics.com/?country=kuwait&src=sms'),
(6,'Kuwait','KWD (Kuwaiti dinar)','social','https://survey.foodics.com/?country=kuwait&src=social'),
(7,'Egypt','EGP (Egyptian pound)','Any channel (no channel tag)','https://survey.foodics.com/?country=egypt'),
(7,'Egypt','EGP (Egyptian pound)','whatsapp','https://survey.foodics.com/?country=egypt&src=whatsapp'),
(7,'Egypt','EGP (Egyptian pound)','email','https://survey.foodics.com/?country=egypt&src=email'),
(7,'Egypt','EGP (Egyptian pound)','sms','https://survey.foodics.com/?country=egypt&src=sms'),
(7,'Egypt','EGP (Egyptian pound)','social','https://survey.foodics.com/?country=egypt&src=social')
) as c(ord, "Country", "Currency merchants answer in", "Channel", "Link")
order by c.ord, (case when c."Channel" like 'Any%' then 0 else 1 end), c."Channel";
revoke all on public.survey_links from public;
grant select on public.survey_links to survey_reader;
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
  public.ans(answers, 'priceViewWhy') as price_view_why,
  public.cell(answers, 'priceAcceptable', case when answers->>'priceAcceptable' = '__skip' then 'Not sure' else answers->>'priceAcceptable' end) as price_acceptable,
  public.ans(answers, 'priceAcceptableWhy') as price_acceptable_why,
  case when answers ? 'country' then public.ans(answers, 'country') else 'Not recorded (older survey version)' end as country,
  case coalesce(nullif(answers->>'currency', ''), case when answers->>'saasSpend' is not null or answers->>'priceAcceptable' is not null then 'SAR' end) when 'LOCAL' then 'Other (own currency)' else coalesce(coalesce(nullif(answers->>'currency', ''), case when answers->>'saasSpend' is not null or answers->>'priceAcceptable' is not null then 'SAR' end), 'Not recorded') end as currency
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
  country as "Country",
  currency as "Currency",
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
  saas_spend as "Software (SaaS) spend per year (local currency)",
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
  link_tag as "Link tag",
  country as "Country",
  currency as "Currency",
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
  saas_spend as "Software (SaaS) spend per year (local currency)",
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
  price_acceptable as "Acceptable yearly POS price (local currency)",
  price_acceptable_why as "Why this price",
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
  link_tag as "Link tag",
  country as "Country",
  currency as "Currency",
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
  saas_spend as "Software (SaaS) spend per year (local currency)",
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
  price_acceptable as "Acceptable yearly POS price (local currency)",
  price_acceptable_why as "Why this price",
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
  link_tag as "Link tag",
  country as "Country",
  currency as "Currency",
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
  saas_spend as "Software (SaaS) spend per year (local currency)",
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