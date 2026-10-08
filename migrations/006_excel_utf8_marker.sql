-- 006: Arabic text in CSV exports opened in Excel. pgweb writes UTF-8 without a marker, so Excel guessed the wrong encoding.
-- The first column header of each "with questions" view now starts with an invisible U+FEFF so Excel reads UTF-8.
-- (Same views as 004; recreated.)
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