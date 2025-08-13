-- SPDX-License-Identifier: EUPL-1.2

-- person
GRANT USAGE ON SCHEMA person TO edim_public;

GRANT EXECUTE ON PROCEDURE person.save_person(jsonb, jsonb) TO edim_public;
GRANT EXECUTE ON PROCEDURE person.get_person(jsonb, jsonb) TO edim_public;
GRANT EXECUTE ON PROCEDURE person.delete_person(jsonb, jsonb) TO edim_public;

-- wallet
GRANT USAGE ON SCHEMA wallet TO edim_public;
GRANT EXECUTE ON PROCEDURE wallet.get_instance_list(jsonb, jsonb) TO edim_public;
GRANT EXECUTE ON PROCEDURE wallet.public_get_attestation_list(jsonb, jsonb) TO edim_public;
GRANT EXECUTE ON PROCEDURE wallet.public_update_attestation_status(jsonb, jsonb) TO edim_public;

-- util
GRANT USAGE ON SCHEMA util TO edim_public;