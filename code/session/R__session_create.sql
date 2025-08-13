-- SPDX-License-Identifier: EUPL-1.2

create or replace procedure session."create"(
  in pi_id varchar,
  in pi_user_id varchar,
  in pi_user_code varchar,
  in pi_given_name varchar,
  in pi_family_name varchar,
  in pi_role_code varchar,
  in pi_ip_addr inet)
language 'plpgsql'
security definer
as $body$
declare
begin
  create temp table if not exists session_state(
    id varchar(26),
    user_id varchar(50),
    user_code varchar(11),
    given_name varchar(100),
    family_name varchar(100),
    role_code varchar(20),
    ip_addr inet
  ) on commit drop;
  delete from session_state;
  insert into session_state (
              id,
              user_id,
              user_code,
              given_name,
              family_name,
              role_code,
              ip_addr)
      values (nullif(pi_id, ''),
              nullif(pi_user_id, ''),
              nullif(replace(pi_user_code, '-', ''), ''),
              nullif(pi_given_name, ''),
              nullif(pi_family_name, ''),
              nullif(pi_role_code, ''),
              pi_ip_addr);
end;
$body$;

alter procedure session."create"(varchar, varchar, varchar, varchar, varchar, varchar, inet) owner to edim;

grant execute on procedure session."create"(varchar, varchar, varchar, varchar, varchar, varchar, inet) to edim;

revoke all on procedure session."create"(varchar, varchar, varchar, varchar, varchar, varchar, inet) from public;

comment on procedure session."create"(varchar, varchar, varchar, varchar, varchar, varchar, inet)
    is 'Lietotāja sesijas stāvokļa uzstādīšana';