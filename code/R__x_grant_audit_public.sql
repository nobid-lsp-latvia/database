-- SPDX-License-Identifier: EUPL-1.2

-- audit
grant usage on schema audit to audit_public;

grant execute on procedure audit.create_audit_partition(date) to audit_public;
grant execute on procedure audit.audit_person_data(text, text) to audit_public;
grant insert on table audit.person_data_requests to audit_public;

-- session
grant usage on schema session to audit_public;

grant execute on procedure session."create"(varchar, varchar, varchar, varchar, varchar, varchar, inet) to audit_public;
