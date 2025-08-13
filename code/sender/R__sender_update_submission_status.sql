-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE PROCEDURE sender.update_submission_status(
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
  v_sent_on     timestamp with time zone;
BEGIN
  v_data := pi_data;

  v_submission.id := NULLIF(trim((v_data ->> 'trackingId')), '');
  v_submission.status := COALESCE((NULLIF(trim((v_data ->> 'status')), '')), 'error');
  v_submission.info := NULLIF(trim((v_data ->> 'info')), '');
  v_submission.message_id := NULLIF(trim((v_data ->> 'messageId')), '');

  if v_submission.id is null then
    po_data := json_build_object('code', 'err:submission:not_found', 'error', 'Sūtīšanas ieraksts nav atrasts');
    return;
  end if;

  if v_submission.status = 'sent' then
    v_sent_on := CURRENT_TIMESTAMP;
  end if;

  UPDATE sender.submission
  SET status        = v_submission.status,
      info          = v_submission.info,
      sent_on       = v_sent_on,
      message_id    = v_submission.message_id,
      date_modified = CURRENT_TIMESTAMP
  where id = v_submission.id
    and active;

  po_data := result_success(json_build_object('trackingId', v_submission.id));
EXCEPTION
  WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_state = RETURNED_SQLSTATE, v_error_msg = MESSAGE_TEXT;
    po_data := result_error('err:internal:db', v_error_msg);
    RETURN;
END;
$BODY$;

GRANT EXECUTE ON PROCEDURE sender.update_submission_status(jsonb, jsonb) TO edim;
REVOKE ALL ON PROCEDURE sender.update_submission_status(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE sender.update_submission_status IS 'Atjauno sūtījuma statusu';