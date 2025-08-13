-- Delete test data
DELETE FROM wallet.attestations;
DELETE FROM wallet.instances;

ALTER TABLE IF EXISTS wallet.instances
    ALTER COLUMN fid DROP NOT NULL;

ALTER TABLE IF EXISTS wallet.instances
    ALTER COLUMN active SET NOT NULL;

ALTER TABLE IF EXISTS wallet.instances
    ADD COLUMN hardware_key_tag character varying(50) NOT NULL;

COMMENT ON COLUMN wallet.instances.hardware_key_tag
    IS 'Unikāls instances iekārtas atslēgas identifikators';

ALTER TABLE IF EXISTS wallet.instances
    ADD COLUMN public_key text NOT NULL;

COMMENT ON COLUMN wallet.instances.public_key
    IS 'PEM kodēta aparatūras glabātuves izsniegta publiskā atslēga, kas ir specifiska šai instancei';

ALTER TABLE IF EXISTS wallet.instances
    ADD COLUMN attestation jsonb;

COMMENT ON COLUMN wallet.instances.attestation
    IS 'Papildus atestācijas dati uz instances inicializācijas brīdi';

CREATE UNIQUE INDEX instances_hardware_key_tag_uniq ON wallet.instances(hardware_key_tag) WHERE active;
