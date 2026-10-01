// Survey configuration.
// The publishable key is designed to be public; the database rules in supabase/schema.sql
// only allow it to INSERT answers, never to read them.
window.SURVEY_CONFIG = {
  SUPABASE_URL: "https://ycmencjhmnosycmdptbd.supabase.co",
  SUPABASE_ANON_KEY: "sb_publishable_wU5NfrXtMDXtNlmvdcjsyw_S_w-y1di",
  TABLE: "responses"
};
