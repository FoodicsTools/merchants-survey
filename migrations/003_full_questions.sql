-- 003: Excel-safe wording, full question text, clearer blank-cell label.
-- 1) Plain-ASCII answer labels, so a CSV opened by double-click in Excel never shows garbled characters.
update public.option_labels set label = 'Cafe'        where question = 'entityType'  and code = 'cafe';
update public.option_labels set label = '10 to 25%'   where question = 'onlineShare' and code = '10-25';
update public.option_labels set label = '26 to 50%'   where question = 'onlineShare' and code = '26-50';

-- 2) Blank-cell label: shown instead of 'Not asked'
create or replace function public.cell(a jsonb, q text, v text) returns text
language sql immutable as $$
  select case
    when nullif(trim(v), '') is not null then v
    when a->'_shown' is null then null
    when (a->'_shown') ? q then 'Skipped'
    else 'Not applicable (question not shown to this merchant)'
  end
$$;

-- 3) Every question, word for word, as merchants saw it (English). Column headers in results are limited
--    to 63 characters by Postgres, so the full wording lives here: join on the header or the number.
create table public.survey_question_text (
  question  text primary key,
  num       int  not null,
  header    text not null,
  customers text,
  stopped   text,
  never     text
);
insert into public.survey_question_text (question, num, header, customers, stopped, never) values
('isCustomer',1,'Customer status','Are you a Foodics customer?','Are you a Foodics customer?','Are you a Foodics customer?'),
('position',2,'Position','What''s your position?','What''s your position?','What''s your position?'),
('entityType',3,'Business type','What type of business do you run?','What type of business do you run?','What type of business do you run?'),
('branches',4,'Number of branches','How many branches do you have?','How many branches do you have?','How many branches do you have?'),
('channels',5,'Sales channels','Which channels do you sell through today?','Which channels do you sell through today?','Which channels do you sell through today?'),
('salesTrend',6,'Sales vs last 12 months','How have your sales changed over the last 12 months?','How have your sales changed over the last 12 months?','How have your sales changed over the last 12 months?'),
('plan',7,'Plan for next 12 months','What''s your plan for the next 12 months?','What''s your plan for the next 12 months?','What''s your plan for the next 12 months?'),
('margins',8,'What squeezes margins','What squeezes your margins the most?','What squeezes your margins the most?','What squeezes your margins the most?'),
('onlineShare',9,'Online and delivery share of sales','About what share of your sales comes from delivery apps and online ordering?','About what share of your sales comes from delivery apps and online ordering?','About what share of your sales comes from delivery apps and online ordering?'),
('salesDrivers',10,'What drove sales','What drove your sales the most this year?','What drove your sales the most this year?','What drove your sales the most this year?'),
('techSpend',11,'Technology spend next 12 months','Over the next 12 months, your spending on technology will...','Over the next 12 months, your spending on technology will...','Over the next 12 months, your spending on technology will...'),
('aiUse',12,'Where AI is used','Where do you use AI in your business today?','Where do you use AI in your business today?','Where do you use AI in your business today?'),
('trend',13,'Biggest change coming','In one sentence, what''s the biggest change you see coming in F&B?','In one sentence, what''s the biggest change you see coming in F&B?','In one sentence, what''s the biggest change you see coming in F&B?'),
('nps',14,'Recommend Foodics (0-10)','How likely are you to recommend Foodics to another restaurant or cafe owner?',null,null),
('leaveReason',15,'Main reason for leaving Foodics',null,'What was the main reason you stopped using Foodics?',null),
('satisfaction',16,'Satisfaction with Foodics (1-10)','Overall, how satisfied are you with Foodics?','Overall, how satisfied were you with Foodics?',null),
('products',17,'Foodics products used','Which Foodics products do you subscribe to?','Which Foodics products did you use?',null),
('unhappy',18,'Products not fully satisfied with','Which products are you not fully satisfied with?','Which products were you not fully satisfied with?',null),
('priceValue',19,'Foodics prices justified (1-5)','Do you think Foodics'' prices are justified compared to the quality of what you get?','Do you think Foodics'' prices were justified compared to the quality of what you got?',null),
('pricingPref',20,'Preferred pricing',null,'What do you prefer in terms of pricing?','What do you prefer in terms of pricing?'),
('wanted',21,'Product or service wanted','Which product or service would you like Foodics to add?','Which product or service would you have liked Foodics to offer?','Which product or service do you wish existed for your business?'),
('finInterest',22,'Interest in banking-type services (1-5)','How interested would you be in banking-type services from Foodics, such as instant deposits and business financing?','How interested would you be in banking-type services from your technology provider, such as instant deposits and business financing?','How interested would you be in banking-type services from your technology provider, such as instant deposits and business financing?'),
('otherProvider',23,'Other provider / current system','Do you also use another provider?','Which system do you use today?','Which system do you use today?'),
('comeBack',24,'What would bring them back',null,'What is the most important factor that might bring you back to Foodics?',null),
('foodicsPayWhy',25,'Why not using Foodics Pay','What''s holding you back from Foodics Pay?',null,null),
('workshop',26,'Interest in workshops (1-10)','How likely are you to join workshops with the Foodics team to test upcoming products and share ideas?','How likely are you to join workshops to test upcoming restaurant-tech products and share your ideas?','How likely are you to join workshops to test upcoming restaurant-tech products and share your ideas?'),
('techSat',27,'Technology satisfaction (1-5)','How satisfied are you with your current technology, including Foodics?','How satisfied are you with your current technology?','How satisfied are you with your current technology?'),
('challenges',28,'Biggest challenges','What are your most pressing challenges in running your business?','What are your most pressing challenges in running your business?','What are your most pressing challenges in running your business?'),
('manualWhere',29,'Where manual work hurts','Where does the manual work hurt most?','Where does the manual work hurt most?','Where does the manual work hurt most?'),
('unmet',30,'Unmet needs','What do you need today that neither Foodics nor anyone else has solved for you?','What do you need today that no provider has solved for you?','What do you need today that no provider has solved for you?'),
('guestTool',31,'How guests are brought back','What do you use today to keep guests coming back?','What do you use today to keep guests coming back?','What do you use today to keep guests coming back?'),
('guestSat',32,'Guest engagement satisfaction (1-5)','How satisfied are you with how you engage your guests?','How satisfied are you with how you engage your guests?','How satisfied are you with how you engage your guests?');

create view public.survey_questions with (security_invoker = true) as
  select num as "No.", header as "Column header in results",
         customers as "Question asked to current customers",
         stopped   as "Question asked to merchants who stopped using Foodics",
         never     as "Question asked to merchants who never used Foodics"
  from public.survey_question_text order by num;

revoke all on public.survey_question_text, public.survey_questions from public;
grant select on public.survey_question_text, public.survey_questions to survey_reader;