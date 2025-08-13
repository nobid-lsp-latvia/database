DROP TABLE IF EXISTS sender.submission;

CREATE TABLE IF NOT EXISTS sender.submission
(
  id            character varying(26)    NOT NULL DEFAULT generate_ulid(),
  message_id    character varying(26),
  submit_to     character varying(100)   NOT NULL,
  sender_from   json                     NOT NULL,
  content       json                     NOT NULL,
  subject       character varying(255)   NOT NULL,
  status        character varying(50)    NOT NULL,
  info          text,
  sent_on       timestamp with time zone,
  date_created  timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_modified timestamp with time zone,
  active        boolean                           DEFAULT true,
  CONSTRAINT sender_id_pkey PRIMARY KEY (id)
    USING INDEX TABLESPACE edim_index
)
  WITH (autovacuum_enabled = TRUE)
  TABLESPACE edim_archive;
ALTER TABLE sender.submission
  OWNER to edim;

COMMENT ON TABLE sender.submission IS 'E-pasta un īsziņas sūtīšanas ieraksti';
COMMENT ON COLUMN sender.submission.id IS 'Ieraksta identifikators';
COMMENT ON COLUMN sender.submission.message_id IS 'Ziņas ārējais identifikators';
COMMENT ON COLUMN sender.submission.submit_to IS 'Saņēmēja dati';
COMMENT ON COLUMN sender.submission.sender_from IS 'Sūtītāja dati';
COMMENT ON COLUMN sender.submission.content IS 'Ziņas saturs';
COMMENT ON COLUMN sender.submission.subject IS 'Ziņas priekšmets';
COMMENT ON COLUMN sender.submission.status IS 'Ziņas statuss';
COMMENT ON COLUMN sender.submission.info IS 'Ziņas statusa papildus informācija';
COMMENT ON COLUMN sender.submission.sent_on IS 'Ziņas izsūtīšanas datums';
COMMENT ON COLUMN sender.submission.date_created IS 'Ieraksta izveides datums';
COMMENT ON COLUMN sender.submission.date_modified IS 'Ieraksta labošanas datums';
COMMENT ON COLUMN sender.submission.active IS 'Pazīme, vai ieraksts ir aktīvs';
