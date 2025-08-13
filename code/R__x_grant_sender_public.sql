-- SPDX-License-Identifier: EUPL-1.2

-- person
GRANT USAGE ON SCHEMA sender TO sender_public;

GRANT EXECUTE ON PROCEDURE sender.save_submission_data(jsonb, jsonb) TO sender_public;
GRANT EXECUTE ON PROCEDURE sender.get_submission_status(jsonb, jsonb) TO sender_public;
GRANT EXECUTE ON PROCEDURE sender.update_submission_status(jsonb, jsonb) TO sender_public;

-- util
GRANT USAGE ON SCHEMA util TO sender_public;