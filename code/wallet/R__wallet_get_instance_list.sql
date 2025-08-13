CREATE OR REPLACE PROCEDURE wallet.get_instance_list(
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
  v_person_code varchar;
  v_person_guid varchar;
  v_person_id   varchar;
  v_result      json;
BEGIN
  v_data := pi_data;

  v_person_code := NULLIF(trim((v_data ->> 'code')), '');
  v_person_guid := NULLIF(trim((v_data ->> 'id')), '');

  v_person_id := COALESCE(
          person.get_person_id_by_code(v_person_code),
          person.get_person_id_by_guid(v_person_guid));

  if v_person_id is null then
    po_data := json_build_object('code', 'err:instances:not_found', 'error', 'Instances ieraksti nav atrasts');
    return;
  end if;

  SELECT json_agg(rec)
  INTO v_result
  FROM (SELECT i.id               as "id",
               i.status           as "status",
               i.hardware_key_tag as "hardwareKeyTag",
               i.fid              as "firebaseId"
        FROM wallet.instances i
        WHERE i.person_id = v_person_id
          and i.active) rec;

  po_data := result_success(v_result);
EXCEPTION
  WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_state = RETURNED_SQLSTATE, v_error_msg = MESSAGE_TEXT;
    po_data := result_error('err:internal:db', v_error_msg);
    RETURN;
END;
$BODY$;

GRANT EXECUTE ON PROCEDURE wallet.get_instance_list(jsonb, jsonb) TO edim;
REVOKE ALL ON PROCEDURE wallet.get_instance_list(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE wallet.get_instance_list IS 'Atgriež sarakstu ar instances ierakstiem';
