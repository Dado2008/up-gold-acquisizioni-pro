begin;
alter table public.crm_activities add column author_id uuid references auth.users(id) default auth.uid();
create or replace function public.crm_log_contact_change() returns trigger language plpgsql security invoker set search_path='' as $$ begin new.updated_at=now(); return new; end $$;
create function public.crm_record_contact_change() returns trigger language plpgsql security definer set search_path='' as $$ begin insert into public.crm_activities(contact_id,kind,notes,author_id) values(new.id,'Aggiornamento scheda',old.state || ' → ' || new.state || '; richiamo: ' || coalesce(new.next_action::text,'non fissato'),auth.uid()); return new; end $$;
create trigger crm_contact_audit after update on public.crm_contacts for each row execute function public.crm_record_contact_change();
revoke all on function public.crm_record_contact_change() from public;
revoke update, delete on public.crm_activities from authenticated;
revoke delete on public.crm_contacts from authenticated;
commit;
