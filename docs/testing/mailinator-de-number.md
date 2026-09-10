# Mailinator DE-number capture for foreigner SGAC updates

Last reviewed: 2026-09-10

## Implementation and scope

[`Resources/MailinatorDE.py`](../../Resources/MailinatorDE.py) reads the confirmation
email and retains its DE number under an explicit submission key.
[`Resources/sgac_email.robot`](../../Resources/sgac_email.robot) exposes shared
keywords for either mobile platform. It returns the DE and sets the test-scoped
`${SGAC_DE_NUMBER}` for the update form. `python-dotenv` is pinned in requirements
for persistent local token loading.

This implements the email-to-update handoff, not a new native foreigner submission
suite. The current iOS foreigner suite covers profile creation, not submission/update;
its UI locators and flows are unchanged. Offline tests execute the real Robot helper
keywords with mocked HTTP. Live inbox/message reads and DE parsing of Edwin's
dummy acknowledgement email are now verified; a fresh app submission-to-email-to-update
round trip remains unverified.

## Account configuration

For persistent local setup, open the repository-root `.env` file and paste the token
after `=` on this line, then save:

```dotenv
MAILINATOR_API_TOKEN=
```

The local file has owner-only read/write permissions (`0600`) and is ignored by Git.
It stores the token as plain text, not encrypted; do not share, upload or force-add
it to Git. A blank [`.env.example`](../../.env.example) is available for new checkouts:
copy it to `.env`, set `chmod 600 .env`, and fill the token locally.

The Mailinator helper reads ONLY the root `.env` selected relative to its own source,
independent of the working directory. It reads on API use, not import, and reloads
the token on each request so saving the file does not require restarting the runner.
It does not source shell commands, expand `${VARIABLE}` expressions, or copy values
into the global process environment. Only `MAILINATOR_API_TOKEN` is consumed from
the file; domain/inbox configuration remains separate below.

An explicitly set `MAILINATOR_API_TOKEN` environment variable takes precedence over
the file, including an empty value. Remove a stale export with
`unset MAILINATOR_API_TOKEN` in the launching shell and restart that runner if needed
to use the file instead. Do not put tokens in Robot variables, `robotconfig.yaml`,
command arguments, committed files, logs or chat.

CI/temporary setup can still use an environment secret or this masked zsh prompt:

```zsh
read -rs 'MAILINATOR_API_TOKEN?Mailinator API token: '
export MAILINATOR_API_TOKEN
```

The prompt does not echo the token or put its value in shell history. When using
environment variables, start the runner from that shell; already-running processes
do not inherit later exports. Never diagnose credentials by printing their values.
The file loader uses [python-dotenv's non-mutating parser](https://github.com/theskumar/python-dotenv#load-configuration-without-altering-the-environment).

Edwin supplied these UAT inboxes, stored in
[`Data/test_data/submission_email.yaml`](../../Data/test_data/submission_email.yaml):

| Module | Robot variable | Submission email |
| --- | --- | --- |
| SGAC resident | `${SGAC_RESIDENT_SUBMISSION_EMAIL}` | `sgac-res@team380551.testinator.email` |
| SGAC foreigner | `${SGAC_FOREIGNER_SUBMISSION_EMAIL}` | `sgac-fore@team380551.testinator.email` |
| Cargo | `${CARGO_SUBMISSION_EMAIL}` | `cargo@team380551.testinator.email` |

The shared resource imports these variables automatically, including
`${MAILINATOR_TEST_DOMAIN}` = `team380551.testinator.email`. Other suites can import
the YAML directly after `fork_config.py`. This provides explicit submission inputs;
it does not silently change generated profile emails, existing device profiles or
past server submissions. Put the selected module address in the actual submitted
form/profile and use the same address for email capture.

These are shared module inboxes, so retain the mandatory per-submission identifying
text and unique submission keys. Avoid concurrent submissions for the same traveller
and arrival date. Mailinator cannot recover mail already sent to `example.com`
simply because an account is configured later.

- API domain defaults to the email domain; `@mailinator.com` maps to `public`.
- Optional `MAILINATOR_DOMAIN` or the capture keyword's `domain` argument overrides
  it. Use the actual recipient domain or Mailinator's `private` alias.
- Wildcard/all-domain inbox reads are rejected. Prefer the account's private domain;
  public inboxes have no privacy. Use synthetic identities only.

The account needs API access under its subscription. Authentication uses the team
token in the `Authorization` header, never the URL. Only these GET endpoints are used:

```text
https://api.mailinator.com/api/v2/domains/{domain}/inboxes/{inbox}
https://api.mailinator.com/api/v2/domains/{domain}/inboxes/{inbox}/messages/{id}
```

Sources: [Mailinator authentication reference](https://www.mailinator.com/documentation/docs/api/mailinator-api/)
and [message API/subscription documentation](https://www.mailinator.com/docs/index.html#message-api).
Redirects are rejected to avoid forwarding the token to another destination.

## Robot integration

Import `Resources/sgac_email.robot` alongside the platform's UI resources. Use a
unique `submission_key` per run/traveller and retain it with the original identity
and arrival details. There is no global "latest DE" fallback.

For the configured foreigner inbox, call:

```robotframework
Prepare Foreigner SGAC Email Capture    ${submission_key}
...    ${SGAC_FOREIGNER_SUBMISSION_EMAIL}    ${matching_text}
...    domain=${MAILINATOR_TEST_DOMAIN}
```

Use `${SGAC_FOREIGNER_SUBMISSION_EMAIL}` when filling the foreigner submission's
email field too. The resident/cargo variables are inputs for their respective forms;
the DE parser is for the foreigner update workflow, not cargo ARN extraction.

1. Fill the SGAC form with the Mailinator email and reach Review.
2. Prepare email capture immediately BEFORE the Submit action.
3. Submit once and verify a successful acknowledgement through the existing UI flow.
4. Capture the DE from the matching email, optionally saving a JSON record.
5. Open the foreigner update form and retrieve the DE with the SAME submission key.

Integration example, with locator arguments supplied by the verified platform flow:

```robotframework
*** Settings ***
Variables    ../../Resources/fork_config.py
Resource     ../../Resources/sgac_email.robot
Resource     ../../Resources/commands.robot

*** Keywords ***
Submit Reviewed Foreigner Card And Capture DE
    [Arguments]    ${submission_key}    ${email}    ${matching_text}
    ...    ${submit_locator}    ${receipt_locator}
    Prepare Foreigner SGAC Email Capture    ${submission_key}    ${email}    ${matching_text}
    Click on element    ${submit_locator}
    Expect Element    ${receipt_locator}    visible
    ${de}=    Capture Foreigner SGAC DE Number    ${submission_key}
    ...    store_path=${OUTPUT DIR}/${submission_key}-de.json
    ...    timeout=120    poll_interval=5    subject_contains=Singapore Arrival Card
    RETURN    ${de}

Fill DE On The Foreigner Update Form
    [Arguments]    ${submission_key}    ${de_field_locator}
    ${de}=    Get Foreigner SGAC DE Number For Update    ${submission_key}
    Type text    ${de_field_locator}    ${de}
```

`${matching_text}` must identify this submission in the email BODY: a passport number,
or a Robot list of passport and arrival date in the email's actual format. Every
supplied value must match whole-token text, ignoring case and repeated whitespace.
Do not use generic text such as "successful submission" as the identity match.
If ICA masks the passport or uses a tracking reference, use identifying text actually
present in that template. Confirm against a redacted sample before a live run.

`subject_contains` still defaults to `SG Arrival Card`. The saved real-template fixture
uses `Singapore Arrival Card`, which does **not** match that default; explicitly pass
`subject_contains=Singapore Arrival Card` for this template, as in the examples here.
Optional `sender` narrows by case-insensitive sender text. That is filtering, not
cryptographic sender authentication. Multiple DEs in a group email fail instead of
guessing which traveller they belong to.

Load an explicitly selected saved record in a subsequent Robot process:

```robotframework
${de}=    Get Foreigner SGAC DE Number For Update    run-123
...    ${EXECDIR}/Output/run-123-de.json
```

The file's submission key must match. If an active capture exists, a record predating
it or belonging to a different email is rejected. Prepare/capture/load attempts clear
the wrapper's prior `${SGAC_DE_NUMBER}` before doing work; errors leave it `${NONE}`.

## Python usage

```python
from Resources.MailinatorDE import MailinatorDE

mail = MailinatorDE()
mail.start_sgac_email_capture(
    "run-123", "sgac-fore@team380551.testinator.email",
    expected_text=["TESTPASS123", "09/09/2026"],
)
# Now submit once through the app and verify its successful acknowledgement.
de = mail.wait_for_sgac_de_number(
    "run-123", timeout=120, poll_interval=5, subject_contains="Singapore Arrival Card",
    store_path="Output/run-123-de.json",
)
update_de = mail.get_stored_sgac_de_number("run-123")
# Or, in a later process, explicitly select the saved submission:
update_de = MailinatorDE().load_sgac_de_number("run-123", "Output/run-123-de.json")
```

## Safeguards and limitations

- Optional `store_path` creates a NEW owner-only (`0600`) JSON file containing schema
  version, submission key, email, DE string, message ID and received timestamp. Existing
  files are never overwritten. Use a new run path under gitignored `Output/`.
- Files are not encrypted. They omit the token, passport, full email and attachments,
  but the retained email/DE remain sensitive artifacts. Robot normally logs arguments
  and return values, including the DE/correlation text: restrict artifact access.
- Capture snapshots old inbox IDs; polling additionally requires a received timestamp
  at/after capture and matching subject, recipient and identifying text. Keep the test
  machine clock synchronized. No email is deleted.
- Reads paginate at 50 messages/page with a 20-page cap. Oversized inboxes fail with
  guidance to use a dedicated inbox, rather than selecting from incomplete history.
- Plain-text, HTML and nested MIME text parts, base64 and quoted-printable are supported.
  Scripts/styles and attachments are ignored. DE must follow a DE-number label; current
  candidates are 6–30 alphanumeric/hyphen characters with at least one digit. Leading
  zeros are preserved. This is a provisional parser, not an official ICA format claim;
  the sample test DEs are synthetic. Tracking IDs are not substituted for DEs.
- Different DEs in one matched email or the current matching email set fail as ambiguous.
  A timeout never returns an old DE or resubmits the arrival card.
- 401/403 fail immediately. Network failures and transient 404/408/429/5xx responses
  retry within the polling budget; numeric `Retry-After` is respected. Invalid JSON,
  malformed metadata, redirects and responses over 2 MB fail without logging their body.
- Defaults: 120-second poll budget, 5-second interval and up to 10 seconds per HTTP
  socket operation. Baseline capture has a 30-second budget. These are synchronous
  socket/polling limits, not hard cancellation of DNS/OS/network operations.
- The helper does not delete emails, follow email links, download attachments, change
  mailbox rules, submit SGACs or interact with native UI.

## Saved dummy email fixture

[`Data/test_data/sgac_foreigner_acknowledgement.json`](../../Data/test_data/sgac_foreigner_acknowledgement.json)
contains the full parsed Mailinator message response, pretty-printed as JSON, including
API metadata, headers and the original HTML part. It was fetched read-only from
`sgac-fore@team380551.testinator.email`, message ID `sgac-fore-1788946522-096396023`.
Edwin supplied the template with dummy traveller values for analysis. No message was
deleted or altered, no email links/images were opened, and no API token is included.

The subject is `[Auto-Acknowledgement] Singapore Arrival Card (SGAC) - Acknowledgement
of Arrival Information & Health Declaration submission`. The HTML labels the same
dummy DE, `X8276T7137`, in both prose and the declaration table. The existing parser
extracts and deduplicates it without changes. The synthetic traveller is `TEST ONE`;
the matching passport/date values appear in the body. Offline fixture tests cover
HTML extraction and mocked capture using the explicit subject filter above.

This is an **email-response fixture**, not a helper-generated per-submission DE record:
do not pass it to `load_sgac_de_number`. Its dummy identity is not the earlier iOS
visitor regression record, and its DE must not be substituted for that visitor's DE.
The saved email is historical; production polling correctly excludes emails already
present when capture starts. The fixture test simulates fresh delivery only in memory.

## Validation and next live check

```sh
venv/bin/python -B -m pytest tests/unit/test_mailinator_de.py -q -p no:cacheprovider
venv/bin/python -B tools/check_fork_parity.py
```

Tests mock HTTP/delivery and execute the real Robot capture/store/load handoff; they
do not establish native iOS update success. Separately, the user-populated local token
authenticated live inbox reads, and the dummy message above was fetched and parsed
successfully. No fresh SGAC submission or native update was made for fixture capture;
WDA remains stopped at the user's request. Use matching synthetic identity details
and the explicit subject filter for the next approved UAT run. The previous visitor
regression sent to `example.com`, so this helper
cannot recover that record's email from a newly chosen Mailinator inbox.

Validation including the saved email fixture, configured inboxes and persistent `.env`:
86 helper tests passed; the full unit suite passed 251 tests.
Fork parity reported 0 errors and 0 warnings. See the
[completed implementation task](../../todo/done/mailinator-sgac-de-helper.md).
