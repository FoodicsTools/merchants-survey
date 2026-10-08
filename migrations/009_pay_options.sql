-- 009: Foodics Pay "what is holding you back" gets a new option (a loan with a bank or another entity).
-- The plain 'Installments' payment option was removed from the survey (monthly installments replaces it);
-- its label stays in option_labels so older answers still read correctly.
insert into public.option_labels (question, code, label) values
('foodicsPayWhy', 'loan', 'I have a loan with a bank or another entity')
on conflict (question, code) do update set label = excluded.label;