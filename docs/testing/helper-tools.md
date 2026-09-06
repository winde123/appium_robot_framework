# Helper tools and utility scripts

This page documents the small helper library and exploratory scripts that
support the Robot test suite.

- `Resources/helper_func.py` — string/date helpers exposed as Robot keywords.
- `tools/examples/generate_qr_code.py` — QR-code image generator.
- `tools/examples/qr_date_validator.py` — QR-code validity-date calculator.

## `Resources/helper_func.py`

Imported as a Robot library.  Function names are the keyword names, so they
must stay stable.

| Keyword | Contract | Notes |
|---|---|---|
| `Remove Whitespaces` | `string → str` with spaces removed | Coerces `string` to `str`; original parameter name preserved. |
| `Reverse List Elements` | reverses list **in place** and returns it | Mutates the original object. |
| `Masking String` | keeps only index 5 onward, prefixed by `*****` | Requires at least 6 characters. |
| `String Splitter` | splits string into chunks of length `chars` | `chars` must be a positive integer; rejects `Decimal("1.5")`, `Fraction(3,2)`, non-finite floats, etc. |
| `Add Space Between String` | inserts one space between each character and strips edges | Coerces input to `str`; `" a "` becomes `"a"`. |
| `Convert Int To Secs` | returns `datetime.timedelta(seconds=numsecs)` | Fractional seconds preserved; return type unchanged. |
| `Date Field Formatter` | validates `dd/mm/yyyy` and formats as `dd / mm / yyyy` | Rejects invalid calendar dates such as `31/02/2026`. |
| `Current Date Generator` | returns today's date as `dd/mm/yyyy` | |

### Boundary validation

- `String Splitter` raises `ValueError` for zero, negative, or non-integral
  chunk sizes (e.g. `2.5`, strings that cannot be parsed as integers).
- `Date Field Formatter` raises `ValueError` for missing values, wrong formats,
  and impossible calendar dates.
- `Masking String` raises `ValueError` for strings shorter than six characters.

### Running the unit tests

```sh
/Users/edwinwan/Documents/Projects/appium_robot_framework/venv/bin/python \
  -B -m pytest -q -p no:cacheprovider tests/unit/test_helper_func.py
```

## QR-code helper (`tools/examples/generate_qr_code.py`)

A reusable wrapper around the optional `treepoem` package.  It is import-safe:
`treepoem` is loaded only when a generation function or the CLI is invoked.

### Optional requirements

```sh
pip install -r tools/examples/requirements-qr.txt
```

`treepoem` also needs a working Ghostscript installation on the host.  See the
[`treepoem` documentation](https://pypi.org/project/treepoem/) for platform
setup instructions.

### CLI

```sh
python tools/examples/generate_qr_code.py \
  --data "https://example.com" \
  --output Output/qr.gif \
  --eclevel Q
```

### API

```python
from pathlib import Path
from tools.examples.generate_qr_code import generate_qr_code

saved_path = generate_qr_code(
    data="payload",
    output_path="Output/qr.gif",
    barcode_type="qrcode",
    eclevel="Q",
)
assert saved_path == Path("Output/qr.gif").resolve()
```

Returns the absolute :class:`pathlib.Path` of the saved image.  Raises
`RuntimeError` with a clear message if `treepoem` is not installed.

### Compatibility shim

The old exploratory path `Data/test_data/generate_qr_128_test.py` still works
when executed directly; it delegates to the new script.

## QR-date validator (`tools/examples/qr_date_validator.py`)

Replaces the original one-liner that printed `datetime.now() + timedelta(364)`.

### CLI

```sh
python tools/examples/qr_date_validator.py
# 2027-06-05 12:00:00   (example output: 364 days from now)

python tools/examples/qr_date_validator.py --days 30 --from-date "2026-01-01 00:00:00"
# 2026-01-31 00:00:00
```

### API

```python
from datetime import datetime
from tools.examples.qr_date_validator import compute_qr_validity_date, format_qr_date

base = datetime(2026, 1, 1)
valid_until = compute_qr_validity_date(days=364, from_date=base)
print(format_qr_date(valid_until))
```

### Compatibility shim

The old exploratory path `Data/test_data/validateQRdate.py` still works when
executed directly; it delegates to the new script.

## Running all helper-tool unit tests

```sh
/Users/edwinwan/Documents/Projects/appium_robot_framework/venv/bin/python \
  -B -m pytest -q -p no:cacheprovider tests/unit/test_helper_func.py \
  tests/unit/test_example_tools.py
```

These tests mock the barcode backend and file writes; no devices, images, or
network access are required.

---

*Last reviewed: 2026-09-06*
