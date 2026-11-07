-- MCL Help Desk: Supabase setup. Paste into Supabase > SQL Editor and press Run.
-- Each Firestore collection becomes a table of (id, data jsonb), so the app's documents keep their shape.

create table if not exists public.users   (id text primary key, data jsonb not null default '{}'::jsonb);
create table if not exists public.tickets (id text primary key, data jsonb not null default '{}'::jsonb);
create table if not exists public.notifs  (id text primary key, data jsonb not null default '{}'::jsonb);
create table if not exists public.files   (id text primary key, data jsonb not null default '{}'::jsonb);

-- Merge fields into a document (same as Firestore's update()). Runs with the caller's rights, so RLS still applies.
create or replace function public.doc_merge(tbl text, doc_id text, patch jsonb)
returns void language plpgsql security invoker set search_path = public as $$
begin
  if tbl not in ('users','tickets','notifs','files') then raise exception 'unknown table %', tbl; end if;
  execute format('update public.%I set data = data || $1 where id = $2', tbl) using patch, doc_id;
  if not found then raise exception 'No document to update: %/%', tbl, doc_id using errcode = 'P0002'; end if;
end $$;
grant execute on function public.doc_merge(text,text,jsonb) to anon, authenticated;

-- Row Level Security. These policies match how the app worked on Firebase: the app itself decides
-- who can see and change what. Older username accounts sign in without Supabase Auth, so the anon
-- role needs access too. Tighten these once every account has moved to email sign-in.
do $$ declare t text; begin
  foreach t in array array['users','tickets','notifs','files'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "app access" on public.%I', t);
    execute format('create policy "app access" on public.%I for all to anon, authenticated using (true) with check (true)', t);
  end loop;
end $$;

-- Realtime: live updates for the three lists the app watches (photos are loaded on demand).
alter table public.users   replica identity full;
alter table public.tickets replica identity full;
alter table public.notifs  replica identity full;
do $$ declare t text; begin
  foreach t in array array['users','tickets','notifs'] loop
    if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename=t) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;
