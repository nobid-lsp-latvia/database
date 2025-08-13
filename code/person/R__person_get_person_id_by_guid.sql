-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE FUNCTION person.get_person_id_by_guid(pi_value varchar) RETURNS VARCHAR
  LANGUAGE plpgsql
  COST 100
  VOLATILE SECURITY DEFINER
AS
$BODY$
DECLARE
  v_result varchar;
BEGIN

  SELECT id
  INTO v_result
  FROM person.persons
  WHERE id = pi_value
    AND active;

  RETURN v_result;
END;
$BODY$;

GRANT EXECUTE ON FUNCTION person.get_person_id_by_guid(varchar) TO edim;
REVOKE ALL ON FUNCTION person.get_person_id_by_guid(varchar) FROM PUBLIC;

COMMENT ON FUNCTION person.get_person_id_by_guid(varchar) IS 'Atrod personu pēc personas GUID';
