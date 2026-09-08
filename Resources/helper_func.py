"""Small string/date helpers used as a Robot Framework library.

All public functions are exposed as Robot keywords.  Function names are
intentionally preserved as the public keyword contract; only docstrings,
input validation and internal clarity have been tightened.

Contracts
---------
remove_whitespaces(string) -> str
    Coerce ``string`` to ``str`` and return it with every space removed.

reverse_list_elements(input_list) -> list
    Reverse ``input_list`` **in place** and return the same object.

masking_string(nric_string) -> str
    Return ``*****`` followed by the substring beginning at index 5.
    The input must contain at least six characters so that masking is
    meaningful.

string_splitter(string, chars) -> list[str]
    Split ``string`` into consecutive chunks of length ``chars``.
    ``chars`` must be a positive integer.

add_space_between_string(string) -> str
    Insert a single space between every character of ``string`` and strip
    leading/trailing whitespace.  Non-string inputs are coerced to strings
    for compatibility with phone-number variables that may arrive as numbers.

convert_int_to_secs(numsecs) -> datetime.timedelta
    Return a ``timedelta`` representing ``numsecs`` seconds.  Fractional
    seconds are preserved.

date_field_formatter(datestr) -> str
    Validate ``datestr`` as ``dd/mm/yyyy`` and a real calendar date,
    then return it formatted as ``dd / mm / yyyy``.

current_date_generator() -> str
    Return today's date formatted as ``dd/mm/yyyy``.
"""

import math
from datetime import date, datetime, timedelta
from decimal import Decimal
from fractions import Fraction


def remove_whitespaces(string):
    """Return ``str(string)`` with all space characters removed."""
    return str(string).replace(" ", "")


def reverse_list_elements(input_list):
    """Reverse ``input_list`` in place and return it.

    The original list object is mutated; no copy is made.
    """
    input_list.reverse()
    return input_list


def masking_string(nric_string):
    """Mask an NRIC-style string, keeping only the characters from index 5.

    Example::

        >>> masking_string("S1234567D")
        '*****567D'

    Raises:
        ValueError: If ``nric_string`` has fewer than six characters.
    """
    if len(nric_string) < 6:
        raise ValueError(
            f"masking_string requires at least 6 characters, got {len(nric_string)!r}"
        )
    nric_substring = nric_string[5:]
    return f"*****{nric_substring}"


def _to_positive_int(value, name="chunk size"):
    """Validate ``value`` as a positive integer.

    Accepts any integral numeric type (``int``, integral ``float``,
    integral ``Decimal``, integral ``Fraction``) and string representations
    of positive integers.  Rejects booleans, non-integral values, non-finite
    floats, non-finite Decimals, and negative or zero values.
    """
    if isinstance(value, bool):
        raise ValueError(
            f"string_splitter {name} must be a positive integer, got {value!r}"
        )
    if isinstance(value, float):
        if not math.isfinite(value) or not value.is_integer():
            raise ValueError(
                f"string_splitter {name} must be a positive integer, got {value!r}"
            )
        result = int(value)
    elif isinstance(value, Decimal):
        if not value.is_finite() or value != value.to_integral_value():
            raise ValueError(
                f"string_splitter {name} must be a positive integer, got {value!r}"
            )
        result = int(value)
    elif isinstance(value, Fraction):
        if value.denominator != 1:
            raise ValueError(
                f"string_splitter {name} must be a positive integer, got {value!r}"
            )
        result = value.numerator
    else:
        try:
            result = int(value)
        except (TypeError, ValueError) as exc:
            raise ValueError(
                f"string_splitter {name} must be a positive integer, got {value!r}"
            ) from exc
    if result <= 0:
        raise ValueError(
            f"string_splitter {name} must be a positive integer, got {result}"
        )
    return result


def string_splitter(string, chars):
    """Split ``string`` into chunks of length ``chars``.

    Example::

        >>> string_splitter("123456789", 2)
        ['12', '34', '56', '78', '9']

    Raises:
        ValueError: If ``chars`` is not a positive integer.
    """
    chars = _to_positive_int(chars)
    return [string[pointer : pointer + chars] for pointer in range(0, len(string), chars)]


def add_space_between_string(string):
    """Insert a single space between each character of ``string``.

    Leading and trailing whitespace is stripped to match the original
    Robot keyword behaviour.  Non-string inputs are coerced to strings.

    Example::

        >>> add_space_between_string("12345")
        '1 2 3 4 5'
        >>> add_space_between_string(" a ")
        'a'
    """
    return " ".join(string_splitter(str(string), 1)).strip()


def convert_int_to_secs(numsecs):
    """Return a ``timedelta`` for ``numsecs`` seconds.

    Robot passes keyword arguments as strings, so numeric strings are
    accepted alongside ints/floats. Fractional seconds are preserved::

        >>> convert_int_to_secs(0.5)
        datetime.timedelta(microseconds=500000)
    """
    return timedelta(seconds=float(numsecs))


def date_field_formatter(datestr):
    """Validate ``dd/mm/yyyy`` and return it as ``dd / mm / yyyy``.

    The date is checked against the real calendar (e.g. 31/02/2026 is
    rejected).

    Raises:
        ValueError: If the format is not ``dd/mm/yyyy`` or the date is
            not a real calendar date.
    """
    if not isinstance(datestr, str):
        raise ValueError(
            f"date_field_formatter expects a string in dd/mm/yyyy format, got {type(datestr).__name__}"
        )
    parts = datestr.split("/")
    if len(parts) != 3 or any(len(part) == 0 for part in parts):
        raise ValueError(
            f"date_field_formatter expects dd/mm/yyyy, got {datestr!r}"
        )
    day, month, year = parts
    if not (len(day) == 2 and len(month) == 2 and len(year) == 4):
        raise ValueError(
            f"date_field_formatter expects dd/mm/yyyy, got {datestr!r}"
        )
    try:
        datetime.strptime(datestr, "%d/%m/%Y")
    except ValueError as exc:
        raise ValueError(
            f"date_field_formatter received an invalid calendar date: {datestr!r}"
        ) from exc
    return f"{day} / {month} / {year}"


def current_date_generator():
    """Return today's date as ``dd/mm/yyyy``."""
    return date.today().strftime("%d/%m/%Y")
