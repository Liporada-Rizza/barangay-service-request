-- =========================================
-- AI-Assisted Barangay Service Request System
-- Database Schema (Supabase / PostgreSQL)
-- =========================================

-- 1. PROFILES TABLE (name + role of each user)
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'resident' check (role in ('resident', 'admin')),
  created_at timestamptz not null default now()
);

-- 2. REQUESTS TABLE (service requests)
create table public.requests (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 5 and 100),
  description text not null check (char_length(description) between 10 and 1000),
  category text not null default 'Others',
  status text not null default 'Pending' check (status in ('Pending', 'In Progress', 'Resolved')),
  created_at timestamptz not null default now()
);

-- 3. AUTO-CREATE A PROFILE WHEN SOMEONE REGISTERS
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 4. HELPER: CHECK IF THE LOGGED-IN USER IS AN ADMIN
create function public.is_admin()
returns boolean
language sql
stable
security definer set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- 5. ROW LEVEL SECURITY
alter table public.profiles enable row level security;
alter table public.requests enable row level security;

create policy "View own profile or admin"
  on public.profiles for select to authenticated
  using (id = auth.uid() or public.is_admin());

create policy "View own requests or admin"
  on public.requests for select to authenticated
  using (user_id = auth.uid() or public.is_admin());

create policy "Submit own requests"
  on public.requests for insert to authenticated
  with check (user_id = auth.uid() and status = 'Pending');

create policy "Edit own pending requests"
  on public.requests for update to authenticated
  using (user_id = auth.uid() and status = 'Pending')
  with check (user_id = auth.uid() and status = 'Pending');

create policy "Admin updates any request"
  on public.requests for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Delete own pending requests"
  on public.requests for delete to authenticated
  using (user_id = auth.uid() and status = 'Pending');

create policy "Admin deletes any request"
  on public.requests for delete to authenticated
  using (public.is_admin());

-- 6. LINK REQUESTS TO PROFILES (for resident names in the admin panel)
alter table public.requests
  add constraint requests_user_profile_fkey
  foreign key (user_id) references public.profiles(id) on delete cascade;
