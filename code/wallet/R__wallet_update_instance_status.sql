CREATE OR REPLACE PROCEDURE wallet.update_instance_status(
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
  v_instance    wallet.instances%ROWTYPE;
  v_existing    wallet.instances%ROWTYPE;
  v_result      json;
BEGIN
  v_data := pi_data;

  v_instance.id := NULLIF(trim((v_data ->> 'instanceId')), '');

  if v_instance.id is null then
    po_data := json_build_object('code', 'err:instances:not_found', 'error', 'Instances ieraksts nav atrasts');
    return;
  end if;

  case (v_data ->> 'action')
    when 'suspend' then v_instance.status := 'suspended';
    when 'unsuspend' then v_instance.status := 'active';
    when 'revoke' then v_instance.status := 'revoked';
    else v_instance.status := null;
    end case;

  if v_instance.status is null then
    po_data := json_build_object('code', 'err:instances:invalid_action', 'error', 'Nepareiza darbība');
    return;
  end if;

  select *
  into v_existing
  from wallet.instances
  where id = v_instance.id
    and active;

  if v_existing.id is null then
    po_data := json_build_object('code', 'err:instances:not_found', 'error', 'Instances ieraksts nav atrasts');
    return;
  end if;

  if v_existing.status = 'revoked' then
    po_data := json_build_object('code', 'err:instances:revoked', 'error',
                                 'Instanci nevar mainīt, jo tā ir atsaukta');
    return;
  end if;

  UPDATE wallet.instances
  SET status        = v_instance.status,
      date_modified = now()
  WHERE id = v_instance.id
    AND active
  RETURNING * INTO v_instance;

  UPDATE wallet.attestations
  SET status       = v_instance.status,
      date_modified = now()
  WHERE instance_id = v_instance.id
    AND status != 'revoked'
    AND active;

  po_data := result_success(wallet.get_instance_data(v_instance.hardware_key_tag)::json);
EXCEPTION
  WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_state = RETURNED_SQLSTATE, v_error_msg = MESSAGE_TEXT;
    po_data := result_error('err:internal:db', v_error_msg);
    RETURN;
END;
$BODY$;

GRANT EXECUTE ON PROCEDURE wallet.update_instance_status(jsonb, jsonb) TO edim;
REVOKE ALL ON PROCEDURE wallet.update_instance_status(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE wallet.update_instance_status IS 'Atjauno instances statusu';
