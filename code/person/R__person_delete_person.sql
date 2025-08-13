-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE PROCEDURE person.delete_person(
  pi_data jsonb,
  INOUT po_data jsonb)
  LANGUAGE plpgsql
  SECURITY DEFINER
AS
$BODY$
DECLARE
  v_error_state          text;
  v_error_msg            text;
  v_data                 jsonb;
  v_person               person.persons%ROWTYPE;
  v_person_identifier    person.person_identifiers%ROWTYPE;
  v_requester_code       varchar;
  v_updated_instance_ids text[];
  v_id                   text;
BEGIN
  v_data := pi_data;

  v_person.id := NULLIF(trim((v_data ->> 'id')), '');
  v_person_identifier.identifier_type := 'person_code';
  v_person_identifier.value := NULLIF(trim((v_data ->> 'code')), '');
  v_requester_code := NULLIF(trim((v_data ->> 'requesterCode')), '');

  -- if passed just person code, we need additional checks
  IF v_person.id IS NULL AND v_person_identifier.value IS NOT NULL THEN
    -- check if requester has permission to update person
    IF v_person_identifier.value != v_requester_code THEN
      po_data := json_build_object('code', 'err:person::not_found', 'error', 'Person not found');
      RETURN;
    END IF;

    v_person.id = person.get_person_id_by_code(v_person_identifier.value);
  end if;

  IF v_person.id IS NULL THEN
    po_data := json_build_object('code', 'err:person::not_found', 'error', 'Person not found');
    RETURN;
  END IF;

  -- revoke all instances
  FOR v_id IN
    UPDATE wallet.instances
      SET status = 'revoked',
        date_modified = now()
      WHERE person_id = v_person.id
        AND active
      RETURNING id
    LOOP
      v_updated_instance_ids := array_append(v_updated_instance_ids, v_id);
    END LOOP;

  -- revoke all related attestations
  UPDATE wallet.attestations
  SET status        = 'revoked',
      date_modified = now()
  WHERE instance_id in (select unnest(v_updated_instance_ids))
    and active;

  -- delete person related contacts
  UPDATE person.person_contact_info
  SET active        = false,
      date_modified = now()
  WHERE person_id = v_person.id
    and active;

  -- delete person related identifications
  UPDATE person.person_identifiers
  SET active        = false,
      date_modified = now()
  WHERE person_id = v_person.id
    and active;

  -- delete person
  UPDATE person.persons
  SET active        = false,
      date_modified = now()
  WHERE id = v_person.id
    and active;

  po_data := result_success(null);
EXCEPTION
  WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_state = RETURNED_SQLSTATE, v_error_msg = MESSAGE_TEXT;
    po_data := result_error('err:internal:db', v_error_msg);
    RETURN;
END;
$BODY$;

GRANT EXECUTE ON PROCEDURE person.delete_person(jsonb, jsonb) TO edim;
REVOKE ALL ON PROCEDURE person.delete_person(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE person.delete_person(jsonb, jsonb) IS 'Izdzēš personu un visas ar viņu saistīto informāciju';
