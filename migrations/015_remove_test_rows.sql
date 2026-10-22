-- 015: remove the test answers collected before launch (6 rows, all submitted on 8 October 2026).
-- The date filter means it cannot touch anything submitted from 9 October onward.
-- NOTE FOR REVIEW: this deletes merchant-answer rows permanently. Take a backup/snapshot before merging.
delete from public.responses where created_at < '2026-10-09';