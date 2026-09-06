"""Compute QR-code validity dates.

The original exploratory script printed ``datetime.now() + timedelta(364)``.
This module turns that into a small reusable helper with an explicit CLI.
"""

import argparse
from datetime import datetime, timedelta


def compute_qr_validity_date(days=364, from_date=None):
    """Return a datetime that is ``days`` days after ``from_date``.

    Args:
        days: Number of days to add (default: 364).
        from_date: Base datetime (default: :func:`datetime.now`).

    Returns:
        A :class:`datetime.datetime` object.
    """
    if from_date is None:
        from_date = datetime.now()
    return from_date + timedelta(days=days)


def format_qr_date(dt):
    """Format ``dt`` as ``YYYY-MM-DD HH:MM:SS``."""
    return dt.strftime("%Y-%m-%d %H:%M:%S")


def _parse_datetime(value):
    """Parse ``YYYY-MM-DD HH:MM:SS`` for the CLI."""
    return datetime.strptime(value, "%Y-%m-%d %H:%M:%S")


def main(argv=None):
    """Command-line entry point."""
    parser = argparse.ArgumentParser(
        description="Compute a QR-code validity date (default: today + 364 days)."
    )
    parser.add_argument(
        "--days",
        type=int,
        default=364,
        help="Number of days to add to the base date",
    )
    parser.add_argument(
        "--from-date",
        type=_parse_datetime,
        help="Base datetime in YYYY-MM-DD HH:MM:SS format (default: now)",
    )
    args = parser.parse_args(argv)
    result = compute_qr_validity_date(days=args.days, from_date=args.from_date)
    print(format_qr_date(result))


if __name__ == "__main__":
    main()
