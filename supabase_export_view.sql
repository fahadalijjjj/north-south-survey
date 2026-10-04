-- Run once in Supabase: SQL Editor > New query > paste > Run.
-- Creates a read-only view with the ACTUAL answer text (not A/B/C), one column per question,
-- plus north/south scores. Export it: Table Editor > pick "responses_export" > Export > CSV.
-- The raw table `responses` is unchanged and keeps the letter codes.

drop view if exists public.responses_export;

create view public.responses_export as
select
  r.created_at,
  r.collected_by,
  r.place as hometown,
  case r.answers->>'q1'
      when 'A' then 'Noodles, dumplings, steamed buns, or flatbread'
      when 'B' then 'Rice'
      when 'C' then 'Both about equally'
    end as q1_staple,
  case r.answers->>'q2'
      when 'A' then 'Salty and hearty, with vinegar and garlic'
      when 'B' then 'Light and slightly sweet'
      when 'C' then 'Very spicy'
      when 'D' then 'No clear pattern'
    end as q2_flavor,
  case r.answers->>'q3'
      when 'A' then 'Standard Mandarin or a Mandarin dialect'
      when 'B' then 'Cantonese, Wu (e.g. Shanghainese), Min/Hokkien, Hakka, or another non-Mandarin language'
      when 'C' then 'Other'
    end as q3_home_language,
  case r.answers->>'q4'
      when 'A' then 'Yes, easily'
      when 'B' then 'Only partly'
      when 'C' then 'Hardly or not at all'
    end as q4_dialect_gap,
  case r.answers->>'q5'
      when 'A' then 'Central heating or radiators'
      when 'B' then 'No heating, or only electric heaters, air conditioners, or blankets'
      when 'C' then 'Other'
    end as q5_winter_heating,
  case r.answers->>'q6'
      when 'A' then 'Many rounds of toasts, often with baijiu or beer'
      when 'B' then 'Tea, light drinking, and a relaxed pace'
      when 'C' then 'Little or no alcohol'
    end as q6_dinners,
  case r.answers->>'q7'
      when 'A' then 'Rarely'
      when 'B' then 'Sometimes'
      when 'C' then 'Very often, as a regular ritual'
    end as q7_tea,
  case r.answers->>'q8'
      when 'A' then 'Yes, it is a major part of village life'
      when 'B' then 'Somewhat'
      when 'C' then 'No'
    end as q8_ancestral_hall,
  case r.answers->>'q9'
      when 'A' then 'Wide plains, dry land, or plateau'
      when 'B' then 'Rivers, canals, lakes, and hills'
      when 'C' then 'Mountains or coast'
      when 'D' then 'Other'
    end as q9_landscape,
  case r.answers->>'q10'
      when 'A' then 'A northerner'
      when 'B' then 'A southerner'
      when 'C' then 'Neither or mixed'
    end as q10_self_id,
  ((r.answers->>'q1' = 'A')::int + (r.answers->>'q2' = 'A')::int + (r.answers->>'q3' = 'A')::int + (r.answers->>'q4' = 'A')::int + (r.answers->>'q5' = 'A')::int + (r.answers->>'q6' = 'A')::int + (r.answers->>'q7' = 'A')::int + (r.answers->>'q8' = 'C')::int + (r.answers->>'q9' = 'A')::int + (r.answers->>'q10' = 'A')::int) as north_score,
  ((r.answers->>'q1' = 'B')::int + (r.answers->>'q2' = 'B')::int + (r.answers->>'q3' = 'B')::int + (r.answers->>'q4' = 'C')::int + (r.answers->>'q5' = 'B')::int + (r.answers->>'q6' = 'B')::int + (r.answers->>'q7' = 'C')::int + (r.answers->>'q8' = 'A')::int + (r.answers->>'q9' = 'B')::int + (r.answers->>'q10' = 'B')::int) as south_score,
  ((r.answers->>'q1' = 'A')::int + (r.answers->>'q2' = 'A')::int + (r.answers->>'q3' = 'A')::int + (r.answers->>'q4' = 'A')::int + (r.answers->>'q5' = 'A')::int + (r.answers->>'q6' = 'A')::int + (r.answers->>'q7' = 'A')::int + (r.answers->>'q8' = 'C')::int + (r.answers->>'q9' = 'A')::int + (r.answers->>'q10' = 'A')::int) - ((r.answers->>'q1' = 'B')::int + (r.answers->>'q2' = 'B')::int + (r.answers->>'q3' = 'B')::int + (r.answers->>'q4' = 'C')::int + (r.answers->>'q5' = 'B')::int + (r.answers->>'q6' = 'B')::int + (r.answers->>'q7' = 'C')::int + (r.answers->>'q8' = 'A')::int + (r.answers->>'q9' = 'B')::int + (r.answers->>'q10' = 'B')::int) as net_score,
  case
    when ((r.answers->>'q1' = 'A')::int + (r.answers->>'q2' = 'A')::int + (r.answers->>'q3' = 'A')::int + (r.answers->>'q4' = 'A')::int + (r.answers->>'q5' = 'A')::int + (r.answers->>'q6' = 'A')::int + (r.answers->>'q7' = 'A')::int + (r.answers->>'q8' = 'C')::int + (r.answers->>'q9' = 'A')::int + (r.answers->>'q10' = 'A')::int) - ((r.answers->>'q1' = 'B')::int + (r.answers->>'q2' = 'B')::int + (r.answers->>'q3' = 'B')::int + (r.answers->>'q4' = 'C')::int + (r.answers->>'q5' = 'B')::int + (r.answers->>'q6' = 'B')::int + (r.answers->>'q7' = 'C')::int + (r.answers->>'q8' = 'A')::int + (r.answers->>'q9' = 'B')::int + (r.answers->>'q10' = 'B')::int) >= 3 then 'leans north'
    when ((r.answers->>'q1' = 'A')::int + (r.answers->>'q2' = 'A')::int + (r.answers->>'q3' = 'A')::int + (r.answers->>'q4' = 'A')::int + (r.answers->>'q5' = 'A')::int + (r.answers->>'q6' = 'A')::int + (r.answers->>'q7' = 'A')::int + (r.answers->>'q8' = 'C')::int + (r.answers->>'q9' = 'A')::int + (r.answers->>'q10' = 'A')::int) - ((r.answers->>'q1' = 'B')::int + (r.answers->>'q2' = 'B')::int + (r.answers->>'q3' = 'B')::int + (r.answers->>'q4' = 'C')::int + (r.answers->>'q5' = 'B')::int + (r.answers->>'q6' = 'B')::int + (r.answers->>'q7' = 'C')::int + (r.answers->>'q8' = 'A')::int + (r.answers->>'q9' = 'B')::int + (r.answers->>'q10' = 'B')::int) <= -3 then 'leans south'
    else 'mixed'
  end as result
from public.responses r
order by r.created_at;

-- Keep it private: the public (anon) key must not be able to read it.
revoke all on public.responses_export from anon, authenticated;
