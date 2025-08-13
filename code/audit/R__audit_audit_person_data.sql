-- SPDX-License-Identifier: EUPL-1.2

create or replace procedure audit.audit_person_data(
	in pi_data text,
	inout po_data text)
language 'plpgsql'
security definer
as $body$
declare
  v_data    jsonb;
  v_audit   audit.person_data_requests%rowtype;
  v_session record;
  v_request jsonb := '{}'::jsonb;
begin
  v_data := pi_data::jsonb;

  v_session := session.get_user_data();

  v_audit.req_person_id := nullif(v_session.user_id, '');
  v_audit.req_person_code := nullif(replace(v_session.user_code, '-', ''), '');
  if v_audit.req_person_code is null and v_audit.req_person_id != 'SYSTEM' then
    raise exception 'Nav norādīts datu pieprasītāja personas kods';
  end if;

  if v_audit.req_person_id is null then
    if v_audit.req_person_code is not null then
      v_audit.req_person_id := 'PNOLV-' || v_audit.req_person_code;
    end if;
  end if;

  v_audit.person_code := v_data -> 'person' ->> 'identifier';
  v_audit.action_code := v_data ->> 'action';
  v_audit.ip_address := (v_data ->> 'ipAddress')::inet;
  v_audit.client_code := v_data ->> 'clientId';

  -- Store resource, person and other request data as jsonb.
  v_audit.req_data := '{}'::jsonb;
  if v_data ->> 'person' is not null then
    v_audit.req_data := jsonb_set(v_audit.req_data, '{person}', v_data -> 'person');
  end if;
  if v_data ->> 'resources' is not null then
    v_audit.req_data := jsonb_set(v_audit.req_data, '{resources}', v_data -> 'resources');
  end if;

  if v_data -> 'endpoint' is not null then
    v_request := jsonb_set(v_request, '{endpoint}', v_data -> 'endpoint');
  end if;
  if v_data -> 'requestParameters' is not null then
    v_request := jsonb_set(v_request, '{parameters}', v_data -> 'requestParameters');
  end if;
  if v_data -> 'userAgent' is not null then
    v_request := jsonb_set(v_request, '{userAgent}', v_data -> 'userAgent');
  end if;

  v_audit.req_data := jsonb_set(v_audit.req_data, '{request}', v_request);

  call audit.insert_person_data_request(v_audit);
  po_data := result_success(null);
end;
$body$;

alter procedure audit.audit_person_data(text, text) owner to edim;

revoke all on procedure audit.audit_person_data(text, text) from public;

comment on procedure audit.audit_person_data(text, text)
    is 'Personas datu audita ieraksta izveidošana autorizētam lietotājam';