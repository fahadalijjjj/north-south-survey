-- Run once in Supabase: SQL Editor > New query > paste > Run.
-- Adds a column `answers_text` to public.responses holding the ACTUAL answer text
-- (e.g. {"q1":"Rice"}) next to the letter codes in `answers`. A trigger fills it on every
-- new insert, so the website needs no change; the last statement fills in existing rows.

alter table public.responses add column if not exists answers_text jsonb;

create or replace function public.responses_fill_answers_text()
returns trigger language plpgsql as $fn$
declare
  m constant jsonb := '{
 "q1": {
  "A": "Noodles, dumplings, steamed buns, or flatbread",
  "B": "Rice",
  "C": "Both about equally"
 },
 "q2": {
  "A": "Salty and hearty, with vinegar and garlic",
  "B": "Light and slightly sweet",
  "C": "Very spicy",
  "D": "No clear pattern"
 },
 "q3": {
  "A": "Standard Mandarin or a Mandarin dialect",
  "B": "Cantonese, Wu (e.g. Shanghainese), Min/Hokkien, Hakka, or another non-Mandarin language",
  "C": "Other"
 },
 "q4": {
  "A": "Yes, easily",
  "B": "Only partly",
  "C": "Hardly or not at all"
 },
 "q5": {
  "A": "Central heating or radiators",
  "B": "No heating, or only electric heaters, air conditioners, or blankets",
  "C": "Other"
 },
 "q6": {
  "A": "Many rounds of toasts, often with baijiu or beer",
  "B": "Tea, light drinking, and a relaxed pace",
  "C": "Little or no alcohol"
 },
 "q7": {
  "A": "Rarely",
  "B": "Sometimes",
  "C": "Very often, as a regular ritual"
 },
 "q8": {
  "A": "Yes, it is a major part of village life",
  "B": "Somewhat",
  "C": "No"
 },
 "q9": {
  "A": "Wide plains, dry land, or plateau",
  "B": "Rivers, canals, lakes, and hills",
  "C": "Mountains or coast",
  "D": "Other"
 },
 "q10": {
  "A": "A northerner",
  "B": "A southerner",
  "C": "Neither or mixed"
 }
}'::jsonb;
begin
  new.answers_text := (
    select coalesce(jsonb_object_agg(a.key, coalesce(m -> a.key ->> (a.value #>> '{}'), a.value #>> '{}')), '{}'::jsonb)
    from jsonb_each(new.answers) a
  );
  return new;
end $fn$;

drop trigger if exists responses_fill_answers_text on public.responses;
create trigger responses_fill_answers_text
  before insert or update of answers on public.responses
  for each row execute function public.responses_fill_answers_text();

-- Backfill existing rows (fires the trigger).
update public.responses set answers = answers where answers_text is null;

