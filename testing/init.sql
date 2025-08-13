-- SPDX-License-Identifier: EUPL-1.2

create role lx with login nosuperuser inherit nocreatedb nocreaterole noreplication password 'test';
create role edim_public with login nosuperuser inherit nocreatedb nocreaterole noreplication password 'test';
create role sender_public with login nosuperuser inherit nocreatedb nocreaterole noreplication password 'test';
create role admin_public with login nosuperuser inherit nocreatedb nocreaterole noreplication password 'test';
create role lx_public with login nosuperuser inherit nocreatedb nocreaterole noreplication password 'test';
create role audit_public with login nosuperuser inherit nocreatedb nocreaterole noreplication password 'test';
create role wallet_public with login nosuperuser inherit nocreatedb nocreaterole noreplication password 'test';
grant lx to edim;

CREATE TABLESPACE edim_main OWNER edim LOCATION '/data/edim/main';
CREATE TABLESPACE edim_index OWNER edim LOCATION '/data/edim/index';
CREATE TABLESPACE edim_archive OWNER edim LOCATION '/data/edim/archive';
CREATE TABLESPACE edim_log OWNER edim LOCATION '/data/edim/log';
CREATE TABLESPACE lx_main OWNER lx LOCATION '/data/lx/main';
CREATE TABLESPACE lx_index OWNER lx LOCATION '/data/lx/index';
CREATE TABLESPACE lx_archive OWNER lx LOCATION '/data/lx/archive';