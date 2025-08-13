CREATE OR REPLACE PROCEDURE wallet.get_attestation_list(
  pi_data jsonb,
  INOUT po_data jsonb)
  LANGUAGE plpgsql
  SECURITY DEFINER
AS
$BODY$
DECLARE
  v_error_state text;
  v_error_msg   text;
  v_error_desc  text;
  v_data        jsonb;
  v_attestation wallet.attestations%ROWTYPE;
  v_result      json;
BEGIN
  v_data := pi_data;

  v_attestation.instance_id := NULLIF(trim((v_data ->> 'instanceId')), '');

  if v_attestation.instance_id is null then
    po_data := json_build_object('code', 'err:attestations:not_found', 'error', 'Instances ieraksts nav atrasts');
    return;
  end if;

  SELECT json_agg(rec)
  INTO v_result
  FROM (SELECT a.id              as "id",
               a.name            as "name",
               a.type            as "type",
               a.public_key      as "publicKey",
               a.attributes      as "attributes",
               a.status          as "status",
               a.issued_on       as "issuedOn",
               a.expires_on      as "expiresOn",
               a.format          as "format",
               a.install_status  as "installStatus",
               a.install_message as "installMessage"
        FROM wallet.attestations a
        WHERE a.instance_id = v_attestation.instance_id
          and a.active) rec;

  if v_result is null then
    po_data := json_build_object('code', 'err:attestations:not_found', 'error', 'Instances attestācijas nav atrastas');
    return;
  end if;

  po_data := result_success(v_result);
EXCEPTION
  WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_state = RETURNED_SQLSTATE, v_error_msg = MESSAGE_TEXT;
    po_data := result_error('err:internal:db', v_error_msg);
    RETURN;
END;
$BODY$;

GRANT EXECUTE ON PROCEDURE wallet.get_attestation_list(jsonb, jsonb) TO edim;
REVOKE ALL ON PROCEDURE wallet.get_attestation_list(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE wallet.get_attestation_list IS 'Atgriež sarakstu ar attribūtu kopām';
