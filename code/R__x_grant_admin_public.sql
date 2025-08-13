-- SPDX-License-Identifier: EUPL-1.2

-- wallet
GRANT USAGE ON SCHEMA wallet TO admin_public;

GRANT EXECUTE ON PROCEDURE wallet.get_instance_list(jsonb, jsonb) TO admin_public;
GRANT EXECUTE ON PROCEDURE wallet.update_instance_status(jsonb, jsonb) TO admin_public;
GRANT EXECUTE ON PROCEDURE wallet.get_attestation_list(jsonb, jsonb) TO admin_public;
GRANT EXECUTE ON PROCEDURE wallet.update_attestation_status(jsonb, jsonb) TO admin_public;

-- person
GRANT USAGE ON SCHEMA person TO admin_public;

GRANT EXECUTE ON PROCEDURE person.get_person_id_by_code(jsonb, jsonb) TO admin_public;
GRANT EXECUTE ON PROCEDURE person.delete_person(jsonb, jsonb) TO admin_public;

-- util
GRANT USAGE ON SCHEMA util TO admin_public;