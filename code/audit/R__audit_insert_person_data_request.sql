-- SPDX-License-Identifier: EUPL-1.2

create or replace procedure audit.insert_person_data_request(
    inout pi_data audit.person_data_requests)
language 'plpgsql'
    security definer 
as $body$
begin
  insert into audit.person_data_requests(
              req_person_id,
              req_person_code,
              person_code,
              action_code,
              ip_address,
              client_code,
              req_data)
      values (pi_data.req_person_id,
              pi_data.req_person_code,
              pi_data.person_code,
              pi_data.action_code,
              pi_data.ip_address,
              pi_data.client_code,
              pi_data.req_data);
exception
    when others then
        if sqlstate = '23514' AND sqlerrm LIKE 'no partition of relation "%" found for row' then
            call audit.create_audit_partition(current_date);
        else
            raise;
        end if;

        -- Retry after partition created.
        insert into audit.person_data_requests(
                    req_person_id,
                    req_person_code,
                    person_code,
                    action_code,
                    ip_address,
                    client_code,
                    req_data)
            values (pi_data.req_person_id,
                    pi_data.req_person_code,
                    pi_data.person_code,
                    pi_data.action_code,
                    pi_data.ip_address,
                    pi_data.client_code,
                    pi_data.req_data);
end
$body$;

alter procedure audit.insert_person_data_request(audit.person_data_requests) owner to edim;

grant execute on procedure audit.insert_person_data_request(audit.person_data_requests) to edim;

revoke all on procedure audit.insert_person_data_request(audit.person_data_requests) from public;

comment on procedure audit.insert_person_data_request(audit.person_data_requests)
    is 'Saglabā personas datu pieprasījumu';
