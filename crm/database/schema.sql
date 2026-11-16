-- UP GOLD CRM PRO: private single-user database (Supabase/PostgreSQL).
-- Run as administrator only; create the owner account separately and replace the UUID.
create schema if not exists private;
create table if not exists private.crm_owner (id uuid primary key references auth.users(id));
revoke all on schema private from public;
revoke all on private.crm_owner from public, anon, authenticated;
create or replace function public.crm_is_owner() returns boolean language sql stable security definer set search_path = '' as $$ select exists(select 1 from private.crm_owner where id=auth.uid()) $$;
revoke all on function public.crm_is_owner() from public;
grant execute on function public.crm_is_owner() to authenticated;
create table public.crm_contacts (id uuid primary key default gen_random_uuid(), name text not null, phone text, email text, city text, notes text, state text not null default 'Nuovo' check(state in ('Nuovo','Da contattare','Contattato','In attesa','Appuntamento','Previsionale inviato','Firmato','Non interessato','Non risponde')), next_action date, updated_at timestamptz not null default now(), created_at timestamptz not null default now());
create table public.crm_activities (id uuid primary key default gen_random_uuid(), contact_id uuid not null references public.crm_contacts(id) on delete cascade, kind text not null, notes text, created_at timestamptz not null default now());
create table public.crm_properties (id uuid primary key default gen_random_uuid(), contact_id uuid not null references public.crm_contacts(id) on delete cascade, address text, area_m2 numeric check(area_m2>0), beds integer check(beds>=0), notes text);
create table public.crm_tasks (id uuid primary key default gen_random_uuid(), contact_id uuid references public.crm_contacts(id) on delete cascade, title text not null, due_at timestamptz not null, done boolean not null default false);
create table public.crm_forecasts (id uuid primary key default gen_random_uuid(), property_id uuid references public.crm_properties(id) on delete cascade, nightly_rate numeric check(nightly_rate>=0), occupancy numeric check(occupancy between 0 and 100), ota_pct numeric check(ota_pct between 0 and 100), management_pct numeric check(management_pct between 0 and 100), annual_costs numeric check(annual_costs>=0), created_at timestamptz default now());
create table public.crm_contracts (id uuid primary key default gen_random_uuid(), contact_id uuid references public.crm_contacts(id) on delete cascade, title text not null, starts_on date, expires_on date, status text, private_object_path text);
create table public.crm_payments (id uuid primary key default gen_random_uuid(), contact_id uuid references public.crm_contacts(id) on delete set null, description text, amount numeric not null, due_on date, paid_on date);
do $$ declare t text; begin foreach t in array array['crm_contacts','crm_activities','crm_properties','crm_tasks','crm_forecasts','crm_contracts','crm_payments'] loop execute format('alter table public.%I enable row level security',t); execute format('revoke all on public.%I from anon, public',t); execute format('grant select, insert, update, delete on public.%I to authenticated',t); execute format('create policy owner_only on public.%I for all to authenticated using (public.crm_is_owner()) with check (public.crm_is_owner())',t); end loop; end $$;
create or replace function public.crm_log_contact_change() returns trigger language plpgsql security invoker set search_path='' as $$ begin new.updated_at=now(); insert into public.crm_activities(contact_id,kind,notes) values(old.id,'Aggiornamento scheda',old.state || ' → ' || new.state); return new; end $$;
create trigger crm_contact_history before update on public.crm_contacts for each row execute function public.crm_log_contact_change();
create index crm_contacts_next_action_idx on public.crm_contacts(next_action);
create index crm_tasks_due_idx on public.crm_tasks(due_at) where not done;
-- Provision owner separately: insert into private.crm_owner(id) values ('OWNER_AUTH_UUID');
-- Disable public signup; private document storage and policies must be configured separately.
