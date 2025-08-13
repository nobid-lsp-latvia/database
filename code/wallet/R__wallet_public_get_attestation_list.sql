CREATE OR REPLACE PROCEDURE wallet.public_get_attestation_list(
  pi_data jsonb,
  INOUT po_data jsonb)
  LANGUAGE plpgsql
  SECURITY DEFINER
AS
$BODY$
DECLARE
  v_error_state text;
  v_error_msg   text;
  v_person_code varchar;
  v_person_guid varchar;
  v_person_id   varchar;
  v_data        jsonb;
  v_instance_id varchar;
  v_result      json;
  v_page_size   integer;
  v_page        integer;
  v_page_offset integer;
  v_status      varchar[];
  v_total_count integer;
BEGIN
  v_data := pi_data;

  v_person_code := NULLIF(trim((v_data ->> 'code')), '');
  v_person_guid := NULLIF(trim((v_data ->> 'id')), '');
  v_page_size := NULLIF((v_data ->> 'perPage')::integer, 20);
  v_page := NULLIF((v_data ->> 'page')::integer, 1);
  v_page_offset := v_page_size * (v_page - 1);

  SELECT array_agg(value::varchar)
  INTO v_status
  FROM jsonb_array_elements_text(v_data -> 'statuses') AS value;

  IF v_status IS NULL THEN
    v_status := ARRAY ['active', 'suspended'];
  END IF;

  v_person_id := COALESCE(
      person.get_person_id_by_code(v_person_code),
      person.get_person_id_by_guid(v_person_guid));

  IF v_person_id IS NULL THEN
    po_data :=
        json_build_object('code', 'err:instance_status:not_found', 'error', 'Instances ieraksts nav atrasts');
    RETURN;
  END IF;

  v_instance_id := NULLIF(trim((v_data ->> 'instanceId')), '');

  IF v_instance_id IS NULL THEN
    po_data :=
        json_build_object('code', 'err:instance_status:not_found', 'error', 'Instances ieraksts nav atrasts');
    RETURN;
  END IF;

  -- verify if asking data for the same person
  IF NOT EXISTS(SELECT NULL
                FROM wallet.instances
                WHERE id = v_instance_id
                  AND person_id = v_person_id
                  AND active) THEN
    po_data :=
        json_build_object('code', 'err:instance_status:not_found', 'error', 'Instances ieraksts nav atrasts');
    RETURN;
  END IF;

  SELECT count(1)
  INTO v_total_count
  FROM wallet.attestations a
  WHERE a.instance_id = v_instance_id
    AND status = ANY (v_status)
    AND a.active;

  IF v_total_count = 0 THEN
    po_data :=
        json_build_object('code', 'err:attestations:not_found', 'error', 'Instances attestācijas nav atrastas');
    RETURN;
  END IF;

  SELECT json_agg(rec)
  INTO v_result
  FROM (SELECT a.id              AS "id",
               a.name            AS "name",
               a.type            AS "type",
               a.public_key      AS "publicKey",
               a.attributes      AS "attributes",
               a.status          AS "status",
               a.issued_on       AS "issuedOn",
               a.expires_on      AS "expiresOn",
               a.format          AS "format",
               a.install_status  AS "installStatus",
               a.install_message AS "installMessage"
        FROM wallet.attestations a
        WHERE a.instance_id = v_instance_id
          AND status = ANY (v_status)
          AND a.active
        ORDER BY a.issued_on DESC
        OFFSET v_page_offset LIMIT v_page_size) rec;

  IF v_result IS NULL THEN
    po_data :=
        json_build_object('code', 'err:attestations:not_found', 'error', 'Instances attestācijas nav atrastas');
    RETURN;
  END IF;

  po_data := result_success(json_build_object('count', v_total_count, 'data', v_result));
EXCEPTION
  WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_state = RETURNED_SQLSTATE, v_error_msg = MESSAGE_TEXT;
    po_data := result_error('err:internal:db', v_error_msg);
    RETURN;
END;
$BODY$;

GRANT EXECUTE ON PROCEDURE wallet.public_get_attestation_list(jsonb, jsonb) TO edim;
REVOKE ALL ON PROCEDURE wallet.public_get_attestation_list(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE wallet.public_get_attestation_list IS 'Atgriež instances statusu ar tās atribūtiem';
