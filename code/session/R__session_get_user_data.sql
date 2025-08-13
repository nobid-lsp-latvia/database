-- SPDX-License-Identifier: EUPL-1.2

create or replace function session.get_user_data()
    returns record
    language 'plpgsql'
    cost 100
    volatile security definer parallel unsafe
as $body$
declare
  v_user record;
begin
  select *
    into v_user
    from session_state;

  return v_user;
end;
$body$;

alter function session.get_user_data() owner to edim;

grant execute on function session.get_user_data() to edim;

revoke all on function session.get_user_data() from public;

comment on function session.get_user_data()
    is 'Uzstādītās sesijas lietotāja detaļas';