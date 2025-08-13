DROP TABLE IF EXISTS wallet.instances;

CREATE TABLE IF NOT EXISTS wallet.instances
(
  id            character varying(26)    NOT NULL DEFAULT generate_ulid(),
  fid           character varying(255)   NOT NULL,
  person_id     character varying(26)    NOT NULL,
  status        character varying(26)    NOT NULL DEFAULT 'active',
  date_created  timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified timestamp with time zone,
  active        boolean                           DEFAULT true,
  CONSTRAINT instances_id_pkey PRIMARY KEY (id)
    USING INDEX TABLESPACE edim_index,
  CONSTRAINT instances_person_id_fkey FOREIGN KEY (person_id)
    REFERENCES person.persons (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
)
  WITH (autovacuum_enabled = TRUE)
  TABLESPACE edim_archive;
ALTER TABLE wallet.instances
  OWNER to edim;

COMMENT ON TABLE wallet.instances IS 'Digitālā maka instances';
COMMENT ON COLUMN wallet.instances.id IS 'Ieraksta identifikators';
COMMENT ON COLUMN wallet.instances.fid IS 'Firebase instalācijas identifikators';
COMMENT ON COLUMN wallet.instances.person_id IS 'Saistītā persona';
COMMENT ON COLUMN wallet.instances.status IS 'Status ("active", "suspended", "revoked", "expired")';
COMMENT ON COLUMN wallet.instances.date_created IS 'Ieraksta izveides datums';
COMMENT ON COLUMN wallet.instances.date_modified IS 'Ieraksta labošanas datums';
COMMENT ON COLUMN wallet.instances.active IS 'Pazīme, vai ieraksts ir aktīvs';

CREATE INDEX IF NOT EXISTS instances_person_id_idx
  ON wallet.instances (person_id) tablespace edim_index
  where active;

ALTER TABLE wallet.instances
  ADD CONSTRAINT instances_status_check
    CHECK (status IN ('active', 'suspended', 'revoked', 'expired'));