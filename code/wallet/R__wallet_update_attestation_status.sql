CREATE OR REPLACE FUNCTION wallet.update_attestation_status(pi_data record, pi_status varchar) RETURNS jsonb
  LANGUAGE plpgsql
  COST 100
  VOLATILE SECURITY DEFINER
AS
$BODY$
DECLARE
  v_existing    wallet.attestations%ROWTYPE;
  v_attestation wallet.attestations%ROWTYPE;
  v_result      json;
  po_data       jsonb;
BEGIN
  v_attestation := pi_data;

  case (pi_status)
    when 'suspend' then v_attestation.status := 'suspended';
    when 'unsuspend' then v_attestation.status := 'active';
    when 'revoke' then v_attestation.status := 'revoked';
    else v_attestation.status := null;
    end case;

  if v_attestation.status is null then
    po_data := json_build_object('code', 'err:attestations:invalid_action', 'error', 'Nepareiza darbība');
    return po_data;
  end if;

  select *
  into v_existing
  from wallet.attestations
  where id = v_attestation.id
    and instance_id = v_attestation.instance_id
    and active;

  if v_existing.id is null then
    po_data := json_build_object('code', 'err:attestations:not_found', 'error',
                                 'Instances attestācijas ieraksts nav atrasts');
    return po_data;
  end if;

  if v_existing.status = 'revoked' then
    po_data := json_build_object('code', 'err:attestations:revoked', 'error',
                                 'Instances attestācijas nevar mainīt, jo tā ir atsaukta');
    return po_data;
  end if;

  IF v_existing.type LIKE '%.pid.%' THEN
    UPDATE wallet.attestations
    SET status        = v_attestation.status,
        date_modified = now()
    WHERE instance_id = v_attestation.instance_id
      and active;
  ELSE
    UPDATE wallet.attestations
    SET status        = v_attestation.status,
        date_modified = now()
    WHERE id = v_attestation.id
      AND instance_id = v_attestation.instance_id
      and active;
  END IF;

  SELECT row_to_json(rec)
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
        WHERE a.id = v_attestation.id
          AND a.instance_id = v_attestation.instance_id
          AND a.active
        LIMIT 1) rec;

  po_data := result_success(v_result);
  return po_data;
END;
$BODY$;

GRANT EXECUTE ON FUNCTION wallet.update_attestation_status(record, varchar) TO edim;
REVOKE ALL ON FUNCTION wallet.update_attestation_status(record, varchar) FROM PUBLIC;

COMMENT ON FUNCTION wallet.update_attestation_status(record, varchar) IS 'Atjauno attribūtu statusu';