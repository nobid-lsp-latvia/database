CREATE TABLE IF NOT EXISTS person.persons
(
  id            character varying(26)    NOT NULL DEFAULT generate_ulid(),
  given_name    varchar(100)             NOT NULL,
  family_name   varchar(100)             NOT NULL,
  birthdate     date,
  date_created  timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified timestamp with time zone,
  active        boolean                           DEFAULT true,
  CONSTRAINT persons_id_pkey PRIMARY KEY (id)
    USING INDEX TABLESPACE edim_index
)
  WITH (autovacuum_enabled = TRUE)
  TABLESPACE edim_archive;
ALTER TABLE person.persons
  OWNER to edim;
