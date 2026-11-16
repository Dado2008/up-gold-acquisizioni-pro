begin;
create function public.crm_transfer_to_admin(contact uuid) returns void language plpgsql security definer set search_path='' as $$
declare target uuid;
begin
if public.crm_role() is distinct from 'collaborator' then raise exception 'Non autorizzato'; end if;
select id into strict target from private.crm_owner;
update public.crm_contacts set assigned_to=target where id=contact and assigned_to=auth.uid();
if not found then raise exception 'Nominativo non assegnato a te'; end if;
insert into public.crm_activities(contact_id,kind,notes,author_id) values(contact,'Riassegnazione','Trasferito all’amministratore',auth.uid());
end $$;
revoke all on function public.crm_transfer_to_admin(uuid) from public;
grant execute on function public.crm_transfer_to_admin(uuid) to authenticated;
commit;
