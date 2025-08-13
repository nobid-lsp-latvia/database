-- SPDX-License-Identifier: EUPL-1.2

GRANT USAGE ON SCHEMA wallet TO wallet_public;

GRANT EXECUTE ON PROCEDURE wallet.create_instance(jsonb, jsonb) TO wallet_public;
GRANT EXECUTE ON PROCEDURE wallet.get_public_key(jsonb, jsonb) TO wallet_public;
GRANT EXECUTE ON PROCEDURE wallet.delete_inactive_instances(jsonb, jsonb) TO wallet_public;
GRANT EXECUTE ON PROCEDURE wallet.get_instance_by_tag(jsonb, jsonb) TO wallet_public;
