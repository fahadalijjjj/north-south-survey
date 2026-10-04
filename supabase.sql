-- Run this once in Supabase: SQL Editor > New query > paste > Run.

create table if not exists public.responses (
  id           uuid primary key,
  created_at   timestamptz not null default now(),
  collected_by text not null,
  place        text not null,
  answers      jsonb not null
);

alter table public.responses enable row level security;

-- The public (anon) key may only INSERT. Nobody can read, change or delete rows
-- through it; you read the data in the Supabase dashboard (Table Editor > Export CSV).
revoke all on public.responses from anon, authenticated;
grant insert on public.responses to anon;

drop policy if exists "anyone can submit" on public.responses;
create policy "anyone can submit" on public.responses
  for insert to anon with check (true);
