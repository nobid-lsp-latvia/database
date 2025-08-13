CREATE TABLE IF NOT EXISTS person.person_identifiers
(
  id              bigserial,
  person_id       character varying(26)    NOT NULL,
  identifier_type varchar(50)              NOT NULL,
  value           varchar(100)             NOT NULL,
  valid           boolean                           DEFAULT true,
  date_created    timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified   timestamp with time zone,
  active          boolean                           DEFAULT true,
  CONSTRAINT identifier_id_pkey PRIMARY KEY (id)
    USING INDEX TABLESPACE edim_index,
  CONSTRAINT identifier_person_id_fkey FOREIGN KEY (person_id)
    REFERENCES person.persons (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
)
  WITH (autovacuum_enabled = TRUE)
  TABLESPACE edim_archive;
ALTER TABLE person.person_identifiers
  OWNER to edim;

CREATE UNIQUE INDEX identifier_values_uniq
  ON person.person_identifiers (person_id, identifier_type, value)
  TABLESPACE edim_index
  WHERE active;
