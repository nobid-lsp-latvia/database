ALTER TABLE wallet.instances ALTER COLUMN person_id DROP NOT NULL;
ALTER TABLE wallet.instances ALTER COLUMN person_id SET DEFAULT NULL;
