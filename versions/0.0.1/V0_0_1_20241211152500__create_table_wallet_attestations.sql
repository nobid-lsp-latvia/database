DROP TABLE IF EXISTS wallet.attestations;

CREATE TABLE IF NOT EXISTS wallet.attestations
(
  id              uuid                     NOT NULL,
  instance_id     character varying(26)    NOT NULL,
  name            character varying(30),
  type            character varying(50),
  public_key      text                     NOT NULL,
  attributes      jsonb,
  status          character varying(26)    NOT NULL DEFAULT 'active',
  issued_on       timestamp with time zone NOT NULL,
  expires_on      timestamp with time zone,
  format          character varying(30),
  install_status  character varying(26)    not null,
  install_message character varying(300),
  date_created    timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified   timestamp with time zone,
  active          boolean                           DEFAULT true,
  CONSTRAINT attestations_id_pkey PRIMARY KEY (id)
    USING INDEX TABLESPACE edim_index,
  CONSTRAINT attestations_person_id_fkey FOREIGN KEY (instance_id)
    REFERENCES wallet.instances (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
)
  WITH (autovacuum_enabled = TRUE)
  TABLESPACE edim_archive;
ALTER TABLE wallet.attestations
  OWNER to edim;

COMMENT ON TABLE wallet.attestations IS 'Digitālā maka attestācijas';
COMMENT ON COLUMN wallet.attestations.id IS 'Ieraksta identifikators';
COMMENT ON COLUMN wallet.attestations.instance_id IS 'Firebase instalācijas identifikators';
COMMENT ON COLUMN wallet.attestations.name IS 'Ieraksta nosaukums';
COMMENT ON COLUMN wallet.attestations.type IS 'Ierakstsa tips';
COMMENT ON COLUMN wallet.attestations.public_key IS 'Attestācijas publiskā atslēga';
COMMENT ON COLUMN wallet.attestations.attributes IS 'Attestācijas atribūti';
COMMENT ON COLUMN wallet.attestations.status IS 'Status ("active", "suspended", "revoked", "expired")';
COMMENT ON COLUMN wallet.attestations.issued_on IS 'Izsniegšanas datums';
COMMENT ON COLUMN wallet.attestations.expires_on IS 'Derīguma termiņa beigas';
COMMENT ON COLUMN wallet.attestations.format IS 'Attestācijas formāts ("mDoc", "SD-JWT-VC")';
COMMENT ON COLUMN wallet.attestations.install_status IS 'Instalācijas status ("sent", "success", "error", "waiting_wi")';
COMMENT ON COLUMN wallet.attestations.install_message IS 'Instalācijas papildus informācija';
COMMENT ON COLUMN wallet.attestations.date_created IS 'Ieraksta izveides datums';
COMMENT ON COLUMN wallet.attestations.date_modified IS 'Ieraksta labošanas datums';
COMMENT ON COLUMN wallet.attestations.active IS 'Pazīme, vai ieraksts ir aktīvs';

CREATE INDEX IF NOT EXISTS attestations_instances_id_idx
  ON wallet.attestations (id, instance_id) tablespace edim_index
  where active;

ALTER TABLE wallet.attestations
  ADD CONSTRAINT attestations_status_check
    CHECK (status IN ('active', 'suspended', 'revoked', 'expired'));

ALTER TABLE wallet.attestations
  ADD CONSTRAINT attestations_install_status_check
    CHECK (install_status IN ('sent', 'success', 'error', 'waiting_wi'));