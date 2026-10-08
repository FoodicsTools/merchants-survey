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