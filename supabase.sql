-- =====================================================================
--  Lab Perf — installation de la base de données Supabase
--  À coller en entier dans Supabase > SQL Editor > New query, puis « Run ».
--  Peut être relancé sans risque (il ne supprime aucune donnée).
-- =====================================================================

-- 1. Comptes : un profil par utilisateur, avec un rôle
create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  name text,
  email text,
  role text not null default 'pending' check (role in ('pending', 'viewer', 'coach', 'admin')),
  created_at timestamptz not null default now()
);

-- Le premier compte créé devient administrateur, les suivants sont « en attente »
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, name, email, role)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data->>'name', ''), split_part(new.email, '@', 1)),
    new.email,
    case when exists (select 1 from public.profiles where role = 'admin') then 'pending' else 'admin' end
  )
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.my_role() returns text
language sql stable security definer set search_path = public as $$
  select coalesce((select role from public.profiles where id = auth.uid()), 'pending')
$$;

-- 2. Données de l'application (joueurs, séances, annotations, mesures…)
create table if not exists public.docs (
  path text primary key,
  col text not null,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  updated_by uuid default auth.uid()
);
create index if not exists docs_col_idx on public.docs (col);
create index if not exists docs_session_idx on public.docs ((data->>'sessionId')) where col = 'annotations';

create or replace function public.touch_updated_at() returns trigger language plpgsql as $$
begin new.updated_at := now(); return new; end $$;
drop trigger if exists docs_touch on public.docs;
create trigger docs_touch before update on public.docs for each row execute function public.touch_updated_at();

-- 3. Sécurité : seules les personnes validées voient les données,
--    seuls les coachs et administrateurs les modifient.
alter table public.docs enable row level security;
alter table public.profiles enable row level security;

drop policy if exists docs_read on public.docs;
drop policy if exists docs_insert on public.docs;
drop policy if exists docs_update on public.docs;
drop policy if exists docs_delete on public.docs;
create policy docs_read   on public.docs for select to authenticated using (public.my_role() in ('viewer', 'coach', 'admin'));
create policy docs_insert on public.docs for insert to authenticated with check (public.my_role() in ('coach', 'admin'));
create policy docs_update on public.docs for update to authenticated using (public.my_role() in ('coach', 'admin')) with check (public.my_role() in ('coach', 'admin'));
create policy docs_delete on public.docs for delete to authenticated using (public.my_role() in ('coach', 'admin'));

drop policy if exists profiles_read on public.profiles;
drop policy if exists profiles_admin on public.profiles;
create policy profiles_read  on public.profiles for select to authenticated using (id = auth.uid() or public.my_role() in ('viewer', 'coach', 'admin'));
create policy profiles_admin on public.profiles for update to authenticated using (public.my_role() = 'admin') with check (public.my_role() = 'admin');

-- 4. Mises à jour en direct entre coachs
do $$ begin
  begin alter publication supabase_realtime add table public.docs; exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.profiles; exception when duplicate_object then null; end;
end $$;

-- 5. Types d'exercices proposés au départ (modifiables dans l'application)
insert into public.docs (path, col, data) values
  ('exerciseTypes/t01echauf', 'exerciseTypes', '{"name":"Échauffement","color":"#d9a21b","order":0,"deleted":false}'),
  ('exerciseTypes/t02activ',  'exerciseTypes', '{"name":"Activation / Mobilité","color":"#9d5b2f","order":1,"deleted":false}'),
  ('exerciseTypes/t03sprint', 'exerciseTypes', '{"name":"Sprint / Vitesse","color":"#c3301b","order":2,"deleted":false}'),
  ('exerciseTypes/t04endu',   'exerciseTypes', '{"name":"Endurance / Intermittent","color":"#e0702c","order":3,"deleted":false}'),
  ('exerciseTypes/t05force',  'exerciseTypes', '{"name":"Musculation / Force","color":"#5b6b2e","order":4,"deleted":false}'),
  ('exerciseTypes/t06tech',   'exerciseTypes', '{"name":"Technique","color":"#1f8fb3","order":5,"deleted":false}'),
  ('exerciseTypes/t07jr',     'exerciseTypes', '{"name":"Jeu réduit","color":"#2458c8","order":6,"deleted":false}'),
  ('exerciseTypes/t08oppo',   'exerciseTypes', '{"name":"Opposition / Jeu","color":"#3d4fb0","order":7,"deleted":false}'),
  ('exerciseTypes/t09mt1',    'exerciseTypes', '{"name":"Match — 1re mi-temps","color":"#7a4fd0","order":8,"deleted":false}'),
  ('exerciseTypes/t10mt2',    'exerciseTypes', '{"name":"Match — 2e mi-temps","color":"#b0437f","order":9,"deleted":false}'),
  ('exerciseTypes/t11recup',  'exerciseTypes', '{"name":"Récupération active","color":"#0d8a61","order":10,"deleted":false}'),
  ('exerciseTypes/t12repos',  'exerciseTypes', '{"name":"Repos / Pause","color":"#6a6f78","order":11,"deleted":false}')
on conflict (path) do nothing;
