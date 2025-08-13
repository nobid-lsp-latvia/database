-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE PROCEDURE person.save_person(
  pi_data jsonb,
  INOUT po_data jsonb)
  LANGUAGE plpgsql
  SECURITY DEFINER
AS
$BODY$
DECLARE
  v_error_state        text;
  v_error_msg          text;
  v_error_desc         text;
  v_data               jsonb;
  v_person_contact_raw jsonb;
  v_person             person.persons%ROWTYPE;
  v_person_contact     person.person_contact_info%ROWTYPE;
  v_person_identifier  person.person_identifiers%ROWTYPE;
  v_requester_code     varchar;
BEGIN
  v_data := pi_data;

  v_person.id := NULLIF(trim((v_data ->> 'id')), '');
  v_person.birthdate := NULLIF(trim((v_data ->> 'birthDate')), '');
  v_person.given_name := NULLIF(trim((v_data ->> 'givenName')), '');
  v_person.family_name := NULLIF(trim((v_data ->> 'familyName')), '');
  v_person_identifier.identifier_type := 'person_code';
  v_person_identifier.value := NULLIF(trim((v_data ->> 'code')), '');
  v_requester_code := NULLIF(trim((v_data ->> 'requesterCode')), '');

  -- check if requester has permission to update person
  IF v_person_identifier.value != v_requester_code THEN
    po_data := json_build_object('code', 'err:person::not_found', 'error', 'Person not found');
    RETURN;
  END IF;

  v_person.id = person.get_person_id_by_code(v_person_identifier.value);

  IF v_person.id IS NULL THEN
    INSERT INTO person.persons(given_name, family_name, birthdate)
    VALUES (v_person.given_name, v_person.family_name, v_person.birthdate)
    RETURNING id INTO v_person.id;
  ELSE
    UPDATE person.persons
    SET given_name    = v_person.given_name,
        family_name   = v_person.family_name,
        birthdate     = v_person.birthdate,
        date_modified = now()
    WHERE id = v_person.id
      AND (given_name IS DISTINCT FROM v_person.given_name
      OR family_name IS DISTINCT FROM v_person.family_name
      OR birthdate IS DISTINCT FROM v_person.birthdate);
  END IF;

  v_person_identifier.person_id := v_person.id;

  INSERT INTO person.person_identifiers(person_id, identifier_type, value)
  VALUES (v_person_identifier.person_id, v_person_identifier.identifier_type, v_person_identifier.value)
  ON CONFLICT (person_id, identifier_type, value)
  WHERE (active = true) DO NOTHING;

  FOR v_person_contact_raw IN SELECT jsonb_array_elements(v_data -> 'contacts')
    LOOP
      v_person_contact.person_id := v_person.id;
      v_person_contact.contact_type := NULLIF(trim((v_person_contact_raw ->> 'type')), '');
      v_person_contact.value := NULLIF(trim((v_person_contact_raw ->> 'value')), '');

      -- check if contact info exists for specific type
      IF exists(SELECT NULL
                FROM person.person_contact_info
                WHERE person_id = v_person_contact.person_id
                  AND contact_type = v_person_contact.contact_type
                  AND active) THEN
        -- deactivate old contact info if it is different
        UPDATE person.person_contact_info
        SET active        = FALSE,
            date_modified = CURRENT_TIMESTAMP
        WHERE person_id = v_person_contact.person_id
          AND contact_type = v_person_contact.contact_type
          AND value != v_person_contact.value
          AND active;
      END IF;

      INSERT INTO person.person_contact_info(person_id, contact_type, value)
      VALUES (v_person_contact.person_id, v_person_contact.contact_type, v_person_contact.value)
      ON CONFLICT (person_id, contact_type, value)
      WHERE (active = true) DO NOTHING;
    END LOOP;

  po_data := result_success(person.get_person_data(v_person.id)::json);
EXCEPTION
  WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_state = RETURNED_SQLSTATE, v_error_msg = MESSAGE_TEXT;
    po_data := result_error('err:internal:db', v_error_msg);
    RETURN;
END;
$BODY$;

GRANT EXECUTE ON PROCEDURE person.save_person(jsonb, jsonb) TO edim;
REVOKE ALL ON PROCEDURE person.save_person(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE person.save_person(jsonb, jsonb) IS 'Saglabā personas datus';
