-- 013: survey_links keeps only the seven country links (the channel links were removed).
-- A channel tag can still be added by hand: ...?country=oman&src=whatsapp
drop view if exists public.survey_links;
create view public.survey_links with (security_invoker = true) as
select c."Country", c."Currency merchants answer in", c."Link"
from (values
(1,'KSA','SAR (Saudi riyal)','https://survey.foodics.com/?country=ksa'),
(2,'Oman','OMR (Omani rial)','https://survey.foodics.com/?country=oman'),
(3,'Jordan','JOD (Jordanian dinar)','https://survey.foodics.com/?country=jordan'),
(4,'UAE','AED (UAE dirham)','https://survey.foodics.com/?country=uae'),
(5,'Bahrain','BHD (Bahraini dinar)','https://survey.foodics.com/?country=bahrain'),
(6,'Kuwait','KWD (Kuwaiti dinar)','https://survey.foodics.com/?country=kuwait'),
(7,'Egypt','EGP (Egyptian pound)','https://survey.foodics.com/?country=egypt')
) as c(ord, "Country", "Currency merchants answer in", "Link")
order by c.ord;
revoke all on public.survey_links from public;
grant select on public.survey_links to survey_reader;