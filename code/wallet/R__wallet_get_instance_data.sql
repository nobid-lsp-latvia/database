CREATE OR REPLACE FUNCTION wallet.get_instance_data(pi_hardware_key_tag varchar) RETURNS jsonb
  LANGUAGE plpgsql
  COST 100
  STABLE SECURITY DEFINER
AS
$BODY$
DECLARE
  v_result jsonb;
BEGIN

  SELECT row_to_json(rec)
    INTO v_result
    FROM (SELECT i.id               as "id",
                 i.status           as "status",
                 i.hardware_key_tag as "hardwareKeyTag",
                 i.public_key       as "publicKey",
                 i.fid              as "firebaseId",
                 i.attestation      as "attestation"
          FROM wallet.instances i
         WHERE i.hardware_key_tag = pi_hardware_key_tag
               and i.active
         LIMIT 1) rec;

  RETURN v_result;
END;
$BODY$;

GRANT EXECUTE ON FUNCTION wallet.get_instance_data(varchar) TO edim;
REVOKE ALL ON FUNCTION wallet.get_instance_data(varchar) FROM PUBLIC;

COMMENT ON FUNCTION wallet.get_instance_data(varchar) IS 'Atgriež instances datus';
