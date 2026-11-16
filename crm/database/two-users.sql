-- Apply after schema.sql, before production use. Provision two distinct auth users.
begin;
create table private.crm_collaborator(id uuid primary key references auth.users(id));
revoke all on private.crm_collaborator from public, anon, authenticated;
create function public.crm_role() returns text language sql stable security definer set search_path='' as $$ select case when exists(select 1 from private.crm_owner where id=auth.uid()) then 'admin' when exists(select 1 from private.crm_collaborator where id=auth.uid()) then 'collaborator' else null end $$;
revoke all on function public.crm_role() from public;
grant execute on function public.crm_role() to authenticated;
alter table public.crm_contacts add column assigned_to uuid references auth.users(id) default auth.uid();
create policy collaborator_contacts on public.crm_contacts for all to authenticated using(public.crm_role()='collaborator' and assigned_to=auth.uid()) with check(public.crm_role()='collaborator' and assigned_to=auth.uid());
create policy collaborator_activities on public.crm_activities for select to authenticated using(public.crm_role()='collaborator' and exists(select 1 from public.crm_contacts c where c.id=contact_id and c.assigned_to=auth.uid()));
create policy collaborator_activity_insert on public.crm_activities for insert to authenticated with check(public.crm_role()='collaborator' and exists(select 1 from public.crm_contacts c where c.id=contact_id and c.assigned_to=auth.uid()));
-- Other modules remain administrator-only until explicitly authorized.
-- Provision collaborator with a distinct UUID in private.crm_collaborator.
commit;
