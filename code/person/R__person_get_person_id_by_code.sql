-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE PROCEDURE person.get_person_id_by_code(
  pi_data jsonb,
  INOUT po_data jsonb)
  LANGUAGE plpgsql
  SECURITY DEFINER
AS
$BODY$
DECLARE
  v_data        jsonb;
  v_result      varchar;
  v_person_code varchar;
  v_person_id   varchar;
BEGIN
  v_data := pi_data;
  v_person_code := NULLIF(trim((v_data ->> 'code')), '');

  v_person_id := person.get_person_id_by_code(v_person_code);

  IF v_person_id IS NULL THEN
    po_data := json_build_object('code', 'err:person:not_found', 'error', 'Person not found');
    RETURN;
  END IF;

  po_data := result_success(json_build_object('Id', v_person_id));
END;
$BODY$;

GRANT EXECUTE ON PROCEDURE person.get_person_id_by_code(jsonb, jsonb) TO edim;
REVOKE ALL ON PROCEDURE person.get_person_id_by_code(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE person.get_person_id_by_code(jsonb, jsonb) IS 'Atrod personu pēc personas koda';

CREATE OR REPLACE FUNCTION person.get_person_id_by_code(pi_value varchar) RETURNS VARCHAR
  LANGUAGE plpgsql
  COST 100
  VOLATILE SECURITY DEFINER
AS
$BODY$
DECLARE
  v_type   varchar = 'person_code';
  v_result varchar;
BEGIN

  SELECT person_id
  INTO v_result
  FROM person.person_identifiers
  WHERE identifier_type = v_type
    AND value = pi_value
    AND active;

  RETURN v_result;
END;
$BODY$;

GRANT EXECUTE ON FUNCTION person.get_person_id_by_code(varchar) TO edim;
REVOKE ALL ON FUNCTION person.get_person_id_by_code(varchar) FROM PUBLIC;

COMMENT ON FUNCTION person.get_person_id_by_code(varchar) IS 'Atrod personu pēc personas koda';