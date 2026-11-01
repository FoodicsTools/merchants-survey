-- 021: remove Omar's test answer of 1 November 2026 (business name "cc", contact name "Omar Sbai") and the progress
-- records of that same test visit, before the survey goes out to merchants. Deleted by exact id / visit id only.
delete from public.responses where id = '2055d8ac-8abc-4830-9e12-157a795cb5c5';
delete from public.survey_progress where sid = '9f430870-43fb-4f96-b7bc-80df0c4c101b';