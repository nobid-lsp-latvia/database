CREATE OR REPLACE PROCEDURE wallet.create_instance(
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
  v_person      jsonb;
  v_person_code varchar;
  v_instance    wallet.instances%ROWTYPE;
BEGIN
  v_data := pi_data;

  v_person := (v_data -> 'person')::jsonb;
  v_person_code := nullif(trim((v_person ->> 'code')), '');

  if v_person is null or v_person_code is null then
    po_data := json_build_object('code', 'err:person:required', 'error', 'Personas dati ir obligāti');
    return;
  end if;

  if v_person_code = 'anonymous' then
    v_instance.person_id := null;
  else
    v_instance.person_id := person.get_person_id_by_code(v_person_code);
    if v_instance.person_id is null then
      call person.save_person(v_person, po_data);
      if not ((po_data ->> 'success')::boolean) then
        return;
      end if;

      v_instance.person_id := ((po_data -> 'data') ->> 'id')::text;

      po_data := null;
    end if;
  end if;

  v_instance.hardware_key_tag := NULLIF(trim((v_data ->> 'hardwareKeyTag')), '');
  v_instance.public_key := NULLIF(trim((v_data ->> 'publicKey')), '');

  v_instance.attestation := v_data - '{person,hardwareKeyTag,publicKey}'::text[];

  INSERT INTO wallet.instances(person_id, hardware_key_tag, public_key, attestation)
  VALUES (v_instance.person_id, v_instance.hardware_key_tag, v_instance.public_key, v_instance.attestation);

  po_data := result_success(wallet.get_instance_data(v_instance.hardware_key_tag)::json);
EXCEPTION
  WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_state = RETURNED_SQLSTATE, v_error_msg = MESSAGE_TEXT;
    po_data := result_error('err:internal:db', v_error_msg);
    RETURN;
END;
$BODY$;

GRANT EXECUTE ON PROCEDURE wallet.create_instance(jsonb, jsonb) TO edim;
REVOKE ALL ON PROCEDURE wallet.create_instance(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE wallet.create_instance IS 'Saglabā jaunu instances ierakstu';
