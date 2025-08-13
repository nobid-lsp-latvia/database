-- SPDX-License-Identifier: EUPL-1.2

do
$$
begin
  if exists (SELECT * FROM pg_tables where schemaname = 'session' and tablename='create') then
      call session."create"('TEST', '11111111111', null, null, null, null);

      SELECT (pcf).functionid::regprocedure, (pcf).lineno, (pcf).statement, (pcf).sqlstate, (pcf).message, (pcf).detail, (pcf).hint, (pcf).level,  (pcf)."position", (pcf).query, (pcf).context
          FROM ( SELECT plpgsql_check_function_tb(pg_proc.oid, COALESCE(pg_trigger.tgrelid, 0)) AS pcf
            FROM pg_proc LEFT JOIN pg_trigger ON (pg_trigger.tgfoid = pg_proc.oid)
              WHERE prolang = (
                SELECT lang.oid
                 FROM pg_language lang
                    WHERE lang.lanname = 'plpgsql') AND pronamespace <> (
                         SELECT nsp.oid FROM pg_namespace nsp
                             WHERE nsp.nspname = 'pg_catalog') AND (pg_proc.prorettype <> (
                                SELECT typ.oid FROM pg_type typ
                                   WHERE typ.typname = 'trigger') OR pg_trigger.tgfoid IS NOT NULL ) OFFSET 0 ) ss
      WHERE (pcf).message not like 'unused parameter "pi_data"'
      ORDER BY (pcf).functionid::regprocedure::text, (pcf).lineno;
  end if;
end
$$
;
