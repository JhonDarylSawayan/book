-- Run this once in Supabase: Dashboard > SQL Editor > New query > paste > Run.

create extension if not exists "pgcrypto";

create table if not exists public.books (
  id               uuid primary key default gen_random_uuid(),
  title            text not null,
  author           text not null,
  isbn             text,
  genre            text default 'General',
  published_year   integer,
  description      text default '',
  cover_url        text default '',
  total_copies     integer not null default 1,
  available_copies integer not null default 1,
  created_at       timestamptz not null default now()
);

create table if not exists public.borrowers (
  id          uuid primary key default gen_random_uuid(),
  member_id   text unique,
  full_name   text not null,
  email       text,
  phone       text,
  department  text default 'General Patron',
  status      text not null default 'active',
  created_at  timestamptz not null default now()
);

create table if not exists public.borrow_records (
  id              uuid primary key default gen_random_uuid(),
  book_id         uuid references public.books(id) on delete cascade,
  borrower_id     uuid references public.borrowers(id) on delete set null,
  borrower_name   text not null,
  borrower_email  text,
  borrower_phone  text,
  borrowed_date   timestamptz not null default now(),
  due_date        timestamptz,
  returned_date   timestamptz,
  status          text not null default 'borrowed'
                  check (status in ('borrowed','returned','overdue')),
  notes           text,
  created_at      timestamptz not null default now()
);

alter table public.books          enable row level security;
alter table public.borrowers      enable row level security;
alter table public.borrow_records enable row level security;

-- The app has no login, so these policies let anyone with your site's
-- anon key read and write. Fine for learning; add Supabase Auth before
-- using real patron data.
create policy "open books"          on public.books          for all using (true) with check (true);
create policy "open borrowers"      on public.borrowers      for all using (true) with check (true);
create policy "open borrow_records" on public.borrow_records for all using (true) with check (true);
