# Test data utilities

This document covers the shared test-data plumbing in `Data/test_data/`.

Last reviewed: 2026-09-06

## Files

| File | Purpose |
|------|---------|
| `Data/test_data/manual_field_random.py` | Seeded profile/identity generators (Robot **Library** only; it is no longer imported as a `Variables` file) |
| `Data/test_data/cargo_data.py` | Repository-anchored cargo permit file loader |
| `Cargo_Test_Data.txt` | Default cargo permit data file (repository root) |
| `tests/unit/test_manual_field_random.py` | Unit tests for seeded profile records and Robot keyword execution |
| `tests/unit/test_cargo_data.py` | Unit tests for cargo file loading |

## Cargo permit loading (`cargo_data.py`)

`load_cargo_permits(path=None, *, min_count=None)` reads a UTF-8 text file
(stripping UTF-8 BOMs and skipping blank/whitespace-only lines) and returns a
list of permit strings.

```python
from Data.test_data import cargo_data

# Default: repo-root Cargo_Test_Data.txt
permits = cargo_data.load_cargo_permits()

# Explicit path
permits = cargo_data.load_cargo_permits("/tmp/permits.txt")

# Fail early if fewer than 100 permits are available
cargo_data.load_cargo_permits(min_count=100)
```

The legacy `manual_field_random.readfromfile()` compatibility wrapper still
returns the default permit list, but now enforces a 100-permit minimum so the
Android 100-permit cargo test fails loudly instead of indexing past the end of
the file.

## Profile records (`manual_field_random.py`)

The module previously generated fixed module-level constants (`${NRIC}`,
`${NAME}`, `${DOB}`, etc.) at import time.  It now exposes a seeded factory
that returns a full profile record per test, while keeping the old single-field
keyword APIs callable for backwards compatibility.

> **Note:** `manual_field_random.py` is now a Robot **Library** only.  Do not
> import it with `Variables`; use the `Generate Profile Record` keyword and
> extract the fields you need.

### Generating a profile record

```robotframework
Library     ../../../Data/test_data/manual_field_random.py

*** Test Cases ***
User creates profile
    ${PROFILE}=    manual_field_random.Generate Profile Record
    Type text    ${RES-NAME-INPUT}    ${PROFILE}[name]
    Type text    ${RES-NRIC-INPUT}    ${PROFILE}[nric]
```

The returned dictionary contains:

| Key | Example | Notes |
|-----|---------|-------|
| `name` | `SEAN PETERSON` | Upper-cased, dots replaced with spaces |
| `nric` | `S0357448B` | Valid NRIC checksum |
| `dob` | `07/07/1980` | `dd/mm/yyyy` |
| `pp_num` | `K5013222K` | Valid Singapore passport checksum |
| `pp_expiry` | `30/08/2028` | Relative to `reference_date` |
| `foreign_pp_num` | `013222161` | Faker passport number |
| `country` | `SG` / `` | Resident context; `SG` forces `cty_code=65` |
| `cty_code` | `65` / `90` | `65` for SG, otherwise 1-998 |
| `phno` | `7453368` | 7-digit integer |
| `email` | `NATHAN_GREEN@test.co` | Derived from a random name |
| `seed` | `1448430812` | Replay seed (integer) |
| `reference_date` | `2026-09-06` | ISO date used for relative expiry |

`Generate Profile Record` accepts optional arguments and validates their types:

```robotframework
${PROFILE}=    manual_field_random.Generate Profile Record
...    seed=12345
...    reference_date=2024-06-01
...    country=SG
```

The same `seed` + `reference_date` + `country` combination always produces the
same record **when the same Faker version and locale are used**.  The keyword
logs only the seed, reference date and country at Robot level.  Note that normal
Robot argument/return logs may still contain the synthetic data values, so do
not treat the record as private data.

### Replaying a record in Python

```python
from Data.test_data.manual_field_random import generate_profile_record

record = generate_profile_record(seed=12345, reference_date="2024-06-01", country="SG")
# Re-run with the same parameters (and same Faker version/locale) to get
# identical values.
rebuilt = generate_profile_record(
    seed=record["seed"],
    reference_date=record["reference_date"],
    country=record["country"],
)
assert rebuilt == record
```

`seed` may be an `int` or a numeric string (but not `bool`).  `reference_date`
may be a `datetime.date` or an ISO date string (`YYYY-MM-DD`); `datetime`
objects are rejected to avoid time-of-day leaking into the metadata.  `country`
is a string and is normalised to uppercase.  Invalid values raise clear
`TypeError`/`ValueError` exceptions so the metadata always roundtrips.

### Backwards-compatible keywords

All old single-field and list generators remain available as Robot keywords:

- `Generate Random Cty Code`
- `Generate Random Ph No`
- `Generate Random Name`
- `Generate Random Email`
- `Generaterandom DOB`
- `Generate PP Date Exp`
- `Generaterandom NRIC`
- `Generaterandom PP Number`
- `Generaterandom Car Plate Number`
- `Generate Foreign Passport Num`
- `Generatelistof DOBS`
- `Generatelistof Names`
- `Generatelistof NRIC`
- `Generate Listof PP Num`
- `Generate Listof Vehno`
- `Generate Listof Permit`
- `Readfromfile`

These no-argument entry points create an independent factory internally, so they
do not rely on the old module-level constants and do not perturb the global
Python/Faker random generators.

## Profile-record flow boundary

`Create resident profile manually` in both
`Resources/android/SGACcommands.robot` and `Resources/ios/SGACcommands.robot`
now accepts an optional profile record and **returns** the record it used.

```robotframework
# No-arg: keyword generates a fresh resident record with country=SG and returns it.
${PROFILE}=    Create resident profile manually

# The returned record is exactly reproducible from its metadata.
${REBUILT}=    manual_field_random.Generate Profile Record
...    seed=${PROFILE}[seed]
...    reference_date=${PROFILE}[reference_date]
...    country=${PROFILE}[country]
Should Be Equal    ${REBUILT}    ${PROFILE}

# Supply your own record: keyword uses it as-is and returns it.
${PROFILE}=    manual_field_random.Generate Profile Record    country=SG
${USED}=    Create resident profile manually    ${PROFILE}
Should Be Equal    ${USED}    ${PROFILE}
```

This makes the profile data available for downstream assertions and replay
without leaking unseeded per-field generation.

## Migration guide

Old style (module-level constants imported via `Variables`):

```robotframework
Variables    ../../../Data/test_data/manual_field_random.py

*** Test Cases ***
User creates profile
    Type text    ${RES-NAME-INPUT}    ${NAME}
```

New style (explicit per-test record):

```robotframework
Library     ../../../Data/test_data/manual_field_random.py

*** Test Cases ***
User creates profile
    ${PROFILE}=    manual_field_random.Generate Profile Record
    Set Test Variable    ${NAME}    ${PROFILE}[name]
    Type text    ${RES-NAME-INPUT}    ${NAME}
```

If a test only needs a subset of fields (for example, `${EMAIL}` in the iOS
cargo convoy test), create the record and extract only what is used.

Resource files that previously consumed module-level constants now generate a
record inside the keyword itself.  For example, `Create resident profile manually`
in `Resources/android/SGACcommands.robot` builds a `${PROFILE}` record and uses
its fields directly, so callers do not need to supply profile data.

## Implementation notes

- `_ProfileFactory` seeds a private `random.Random` instance and a private
  `Faker` instance.  This keeps global RNGs untouched and makes per-test data
  reproducible.
- The factory uses a `reference_date` instead of `date.today()` for relative
  expiry dates so that replay works regardless of when the test is run.
- `cargo_data.py` resolves the default permit file relative to the repository
  root, not the current working directory, so tests can be run from any
  directory.
- Internal helpers (`_ProfileFactory`, `_robot_log`) are prefixed so they do not
  become Robot keywords.  `cargo_data` is loaded via `importlib.util` without
  mutating `sys.path`.

## Validation

Run the focused unit tests with the shared interpreter:

```sh
/Users/edwinwan/Documents/Projects/appium_robot_framework/venv/bin/python -B -m pytest -q -p no:cacheprovider tests/unit/test_cargo_data.py tests/unit/test_manual_field_random.py
```

Run Robot dry-runs for both forks:

```sh
APP_FORK=sgac1 /Users/edwinwan/Documents/Projects/appium_robot_framework/venv/bin/python -B -m robot --dryrun --output NONE --log NONE --report NONE tests
APP_FORK=sgac2 /Users/edwinwan/Documents/Projects/appium_robot_framework/venv/bin/python -B -m robot --dryrun --output NONE --log NONE --report NONE tests
```

Both forks should report 66 tests passed.  `tools/check_fork_parity.py --strict`
reports 0 errors and 0 warnings on the integrated baseline; intentional fork
divergences are suppressed by the repository allowlist and are unrelated to
this work.
