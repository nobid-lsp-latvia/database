-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE FUNCTION person.get_person_data(pi_person_id varchar) RETURNS jsonb
  LANGUAGE plpgsql
  COST 100
  VOLATILE SECURITY DEFINER
AS
$BODY$
DECLARE
  v_type   varchar = 'person_code';
  v_result jsonb;
BEGIN

  SELECT row_to_json(rec)
  INTO v_result
  FROM (SELECT p.id                                                                      as id,
               (select value
                from person.person_identifiers pi
                where pi.person_id = p.id
                  and pi.identifier_type = v_type
                  and active
                LIMIT 1)                                                                 as code,
               p.given_name                                                              as givenName,
               p.family_name                                                             as familyName,
               p.birthdate                                                               as birthDate,
               json_agg(json_build_object('type', pci.contact_type, 'value', pci.value)) AS contacts
        FROM person.persons p
               LEFT JOIN person.person_contact_info pci ON p.id = pci.person_id and pci.active
        WHERE p.id = pi_person_id
          and p.active
        GROUP BY p.id, p.given_name, p.family_name, p.birthdate
        LIMIT 1) rec;

  RETURN v_result;
END;
$BODY$;

GRANT EXECUTE ON FUNCTION person.get_person_data(varchar) TO edim;
REVOKE ALL ON FUNCTION person.get_person_data(varchar) FROM PUBLIC;

COMMENT ON FUNCTION person.get_person_data(varchar) IS 'Atgriež personas datus';