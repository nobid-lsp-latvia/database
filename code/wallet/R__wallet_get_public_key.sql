CREATE OR REPLACE PROCEDURE wallet.get_public_key(
	IN pi_data jsonb,
	INOUT po_data jsonb)
LANGUAGE 'plpgsql'
    SECURITY DEFINER 
AS $BODY$
DECLARE
  v_error_state text;
  v_error_msg   text;
  v_data        jsonb;
  v_type        text;
  v_tag         text;
  v_pubkey      text;
  v_person_id   text;
  v_person      jsonb;
BEGIN
  v_data := pi_data;

  v_type := nullif(trim((v_data ->> 'type')), '');
  v_tag  := nullif(trim((v_data ->> 'hardwareKeyTag')), '');

  if v_type = 'instance' then
    select person_id, public_key
      into v_person_id, v_pubkey
      from wallet.instances
     where hardware_key_tag = v_tag
           and status = 'active'
           and active;
  end if;

  if v_pubkey is null then
    po_data := json_build_object('code', 'err:public_key:not_found', 'error', 'Publiskā atslēga netika atrasta');
    return;
  end if;

  if v_person_id is not null then
    v_person := person.get_person_data(v_person_id);
  end if;

  po_data := result_success(json_build_object('publicKey', v_pubkey, 'person', v_person));
EXCEPTION
  WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_state = RETURNED_SQLSTATE, v_error_msg = MESSAGE_TEXT;
    po_data := result_error('err:internal:db', v_error_msg);
    RETURN;
END;
$BODY$;
ALTER PROCEDURE wallet.get_public_key(jsonb, jsonb)
    OWNER TO edim;

GRANT EXECUTE ON PROCEDURE wallet.get_public_key(jsonb, jsonb) TO edim;
REVOKE ALL ON PROCEDURE wallet.get_public_key(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE wallet.get_public_key(jsonb, jsonb)
    IS 'Atgriež publisko atslēgu un personu pēc atslēgas identifikatora';
