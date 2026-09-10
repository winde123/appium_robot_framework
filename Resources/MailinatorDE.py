"""Read-only Mailinator → SGAC DE-number bridge for Python and Robot Framework.

No API traffic occurs on import. MAILINATOR_API_TOKEN comes from the environment
or the repository-root .env file; an explicit environment value takes precedence.
See docs/testing/mailinator-de-number.md for the capture/submit/wait/update contract.
"""

from __future__ import annotations

import base64
import binascii
import json
import math
import os
from pathlib import Path
import quopri
import re
import time
from html.parser import HTMLParser
from urllib.error import HTTPError, URLError
from urllib.parse import quote, urlencode
from urllib.request import HTTPRedirectHandler, Request, build_opener

from robot.api.deco import keyword, library
from dotenv import dotenv_values


_API = "https://api.mailinator.com/api/v2"
_DOTENV_PATH = Path(__file__).resolve().parents[1] / ".env"
_VALUE = r"(?=[A-Z0-9-]*\d)[A-Z0-9][A-Z0-9-]{5,29}(?![A-Z0-9-])"
_DE_LABEL = re.compile(
    r"\b(?:D\s*[/.-]?\s*E\.?|Disembarkation\s*[/&-]\s*Embarkation\s*(?:\(D/?E\))?)"
    r"\s*(?:Number|No\.?|#)\s*(?:is\b\s*)?[:：#-]?\s*(" + _VALUE + r")",
    re.IGNORECASE,
)


class MailinatorError(RuntimeError):
    """Sanitized configuration/API error (never includes responses or credentials)."""


class _TransientError(MailinatorError):
    def __init__(self, message, retry_after=0):
        super().__init__(message)
        self.retry_after = retry_after


class _NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        # Never forward the account token to a redirected destination.
        return None


class _HTMLText(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.fragments = []
        self.hidden = 0

    def handle_starttag(self, tag, attrs):
        if tag in {"script", "style"}:
            self.hidden += 1
        if tag in {"br", "p", "div", "tr", "td", "th", "li"}:
            self.fragments.append(" ")

    def handle_endtag(self, tag):
        if tag in {"script", "style"}:
            self.hidden = max(0, self.hidden - 1)
        if tag in {"p", "div", "tr", "td", "th", "li"}:
            self.fragments.append(" ")

    def handle_data(self, data):
        if not self.hidden:
            self.fragments.append(data)


def _message_text(message):
    """Read text MIME parts only; never follow links or inspect attachments."""
    texts = []

    def visit(part):
        if not isinstance(part, dict):
            return
        if not isinstance(part.get("headers", {}), dict) or not isinstance(part.get("parts", []), list):
            raise MailinatorError("Mailinator returned malformed MIME part metadata.")
        headers = {str(k).lower(): str(v) for k, v in part.get("headers", {}).items()}
        if "attachment" in headers.get("content-disposition", "").lower():
            return
        for child in part.get("parts", []):
            visit(child)
        body = part.get("body")
        content_type = str(headers.get("content-type", part.get("type", "text/plain"))).lower()
        if not isinstance(body, str) or not content_type.startswith(("text/plain", "text/html")):
            return
        encoding = headers.get("content-transfer-encoding", "").lower()
        charset = re.search(r'charset=["\']?([\w-]+)', content_type)
        charset = charset.group(1) if charset else "utf-8"
        try:
            if encoding == "base64":
                body = base64.b64decode(re.sub(r"\s+", "", body), validate=True).decode(charset)
            elif encoding == "quoted-printable":
                body = quopri.decodestring(body.encode("utf-8")).decode(charset)
        except (ValueError, LookupError, UnicodeError, binascii.Error):
            raise MailinatorError("Cannot decode a Mailinator text part.") from None
        if content_type.startswith("text/html"):
            parser = _HTMLText()
            parser.feed(body)
            body = "".join(parser.fragments)
        texts.append(body)

    visit(message)
    return " ".join(" ".join(texts).split())


def _extract_de_number(text):
    values = {match.upper() for match in _DE_LABEL.findall(text)}
    if len(values) > 1:
        raise MailinatorError("Multiple DE numbers in the matching email; refusing an ambiguous update.")
    return next(iter(values), None)


def _positive(value, name):
    try:
        result = float(value)
    except (ValueError, TypeError):
        result = 0
    if not math.isfinite(result) or result <= 0:
        raise ValueError(f"{name} must be a positive finite number of seconds.")
    return result


def _valid_timestamp(value):
    return (isinstance(value, (int, float)) and not isinstance(value, bool)
            and math.isfinite(value) and value > 0)


@library(scope="SUITE", auto_keywords=False)
class MailinatorDE:
    def __init__(self):
        self._captures = {}
        self._records = {}
        self._opener = build_opener(_NoRedirect())

    def _get(self, path, params=None, timeout=10):
        token = os.environ.get("MAILINATOR_API_TOKEN")
        if token is None:
            try:
                # Explicit path: never search the CWD/parents or change os.environ.
                # Reload on use so saving the file works without restarting a runner.
                token = dotenv_values(_DOTENV_PATH, interpolate=False, encoding="utf-8-sig").get("MAILINATOR_API_TOKEN")
            except (OSError, UnicodeError):
                raise MailinatorError("Cannot read the repository .env token configuration.") from None
        token = (token or "").strip()
        if not token or any(ord(char) < 33 or ord(char) > 126 for char in token):
            raise MailinatorError("Set a valid MAILINATOR_API_TOKEN in the environment or repository-root .env.")
        url = _API + path + ("?" + urlencode(params) if params else "")
        request = Request(url, headers={"Authorization": token, "Accept": "application/json"})
        try:
            with self._opener.open(request, timeout=timeout) as response:
                raw = response.read(2_000_001)
        except HTTPError as error:
            status = error.code
            retry_after = (error.headers or {}).get("Retry-After", "0")
            error.close()
            if status in {404, 408, 429, 500, 502, 503, 504}:
                delay = float(retry_after) if re.fullmatch(r"\d+", retry_after) else 0
                raise _TransientError(f"Mailinator returned HTTP {status}.", delay) from None
            if status in {401, 403}:
                raise MailinatorError("Mailinator denied API access; check the token, domain and subscription.") from None
            raise MailinatorError(f"Mailinator returned HTTP {status}; redirects are not followed.") from None
        except (URLError, TimeoutError, OSError):
            raise _TransientError("Mailinator request failed or timed out.") from None
        if len(raw) > 2_000_000:
            raise MailinatorError("Mailinator response exceeds the 2 MB safety limit.")
        try:
            payload = json.loads(raw)
        except (ValueError, UnicodeError):
            raise MailinatorError("Mailinator returned invalid JSON.") from None
        if not isinstance(payload, dict):
            raise MailinatorError("Mailinator returned an unexpected response shape.")
        return payload

    def _summaries(self, capture, deadline):
        messages = []
        for page in range(20):
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                raise _TransientError("Mailinator inbox read timed out.")
            payload = self._get(capture["path"],
                                {"skip": page * 50, "limit": 50, "sort": "descending", "decode_subject": "true"},
                                min(10, remaining))
            batch = payload.get("msgs")
            if not isinstance(batch, list) or any(not isinstance(m, dict) or not isinstance(m.get("id"), str) or not m["id"] for m in batch):
                raise MailinatorError("Mailinator inbox response must contain message summaries with IDs.")
            messages.extend(batch)
            if len(batch) < 50:
                return messages
        raise MailinatorError("Inbox exceeds the 1000-message scan limit; use a dedicated test inbox.")

    @keyword("Start SGAC Email Capture")
    def start_sgac_email_capture(self, submission_key, email_address, expected_text, domain=None):
        """Call BEFORE Submit. Snapshot old IDs and require identifying text in the new email.

        expected_text is a nonempty string or list of strings, e.g. passport and
        arrival date exactly as rendered in the email. All strings must match.
        """
        if not isinstance(submission_key, str) or not submission_key.strip():
            raise ValueError("Use a nonempty, unique submission_key for this run/traveller.")
        self._captures.pop(submission_key, None)
        self._records.pop(submission_key, None)
        address = str(email_address).strip().lower()
        match = re.fullmatch(r"([a-z0-9][a-z0-9._+-]{0,63})@([a-z0-9][a-z0-9.-]*\.[a-z]{2,})", address)
        if not match:
            raise ValueError("Provide one exact Mailinator email address, not a wildcard inbox.")
        inbox, email_domain = match.groups()
        api_domain = str(domain or os.environ.get("MAILINATOR_DOMAIN") or ("public" if email_domain == "mailinator.com" else email_domain)).strip().lower()
        if not re.fullmatch(r"[a-zA-Z0-9][a-zA-Z0-9.-]*", api_domain):
            raise ValueError("Invalid Mailinator API domain.")
        if api_domain.lower() not in {email_domain, "private", "public"}:
            raise ValueError("The API domain must match the recipient domain, or be private/public.")
        if api_domain.lower() == "public" and email_domain != "mailinator.com":
            raise ValueError("Use the exact private domain for non-mailinator.com recipients.")
        tokens = [expected_text] if isinstance(expected_text, str) else expected_text
        if not isinstance(tokens, (list, tuple)) or not tokens or any(not isinstance(t, str) or not t.strip() for t in tokens):
            raise ValueError("expected_text must contain identifying text from this submission.")
        capture = {"email": address, "inbox": inbox, "domain": api_domain,
                   "path": f"/domains/{quote(api_domain, safe='')}/inboxes/{quote(inbox, safe='')}",
                   "tokens": [" ".join(t.split()).casefold() for t in tokens]}
        # A baseline failure stops before the caller submits anything.
        old = self._summaries(capture, time.monotonic() + 30)
        capture["old_ids"] = {m["id"] for m in old}
        capture["started_ms"] = int(time.time() * 1000)
        self._captures[submission_key] = capture

    @keyword("Wait For SGAC DE Number")
    def wait_for_sgac_de_number(self, submission_key, timeout=120, poll_interval=5,
                               subject_contains="SG Arrival Card", sender=None, store_path=None):
        """After successful Submit, poll new matching mail and return/store its DE number.

        HTTP/network failures are sanitized. Timeouts never return a previous DE.
        Optional store_path creates a new, owner-readable JSON file (no overwrite).
        """
        timeout = _positive(timeout, "timeout")
        interval = _positive(poll_interval, "poll_interval")
        capture = self._captures.get(submission_key)
        if capture is None:
            raise MailinatorError("Call Start SGAC Email Capture before submitting this arrival card.")
        self._records.pop(submission_key, None)
        if not isinstance(subject_contains, str) or not subject_contains.strip():
            raise ValueError("subject_contains must identify the expected confirmation email.")
        deadline = time.monotonic() + timeout
        last_issue = "No new email matched the subject, identifying text and DE label."
        while time.monotonic() < deadline:
            delay = interval
            try:
                records = []
                for summary in self._summaries(capture, deadline):
                    received = summary.get("time")
                    if summary["id"] in capture["old_ids"] or not _valid_timestamp(received) or received < capture["started_ms"]:
                        continue
                    if subject_contains.casefold() not in str(summary.get("subject", "")).casefold():
                        continue
                    remaining = deadline - time.monotonic()
                    if remaining <= 0:
                        # Do not select a DE from a partially inspected candidate set.
                        raise _TransientError("Deadline reached before all candidate emails were inspected.")
                    message = self._get(capture["path"] + "/messages/" + quote(str(summary["id"]), safe=""), timeout=min(10, remaining))
                    if message.get("id") != summary["id"]:
                        raise MailinatorError("Mailinator returned a different message ID.")
                    recipient = str(message.get("to", "")).lower()
                    if recipient not in {capture["email"], capture["inbox"]}:
                        continue
                    if sender and str(sender).casefold() not in str(message.get("fromfull", message.get("from", ""))).casefold():
                        continue
                    body = _message_text(message)
                    if not all(re.search(r"(?<!\w)" + re.escape(t) + r"(?!\w)", body.casefold()) for t in capture["tokens"]):
                        continue
                    number = _extract_de_number(body)
                    if number:
                        records.append({"schema_version": 1, "submission_key": submission_key,
                                        "email": capture["email"], "de_number": number,
                                        "message_id": summary["id"], "received_ms": received})
                if len({r["de_number"] for r in records}) > 1:
                    raise MailinatorError("Multiple matching emails contain different DE numbers; narrow the correlation.")
                if records:
                    record = max(records, key=lambda r: r["received_ms"])
                    if store_path:
                        self._save(record, store_path)
                    self._records[submission_key] = record
                    return record["de_number"]
            except _TransientError as error:
                last_issue = str(error)
                delay = max(delay, error.retry_after)
            remaining = deadline - time.monotonic()
            if remaining > 0:
                time.sleep(min(delay, remaining))
        raise TimeoutError(f"Timed out waiting for the SGAC DE email. {last_issue}")

    @staticmethod
    def _save(record, store_path):
        path = Path(store_path)
        path.parent.mkdir(parents=True, exist_ok=True)
        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as stream:
                json.dump(record, stream, indent=2, allow_nan=False)
                stream.write("\n")
        except Exception:
            # Only remove the new file created by this call, never an existing record.
            path.unlink(missing_ok=True)
            raise

    @keyword("Get Stored SGAC DE Number")
    def get_stored_sgac_de_number(self, submission_key):
        """Retrieve only the named submission; there is no global 'latest DE' fallback."""
        if submission_key not in self._records:
            raise MailinatorError("No DE number stored for this submission; capture or load it first.")
        return self._records[submission_key]["de_number"]

    @keyword("Load SGAC DE Number")
    def load_sgac_de_number(self, submission_key, store_path):
        """Load an explicitly selected previous-run record; retain its original key."""
        self._records.pop(submission_key, None)
        try:
            record = json.loads(Path(store_path).read_text(encoding="utf-8"))
        except (ValueError, OSError):
            raise MailinatorError("Cannot read the SGAC DE record file.") from None
        if (not isinstance(record, dict) or record.get("schema_version") != 1
                or record.get("submission_key") != submission_key
                or not isinstance(record.get("de_number"), str)
                or not re.fullmatch(_VALUE, record["de_number"])
                or not _valid_timestamp(record.get("received_ms"))
                or not isinstance(record.get("email"), str)
                or not isinstance(record.get("message_id"), str) or not record["message_id"]):
            raise MailinatorError("Invalid SGAC DE record or mismatched submission key.")
        capture = self._captures.get(submission_key)
        if capture and (record["email"] != capture["email"] or record["received_ms"] < capture["started_ms"]):
            raise MailinatorError("The stored DE record predates or mismatches the active submission.")
        self._records[submission_key] = record
        return record["de_number"]
