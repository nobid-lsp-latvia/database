CREATE OR REPLACE PROCEDURE wallet.update_attestation_status(
  pi_data jsonb,
  INOUT po_data jsonb)
  LANGUAGE plpgsql
  SECURITY DEFINER
AS
$BODY$
DECLARE
  v_error_state text;
  v_error_msg   text;
  v_data        jsonb;
  v_attestation wallet.attestations%ROWTYPE;
BEGIN
  v_data := pi_data;

  v_attestation.id := NULLIF(trim((v_data ->> 'attestationId')), '');

  if v_attestation.id is null then
    po_data := json_build_object('code', 'err:attestations:not_found', 'error', 'Instances attestācija nav atrasta');
    return;
  end if;

  v_attestation.instance_id := NULLIF(trim((v_data ->> 'instanceId')), '');

  if v_attestation.instance_id is null then
    po_data := json_build_object('code', 'err:attestations:not_found', 'error', 'Instances attestācija nav atrasta');
    return;
  end if;

  po_data := wallet.update_attestation_status(v_attestation, v_data ->> 'action');
EXCEPTION
  WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_state = RETURNED_SQLSTATE, v_error_msg = MESSAGE_TEXT;
    po_data := result_error('err:internal:db', v_error_msg);
    RETURN;
END;
$BODY$;

GRANT EXECUTE ON PROCEDURE wallet.update_attestation_status(jsonb, jsonb) TO edim;
REVOKE ALL ON PROCEDURE wallet.update_attestation_status(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE wallet.update_attestation_status IS 'Atjauno attribūtu statusu';
