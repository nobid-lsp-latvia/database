COMMENT ON TABLE person.persons IS 'Personu tabula';
COMMENT ON COLUMN person.persons.id IS 'Ieraksta identifikators';
COMMENT ON COLUMN person.persons.given_name IS 'Vārds';
COMMENT ON COLUMN person.persons.family_name IS 'Uzvārds';
COMMENT ON COLUMN person.persons.birthdate IS 'Dzimšanas datums';
COMMENT ON COLUMN person.persons.date_created IS 'Ieraksta izveides datums';
COMMENT ON COLUMN person.persons.date_modified IS 'Ieraksta labošanas datums';
COMMENT ON COLUMN person.persons.active IS 'Pazīme, vai ieraksts ir aktīvs';

COMMENT ON TABLE person.person_identifiers IS 'Personas identifikatoru veidi';
COMMENT ON COLUMN person.person_identifiers.id IS 'Ieraksta identifikators';
COMMENT ON COLUMN person.person_identifiers.person_id IS 'Saistītā persona';
COMMENT ON COLUMN person.person_identifiers.identifier_type IS 'Identifikatora tips';
COMMENT ON COLUMN person.person_identifiers.value IS 'Identifikatora vērtība';
COMMENT ON COLUMN person.person_identifiers.valid IS 'Pazīme vai identifikators ir derīgs';
COMMENT ON COLUMN person.person_identifiers.date_created IS 'Ieraksta izveides datums';
COMMENT ON COLUMN person.person_identifiers.date_modified IS 'Ieraksta labošanas datums';
COMMENT ON COLUMN person.person_identifiers.active IS 'Pazīme, vai ieraksts ir aktīvs';

COMMENT ON TABLE person.person_contact_info IS 'Personu kontakta informācija';
COMMENT ON COLUMN person.person_contact_info.id IS 'Ieraksta identifikators';
COMMENT ON COLUMN person.person_contact_info.person_id IS 'Saistītā persona';
COMMENT ON COLUMN person.person_contact_info.contact_type IS 'Kontakta tips (email, phone)';
COMMENT ON COLUMN person.person_contact_info.value IS 'Identifikatora vērtība';
COMMENT ON COLUMN person.person_contact_info.date_created IS 'Ieraksta izveides datums';
COMMENT ON COLUMN person.person_contact_info.date_modified IS 'Ieraksta labošanas datums';
COMMENT ON COLUMN person.person_contact_info.active IS 'Pazīme, vai ieraksts ir aktīvs';