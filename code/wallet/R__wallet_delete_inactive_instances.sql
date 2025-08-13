CREATE OR REPLACE PROCEDURE wallet.delete_inactive_instances(
  pi_data jsonb,
  INOUT po_data jsonb)
  LANGUAGE plpgsql
  SECURITY DEFINER
AS
$BODY$
DECLARE
  v_older_than_in_min int;
  v_error_state       text;
  v_error_msg         text;
  v_error_desc        text;
  v_data              jsonb;
BEGIN
  v_data := pi_data;

  v_older_than_in_min := COALESCE(nullif((v_data ->> 'OlderThanInMin')::bigint, 0), 60)::int;

  WITH deactivated_instances AS (
    UPDATE wallet.instances
      SET active = false,
        date_modified = CURRENT_TIMESTAMP
      WHERE person_id is null
        AND date_created < (CURRENT_TIMESTAMP - (v_older_than_in_min * INTERVAL '1 minute'))
        AND active
      RETURNING id::text)
  UPDATE wallet.attestations
  SET active        = false,
      date_modified = CURRENT_TIMESTAMP
  WHERE instance_id = ANY (ARRAY(SELECT id FROM deactivated_instances))
    AND active;

  po_data := result_success(null);
EXCEPTION
  WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_state = RETURNED_SQLSTATE, v_error_msg = MESSAGE_TEXT;
    po_data := result_error('err:internal:db', v_error_msg);
    RETURN;
END;
$BODY$;

GRANT EXECUTE ON PROCEDURE wallet.delete_inactive_instances(jsonb, jsonb) TO edim;
REVOKE ALL ON PROCEDURE wallet.delete_inactive_instances(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE wallet.delete_inactive_instances IS 'Izdzēš pagaidu instances';
