-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE PROCEDURE sender.save_submission_data(
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
BEGIN
  v_data := pi_data;

  v_submission.content := v_data -> 'content';
  v_submission.sender_from := v_data -> 'from';
  v_submission.subject := v_data ->> 'subject';
  v_submission.message_id := NULLIF(trim((v_data ->> 'messageId')), '');
  v_submission.submit_to := NULLIF(trim((v_data ->> 'to')), '');
  v_submission.status := COALESCE((NULLIF(trim((v_data ->> 'status')), '')), 'new');
  v_submission.info := NULLIF(trim((v_data ->> 'info')), '');

  INSERT INTO sender.submission (content, sender_from, subject, status, info, submit_to)
  VALUES (v_submission.content, v_submission.sender_from, v_submission.subject, v_submission.status, v_submission.info, v_submission.submit_to)
  RETURNING id INTO v_submission.id;

  po_data := result_success(json_build_object('trackingId', v_submission.id));
EXCEPTION
  WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error_state = RETURNED_SQLSTATE, v_error_msg = MESSAGE_TEXT;
    po_data := result_error('err:internal:db', v_error_msg);
    RETURN;
END;
$BODY$;

GRANT EXECUTE ON PROCEDURE sender.save_submission_data(jsonb, jsonb) TO edim;
REVOKE ALL ON PROCEDURE sender.save_submission_data(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE sender.save_submission_data IS 'Saglabā sūtījuma datus';