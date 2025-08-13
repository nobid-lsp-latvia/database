CREATE TABLE IF NOT EXISTS person.person_contact_info
(
  id            bigserial,
  person_id     character varying(26)    NOT NULL,
  contact_type  varchar(50)              NOT NULL,
  value         varchar(100)             NOT NULL,
  date_created  timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified timestamp with time zone,
  active        boolean                           DEFAULT true,
  CONSTRAINT contact_info_id_pkey PRIMARY KEY (id)
    USING INDEX TABLESPACE edim_index,
  CONSTRAINT contact_person_id_fkey FOREIGN KEY (person_id)
    REFERENCES person.persons (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
)
  WITH (autovacuum_enabled = TRUE)
  TABLESPACE edim_archive;
ALTER TABLE person.person_contact_info
  OWNER to edim;

CREATE UNIQUE INDEX contact_values_uniq
  ON person.person_contact_info (person_id, contact_type, value)
  TABLESPACE edim_index
  WHERE active;