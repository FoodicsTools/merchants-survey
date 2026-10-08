-- 007: same Excel/Arabic fix for the plain group views (006 covered the "with questions" ones).
-- RULE for any future migration that recreates an export view: its first column header must start with U+FEFF
-- (chr(65279)), otherwise Excel shows Arabic text as garbage when the pgweb CSV is opened by double-click.
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