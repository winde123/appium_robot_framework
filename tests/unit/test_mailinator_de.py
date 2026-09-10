"""Offline Mailinator/DE tests using synthetic data and a user-supplied dummy email."""

import base64
from io import BytesIO
import json
import os
from pathlib import Path
import time
from urllib.error import HTTPError, URLError
from unittest.mock import Mock

import pytest
import yaml
from robot.api import TestSuite as RobotSuite

from Resources.MailinatorDE import (
    MailinatorDE, MailinatorError, _NoRedirect,
    _TransientError, _extract_de_number, _message_text,
)


EMAIL = "sgac-run-123@team.testinator.com"
IDENTITY = "TESTPASS123"
DE = "000123456789"
ROOT = Path(__file__).resolve().parents[2]


@pytest.fixture(autouse=True)
def isolate_account_environment(monkeypatch, tmp_path):
    monkeypatch.delenv("MAILINATOR_DOMAIN", raising=False)
    monkeypatch.delenv("MAILINATOR_API_TOKEN", raising=False)
    # Never consume the user's actual local token during offline tests.
    monkeypatch.setattr("Resources.MailinatorDE._DOTENV_PATH", tmp_path / "absent.env")


def message(number=DE, identity=IDENTITY, message_id="new-1", **overrides):
    data = {
        "id": message_id, "to": "sgac-run-123", "time": int(time.time() * 1000) + 1000,
        "subject": "SG Arrival Card - Successful Submission", "fromfull": "ICA <uat@example.com>",
        "parts": [{"headers": {"content-type": "text/plain"},
                   "body": f"Passport: {identity}\nDE Number: {number}"}],
    }
    data.update(overrides)
    return data


class Clock:
    def __init__(self):
        self.now = 0
        self.sleeps = []

    def monotonic(self):
        return self.now

    def sleep(self, seconds):
        self.sleeps.append(seconds)
        self.now += seconds


@pytest.fixture
def clock(monkeypatch):
    clock = Clock()
    monkeypatch.setattr("Resources.MailinatorDE.time.monotonic", clock.monotonic)
    monkeypatch.setattr("Resources.MailinatorDE.time.sleep", clock.sleep)
    return clock


def prepare(monkeypatch, old=None):
    client = MailinatorDE()
    monkeypatch.setattr(client, "_get", Mock(return_value={"msgs": old or []}))
    client.start_sgac_email_capture("run-123", EMAIL, IDENTITY)
    return client


def poll_api(monkeypatch, client, messages):
    calls = []

    def get(path, params=None, timeout=10):
        calls.append((path, params, timeout))
        if "/messages/" in path:
            return next(m for m in messages if path.endswith("/" + m["id"]))
        return {"msgs": messages}

    monkeypatch.setattr(client, "_get", get)
    return calls


@pytest.mark.parametrize("label", [
    "DE Number", "DE No.", "D/E Number", "D.E. No.", "DE #",
    "Disembarkation/Embarkation (DE) Number", "Disembarkation/Embarkation Number",
])
def test_label_variants_preserve_leading_zeroes(label):
    assert _extract_de_number(f"{label}: {DE}") == DE


@pytest.mark.parametrize("body", [
    "Tracking ID: 123456789", "Passport: TESTPASS123", "DE Number: pending",
    "DE Number: 123", "DE Number: " + "1" * 31,
])
def test_does_not_guess_unlabelled_invalid_or_tracking_numbers(body):
    assert _extract_de_number(body) is None


def test_html_tables_entities_and_hidden_scripts():
    data = message(parts=[{"headers": {"content-type": "text/html; charset=UTF-8"}, "body":
        f"<style>DE Number: 999999999</style><table><tr><td>D/E&nbsp;Number</td>"
        f"<td><b>{DE}</b></td></tr></table><script>DE Number: 888888888</script>"}])
    assert _extract_de_number(_message_text(data)) == DE


def test_saved_foreigner_acknowledgement_html_extracts_dummy_de():
    data = json.loads((ROOT / "Data/test_data/sgac_foreigner_acknowledgement.json").read_text(encoding="utf-8"))
    assert data["to"] == "sgac-fore"
    assert "Singapore Arrival Card" in data["subject"]
    assert any("text/html" in part["headers"]["content-type"] for part in data["parts"])
    body = _message_text(data)
    assert "TEST ONE" in body
    # The same labelled DE appears in the acknowledgement prose and table.
    assert body.count("X8276T7137") == 2
    assert _extract_de_number(body) == "X8276T7137"


def test_saved_foreigner_acknowledgement_capture_with_actual_subject(monkeypatch):
    data = json.loads((ROOT / "Data/test_data/sgac_foreigner_acknowledgement.json").read_text(encoding="utf-8"))
    client = MailinatorDE()
    monkeypatch.setattr(client, "_get", Mock(return_value={"msgs": []}))
    client.start_sgac_email_capture(
        "fixture-run", "sgac-fore@team380551.testinator.email",
        ["T11949149", "09/09/2026"],
    )
    # Simulate new delivery in memory only; preserve the saved API response unchanged.
    data["time"] = int(time.time() * 1000) + 1000
    poll_api(monkeypatch, client, [data])
    assert client.wait_for_sgac_de_number(
        "fixture-run", subject_contains="Singapore Arrival Card",
    ) == "X8276T7137"
    assert client.get_stored_sgac_de_number("fixture-run") == "X8276T7137"


@pytest.mark.parametrize("encoding", ["base64", "quoted-printable"])
def test_encoded_text(encoding):
    text = f"DE Number: {DE}"
    body = base64.b64encode(text.encode()).decode() if encoding == "base64" else text.replace(" ", "=20")
    data = message(parts=[{"headers": {"content-type": "text/plain", "content-transfer-encoding": encoding}, "body": body}])
    assert _extract_de_number(_message_text(data)) == DE


def test_multipart_deduplicates_same_de_and_ignores_attachments():
    part = message()["parts"][0]
    data = message(parts=[{"parts": [part, part]}, {
        "headers": {"content-type": "text/plain", "content-disposition": "attachment; filename=test.txt"},
        "body": "DE Number: 999999999"}])
    assert _extract_de_number(_message_text(data)) == DE


def test_ambiguous_group_email_is_not_used():
    with pytest.raises(MailinatorError, match="Multiple DE numbers"):
        _extract_de_number(f"DE Number: {DE} DE Number: 999999999")


def test_success_store_reload_and_no_raw_email_or_token(monkeypatch, tmp_path):
    client = prepare(monkeypatch)
    calls = poll_api(monkeypatch, client, [message()])
    path = tmp_path / "private" / "run-123.json"
    assert client.wait_for_sgac_de_number("run-123", store_path=path) == DE
    assert client.get_stored_sgac_de_number("run-123") == DE
    assert MailinatorDE().load_sgac_de_number("run-123", path) == DE
    record = json.loads(path.read_text())
    assert set(record) == {"schema_version", "submission_key", "email", "de_number", "message_id", "received_ms"}
    assert IDENTITY not in path.read_text()
    assert path.stat().st_mode & 0o777 == 0o600
    assert calls[0][0] == "/domains/team.testinator.com/inboxes/sgac-run-123"
    assert calls[1][0].endswith("/messages/new-1")


def test_delayed_delivery(monkeypatch, clock):
    client = prepare(monkeypatch)
    monkeypatch.setattr(client, "_get", Mock(side_effect=[{"msgs": []}, {"msgs": [message()]}, message()]))
    assert client.wait_for_sgac_de_number("run-123", timeout=10, poll_interval=2) == DE
    assert clock.sleeps == [2]


@pytest.mark.parametrize("variant", ["baseline", "old_timestamp", "wrong_subject", "wrong_recipient", "wrong_identity", "identity_substring", "no_de", "missing_timestamp"])
def test_stale_and_unrelated_mail_cannot_supply_de(monkeypatch, clock, variant):
    email = message()
    client = prepare(monkeypatch, old=[email] if variant == "baseline" else [])
    if variant == "old_timestamp":
        email["time"] = 1
    elif variant == "wrong_subject":
        email["subject"] = "Unrelated"
    elif variant == "wrong_recipient":
        email["to"] = "another-inbox"
    elif variant == "wrong_identity":
        email = message(identity="SOMEONEELSE")
    elif variant == "identity_substring":
        email = message(identity="X" + IDENTITY + "99")
    elif variant == "no_de":
        email["parts"][0]["body"] = f"Passport: {IDENTITY} Tracking ID: 123456789"
    elif variant == "missing_timestamp":
        email.pop("time")
    poll_api(monkeypatch, client, [email])
    with pytest.raises(TimeoutError):
        client.wait_for_sgac_de_number("run-123", timeout=3, poll_interval=2)
    with pytest.raises(MailinatorError, match="No DE number"):
        client.get_stored_sgac_de_number("run-123")
    assert clock.sleeps == [2, 1]


def test_all_identity_tokens_and_optional_sender_must_match(monkeypatch, clock):
    client = prepare(monkeypatch)
    monkeypatch.setattr(client, "_get", Mock(return_value={"msgs": []}))
    client.start_sgac_email_capture("run-123", EMAIL, [IDENTITY, "09 Sep 2026"])
    poll_api(monkeypatch, client, [message()])
    with pytest.raises(TimeoutError):
        client.wait_for_sgac_de_number("run-123", timeout=1)
    email = message()
    email["parts"][0]["body"] += " Arrival 09 Sep 2026"
    poll_api(monkeypatch, client, [email])
    with pytest.raises(TimeoutError):
        client.wait_for_sgac_de_number("run-123", timeout=1, sender="different@example.com")
    assert client.wait_for_sgac_de_number("run-123", sender="uat@example.com") == DE


def test_multiple_different_matches_fail_closed(monkeypatch):
    client = prepare(monkeypatch)
    poll_api(monkeypatch, client, [message(), message(number="999999999", message_id="new-2")])
    with pytest.raises(MailinatorError, match="Multiple matching emails"):
        client.wait_for_sgac_de_number("run-123")


def test_deadline_during_scan_never_selects_from_partial_candidates(monkeypatch, clock):
    client = prepare(monkeypatch)
    emails = [message(), message(number="999999999", message_id="new-2")]

    def get(path, params=None, timeout=10):
        if "/messages/" in path:
            clock.now += 4
            return emails[0]
        return {"msgs": emails}

    monkeypatch.setattr(client, "_get", get)
    with pytest.raises(TimeoutError, match="all candidate emails"):
        client.wait_for_sgac_de_number("run-123", timeout=3)
    with pytest.raises(MailinatorError):
        client.get_stored_sgac_de_number("run-123")


def test_two_submission_keys_keep_separate_values(monkeypatch):
    client = prepare(monkeypatch)
    monkeypatch.setattr(client, "_get", Mock(return_value={"msgs": []}))
    client.start_sgac_email_capture("run-456", EMAIL, "OTHERPASS456")
    poll_api(monkeypatch, client, [message(), message(number="999999999", identity="OTHERPASS456", message_id="new-2")])
    assert client.wait_for_sgac_de_number("run-123") == DE
    assert client.wait_for_sgac_de_number("run-456") == "999999999"
    assert client.get_stored_sgac_de_number("run-123") == DE


def test_pagination_reads_next_page(monkeypatch):
    client = prepare(monkeypatch)
    unrelated = [message(message_id=f"other-{i}", subject="Other") for i in range(50)]
    monkeypatch.setattr(client, "_get", Mock(side_effect=[{"msgs": unrelated}, {"msgs": [message()]}, message()]))
    assert client.wait_for_sgac_de_number("run-123") == DE
    assert client._get.call_args_list[1].args[1]["skip"] == 50


def test_retry_after_then_success(monkeypatch, clock):
    client = prepare(monkeypatch)
    monkeypatch.setattr(client, "_get", Mock(side_effect=[_TransientError("HTTP 429", 7), {"msgs": [message()]}, message()]))
    assert client.wait_for_sgac_de_number("run-123", timeout=20, poll_interval=2) == DE
    assert clock.sleeps == [7]


def test_retry_after_is_bounded_by_deadline(monkeypatch, clock):
    client = prepare(monkeypatch)
    monkeypatch.setattr(client, "_get", Mock(side_effect=_TransientError("HTTP 429", 300)))
    with pytest.raises(TimeoutError, match="HTTP 429"):
        client.wait_for_sgac_de_number("run-123", timeout=4)
    assert clock.sleeps == [4]


def test_new_capture_or_failed_wait_clears_previous_value(monkeypatch, clock):
    client = prepare(monkeypatch)
    poll_api(monkeypatch, client, [message()])
    assert client.wait_for_sgac_de_number("run-123") == DE
    monkeypatch.setattr(client, "_get", Mock(return_value={"msgs": []}))
    with pytest.raises(TimeoutError):
        client.wait_for_sgac_de_number("run-123", timeout=1)
    with pytest.raises(MailinatorError):
        client.get_stored_sgac_de_number("run-123")
    with pytest.raises(ValueError):
        client.start_sgac_email_capture("run-123", EMAIL, [])
    with pytest.raises(MailinatorError, match="before submitting"):
        client.wait_for_sgac_de_number("run-123")


@pytest.mark.parametrize("invalid", [0, -1, "nan", "inf", "bad"])
def test_invalid_wait_options_fail_before_network(monkeypatch, invalid):
    client = prepare(monkeypatch)
    with pytest.raises(ValueError):
        client.wait_for_sgac_de_number("run-123", timeout=invalid)
    with pytest.raises(ValueError):
        client.wait_for_sgac_de_number("run-123", poll_interval=invalid)


def test_missing_capture_and_unknown_key_do_not_fall_back():
    client = MailinatorDE()
    with pytest.raises(MailinatorError):
        client.wait_for_sgac_de_number("unknown")
    with pytest.raises(MailinatorError):
        client.get_stored_sgac_de_number("unknown")


def test_no_overwrite_or_wrong_key_load(monkeypatch, tmp_path):
    client = prepare(monkeypatch)
    poll_api(monkeypatch, client, [message()])
    path = tmp_path / "record.json"
    client.wait_for_sgac_de_number("run-123", store_path=path)
    original = path.read_bytes()
    with pytest.raises(FileExistsError):
        client.wait_for_sgac_de_number("run-123", store_path=path)
    assert path.read_bytes() == original
    with pytest.raises(MailinatorError, match="mismatched submission key"):
        client.load_sgac_de_number("other-run", path)


def test_load_rejects_active_capture_older_record(monkeypatch, tmp_path):
    client = prepare(monkeypatch)
    poll_api(monkeypatch, client, [message()])
    path = tmp_path / "record.json"
    client.wait_for_sgac_de_number("run-123", store_path=path)
    client._captures["run-123"]["started_ms"] += 5000
    with pytest.raises(MailinatorError, match="predates"):
        client.load_sgac_de_number("run-123", path)


def test_bad_record_and_missing_file(tmp_path):
    path = tmp_path / "record.json"
    client = MailinatorDE()
    with pytest.raises(MailinatorError, match="Cannot read"):
        client.load_sgac_de_number("run-123", path)
    for value in ["not json", "[]", '{"schema_version": 2}']:
        path.write_text(value)
        with pytest.raises(MailinatorError):
            client.load_sgac_de_number("run-123", path)


@pytest.mark.parametrize("bad_time", [float("nan"), float("inf"), True, -1])
def test_invalid_timestamp_is_never_selected(monkeypatch, clock, bad_time):
    client = prepare(monkeypatch)
    poll_api(monkeypatch, client, [message(time=bad_time)])
    with pytest.raises(TimeoutError):
        client.wait_for_sgac_de_number("run-123", timeout=1)


def test_invalid_mime_and_inbox_schemas(monkeypatch):
    with pytest.raises(MailinatorError, match="MIME"):
        _message_text({"headers": None})
    client = MailinatorDE()
    monkeypatch.setattr(client, "_get", Mock(return_value={"unexpected": []}))
    with pytest.raises(MailinatorError, match="summaries"):
        client.start_sgac_email_capture("run-123", EMAIL, IDENTITY)


def test_inbox_scan_limit_fails_closed(monkeypatch):
    client = MailinatorDE()
    monkeypatch.setattr(client, "_get", Mock(return_value={"msgs": [message(message_id=str(i)) for i in range(50)]}))
    with pytest.raises(MailinatorError, match="1000-message"):
        client.start_sgac_email_capture("run-123", EMAIL, IDENTITY)


def test_auth_failure_is_immediate_not_retried(monkeypatch, clock):
    client = prepare(monkeypatch)
    monkeypatch.setattr(client, "_get", Mock(side_effect=MailinatorError("Mailinator denied API access")))
    with pytest.raises(MailinatorError, match="denied API"):
        client.wait_for_sgac_de_number("run-123")
    assert clock.sleeps == []


def test_response_size_limit(monkeypatch):
    monkeypatch.setenv("MAILINATOR_API_TOKEN", "synthetic-token")
    client = MailinatorDE()
    client._opener.open = Mock(return_value=BytesIO(b"x" * 2_000_001))
    with pytest.raises(MailinatorError, match="2 MB"):
        client._get("/test")


@pytest.mark.parametrize("address", ["*@team.testinator.com", "a/b@team.testinator.com", "", "a@b.com?token=x"])
def test_rejects_wildcard_and_invalid_inbox(address):
    with pytest.raises(ValueError):
        MailinatorDE().start_sgac_email_capture("run-123", address, IDENTITY)


def test_public_and_explicit_private_domains(monkeypatch):
    monkeypatch.delenv("MAILINATOR_DOMAIN", raising=False)
    client = prepare(monkeypatch)
    client.start_sgac_email_capture("public-run", "synthetic123@mailinator.com", IDENTITY)
    assert client._captures["public-run"]["domain"] == "public"
    client.start_sgac_email_capture("private-run", EMAIL, IDENTITY, domain="private")
    assert client._captures["private-run"]["domain"] == "private"
    with pytest.raises(ValueError):
        client.start_sgac_email_capture("wrong-domain", EMAIL, IDENTITY, domain="elsewhere.com")


def test_real_transport_contract_header_token_not_url(monkeypatch):
    token = "synthetic-secret-token"
    monkeypatch.setenv("MAILINATOR_API_TOKEN", token)
    client = MailinatorDE()
    client._opener.open = Mock(return_value=BytesIO(b'{"msgs": []}'))
    assert client._get("/domains/private/inboxes/test", {"limit": 50}, timeout=3) == {"msgs": []}
    request = client._opener.open.call_args.args[0]
    assert request.get_method() == "GET"
    assert request.get_header("Authorization") == token
    assert token not in request.full_url
    assert request.full_url == "https://api.mailinator.com/api/v2/domains/private/inboxes/test?limit=50"
    assert client._opener.open.call_args.kwargs["timeout"] == 3


@pytest.mark.parametrize("value", ["synthetic-token", '"synthetic-token"', "'synthetic-token'"])
def test_dotenv_token_is_loaded_from_explicit_path_not_cwd(monkeypatch, tmp_path, value):
    config = tmp_path / "project.env"
    config.write_text(f"# Local test fixture\nMAILINATOR_API_TOKEN={value}\nUNRELATED_SETTING=ignored\n")
    monkeypatch.setattr("Resources.MailinatorDE._DOTENV_PATH", config)
    elsewhere = tmp_path / "elsewhere"
    elsewhere.mkdir()
    (elsewhere / ".env").write_text("MAILINATOR_API_TOKEN=wrong-cwd-token\n")
    monkeypatch.chdir(elsewhere)
    client = MailinatorDE()
    client._opener.open = Mock(return_value=BytesIO(b'{"msgs": []}'))
    client._get("/test")
    request = client._opener.open.call_args.args[0]
    assert request.get_header("Authorization") == "synthetic-token"
    assert "synthetic-token" not in request.full_url
    assert "MAILINATOR_API_TOKEN" not in os.environ
    assert "UNRELATED_SETTING" not in os.environ


@pytest.mark.parametrize("env_token", ["environment-token", ""])
def test_explicit_environment_value_always_wins(monkeypatch, tmp_path, env_token):
    config = tmp_path / ".env"
    config.write_text("MAILINATOR_API_TOKEN=file-token\n")
    monkeypatch.setattr("Resources.MailinatorDE._DOTENV_PATH", config)
    monkeypatch.setenv("MAILINATOR_API_TOKEN", env_token)
    client = MailinatorDE()
    client._opener.open = Mock(return_value=BytesIO(b'{"msgs": []}'))
    if env_token:
        client._get("/test")
        assert client._opener.open.call_args.args[0].get_header("Authorization") == env_token
    else:
        with pytest.raises(MailinatorError, match="MAILINATOR_API_TOKEN"):
            client._get("/test")
        client._opener.open.assert_not_called()


def test_dotenv_value_is_literal_and_reloaded_on_next_request(monkeypatch, tmp_path):
    config = tmp_path / ".env"
    config.write_text("MAILINATOR_API_TOKEN='literal-${NOT_EXPANDED}'\n")
    monkeypatch.setattr("Resources.MailinatorDE._DOTENV_PATH", config)
    monkeypatch.setenv("NOT_EXPANDED", "must-not-substitute")
    client = MailinatorDE()
    client._opener.open = Mock(side_effect=lambda *a, **kw: BytesIO(b'{}'))
    client._get("/test")
    assert client._opener.open.call_args.args[0].get_header("Authorization") == "literal-${NOT_EXPANDED}"
    config.write_text("MAILINATOR_API_TOKEN=replacement-token\n")
    client._get("/test")
    assert client._opener.open.call_args.args[0].get_header("Authorization") == "replacement-token"


@pytest.mark.parametrize("contents", ["", "MAILINATOR_API_TOKEN=", "MAILINATOR_API_TOKEN", 'MAILINATOR_API_TOKEN="line1\\nline2"', "MAILINATOR_API_TOKEN=nonascii-é", "MAILINATOR_API_TOKEN=internal space"])
def test_empty_or_multiline_dotenv_token_fails_without_network(monkeypatch, tmp_path, contents):
    config = tmp_path / ".env"
    config.write_text(contents)
    monkeypatch.setattr("Resources.MailinatorDE._DOTENV_PATH", config)
    client = MailinatorDE()
    client._opener.open = Mock()
    with pytest.raises(MailinatorError, match="MAILINATOR_API_TOKEN"):
        client._get("/test")
    client._opener.open.assert_not_called()


def test_dotenv_read_error_is_sanitized(monkeypatch):
    monkeypatch.setattr("Resources.MailinatorDE.dotenv_values", Mock(side_effect=OSError("private-secret-details")))
    with pytest.raises(MailinatorError, match="Cannot read") as caught:
        MailinatorDE()._get("/test")
    assert "private-secret" not in str(caught.value)


@pytest.mark.parametrize("status", [401, 403, 302, 400, 404, 429, 503])
def test_http_errors_do_not_leak_token_or_body(monkeypatch, status):
    monkeypatch.setenv("MAILINATOR_API_TOKEN", "secret-test-token")
    client = MailinatorDE()
    error = HTTPError("https://example.com/secret-test-token", status, "secret-body", {"Retry-After": "5"}, BytesIO(b"secret-body"))
    client._opener.open = Mock(side_effect=error)
    with pytest.raises(MailinatorError) as caught:
        client._get("/test")
    assert "secret" not in str(caught.value)
    if status in {404, 429, 503}:
        assert caught.value.retry_after == 5
    assert _NoRedirect().redirect_request(None, None, 302, "", {}, "https://other.example") is None


def test_missing_credentials_invalid_json_and_network_error(monkeypatch):
    monkeypatch.delenv("MAILINATOR_API_TOKEN", raising=False)
    client = MailinatorDE()
    with pytest.raises(MailinatorError, match="MAILINATOR_API_TOKEN"):
        client._get("/test")
    monkeypatch.setenv("MAILINATOR_API_TOKEN", "synthetic-token")
    client._opener.open = Mock(return_value=BytesIO(b"<html>server error private-body</html>"))
    with pytest.raises(MailinatorError, match="invalid JSON"):
        client._get("/test")
    client._opener.open = Mock(side_effect=URLError("secret-network-details"))
    with pytest.raises(_TransientError, match="request failed") as caught:
        client._get("/test")
    assert "secret" not in str(caught.value)


def test_robot_capture_to_update_round_trip(monkeypatch, tmp_path):
    """Execute actual shared Robot keywords with mocked HTTP, not a dry run."""
    monkeypatch.setenv("MAILINATOR_API_TOKEN", "robot-synthetic-token")
    monkeypatch.delenv("MAILINATOR_DOMAIN", raising=False)
    email = message()
    responses = iter([{"msgs": []}, {"msgs": [email]}, email])

    def open_mock(self, request, timeout):
        return BytesIO(json.dumps(next(responses)).encode())

    monkeypatch.setattr("urllib.request.OpenerDirector.open", open_mock)
    suite = RobotSuite.from_string(f"""*** Settings ***
Resource    {ROOT}/Resources/sgac_email.robot

*** Test Cases ***
Submission Email Supplies DE To Update Flow
    Prepare Foreigner SGAC Email Capture    run-123    {EMAIL}    {IDENTITY}
    ${{de}}=    Capture Foreigner SGAC DE Number    run-123    store_path={tmp_path}/de.json
    Should Be Equal    ${{de}}    {DE}
    Should Be Equal    ${{SGAC_DE_NUMBER}}    {DE}
    ${{update_de}}=    Get Foreigner SGAC DE Number For Update    run-123
    Should Be Equal    ${{update_de}}    {DE}

New Test Loads The Same Submission For Update
    ${{update_de}}=    Get Foreigner SGAC DE Number For Update    run-123    {tmp_path}/de.json
    Should Be Equal    ${{update_de}}    {DE}
    Should Be Equal    ${{SGAC_DE_NUMBER}}    {DE}

Failed Load Clears The Test Scoped Value
    Set Test Variable    ${{SGAC_DE_NUMBER}}    stale-number
    Run Keyword And Expect Error    *mismatched submission key*
    ...    Get Foreigner SGAC DE Number For Update    wrong-run    {tmp_path}/de.json
    Should Be Equal    ${{SGAC_DE_NUMBER}}    ${{NONE}}
""")
    result = suite.run(outputdir=str(tmp_path), log=None, report=None)
    assert result.return_code == 0
    output = (tmp_path / "output.xml").read_text()
    assert "robot-synthetic-token" not in output


@pytest.mark.parametrize("variable,inbox", [
    ("SGAC_RESIDENT_SUBMISSION_EMAIL", "sgac-res"),
    ("SGAC_FOREIGNER_SUBMISSION_EMAIL", "sgac-fore"),
    ("CARGO_SUBMISSION_EMAIL", "cargo"),
])
def test_configured_submission_addresses_route_to_correct_inbox(monkeypatch, variable, inbox):
    config = yaml.safe_load((ROOT / "Data/test_data/submission_email.yaml").read_text())
    assert set(config) == {"MAILINATOR_TEST_DOMAIN", "SGAC_RESIDENT_SUBMISSION_EMAIL",
                           "SGAC_FOREIGNER_SUBMISSION_EMAIL", "CARGO_SUBMISSION_EMAIL"}
    assert config["MAILINATOR_TEST_DOMAIN"] == "team380551.testinator.email"
    assert config[variable] == f"{inbox}@team380551.testinator.email"
    client = MailinatorDE()
    client._get = Mock(return_value={"msgs": []})
    client.start_sgac_email_capture("configured-run", config[variable], IDENTITY)
    assert client._get.call_args.args[0] == f"/domains/team380551.testinator.email/inboxes/{inbox}"


def test_robot_resource_exposes_configured_submission_addresses(tmp_path):
    suite = RobotSuite.from_string(f"""*** Settings ***
Resource    {ROOT}/Resources/sgac_email.robot

*** Test Cases ***
Approved Module Inboxes Are Available Without Credentials
    Should Be Equal    ${{MAILINATOR_TEST_DOMAIN}}    team380551.testinator.email
    Should Be Equal    ${{SGAC_RESIDENT_SUBMISSION_EMAIL}}    sgac-res@team380551.testinator.email
    Should Be Equal    ${{SGAC_FOREIGNER_SUBMISSION_EMAIL}}    sgac-fore@team380551.testinator.email
    Should Be Equal    ${{CARGO_SUBMISSION_EMAIL}}    cargo@team380551.testinator.email
""")
    result = suite.run(outputdir=str(tmp_path), log=None, report=None)
    assert result.return_code == 0
