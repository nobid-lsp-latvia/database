-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE PROCEDURE sender.get_submission_status(
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
  v_submission  sender.submission%ROWTYPE;
  v_result      json;
BEGIN
  v_data := pi_data;

  v_submission.id := NULLIF(trim((v_data ->> 'trackingId')), '');

  if v_submission.id is null then
    po_data := json_build_object('code', 'err:submission:not_found', 'error', 'Sūtīšanas ieraksts nav atrasts');
    return;
  end if;

  SELECT row_to_json(rec)
  INTO v_result
  FROM (SELECT s.id      as trackingId,
               s.status  as status,
               s.info    as info,
               s.sent_on as sentOn
        FROM sender.submission s
        WHERE s.id = v_submission.id
          and s.active
        LIMIT 1) rec;

  po_data := result_success(v_result);
EXCEPTION
  WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_state = RETURNED_SQLSTATE, v_error_msg = MESSAGE_TEXT;
    po_data := result_error('err:internal:db', v_error_msg);
    RETURN;
END;
$BODY$;

GRANT EXECUTE ON PROCEDURE sender.get_submission_status(jsonb, jsonb) TO edim;
REVOKE ALL ON PROCEDURE sender.get_submission_status(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE sender.get_submission_status IS 'Atgriež sūtījuma statusu';
