-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE PROCEDURE person.get_person(
  pi_data jsonb,
  INOUT po_data jsonb)
  LANGUAGE plpgsql
  SECURITY DEFINER
AS
$BODY$
DECLARE
  v_error_state    text;
  v_error_msg      text;
  v_error_desc     text;
  v_data           jsonb;
  v_person_code    varchar;
  v_person_guid    varchar;
  v_person_id      varchar;
  v_person_data    jsonb;
  v_requester_code varchar;
BEGIN
  v_data := pi_data;
  v_person_code := NULLIF(trim((v_data ->> 'code')), '');
  v_person_guid := NULLIF(trim((v_data ->> 'id')), '');
  v_requester_code := NULLIF(trim((v_data ->> 'requesterCode')), '');

  v_person_id := COALESCE(
          person.get_person_id_by_code(v_person_code),
          person.get_person_id_by_guid(v_person_guid));

  IF v_person_id IS NULL THEN
    po_data := json_build_object('code', 'err:person:not_found', 'error', 'Person not found');
    RETURN;
  END IF;

  -- check if requester has permission to update person
  IF exists(SELECT NULL
            FROM person.person_identifiers
            WHERE identifier_type = 'person_code'
              AND value = v_requester_code
              AND person_id = v_person_id
              AND active) = FALSE THEN
    po_data := json_build_object('code', 'err:person::not_found', 'error', 'Person not found');
    RETURN;
  END IF;

  v_person_data := person.get_person_data(v_person_id);

  po_data := result_success(v_person_data::json);
EXCEPTION
  WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_state = RETURNED_SQLSTATE, v_error_msg = MESSAGE_TEXT;
    po_data := result_error('err:internal:db', v_error_msg);
    RETURN;
END;
$BODY$;

GRANT EXECUTE ON PROCEDURE person.get_person(jsonb, jsonb) TO edim;
REVOKE ALL ON PROCEDURE person.get_person(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE person.get_person(jsonb, jsonb) IS 'Atgriež personas datus';
