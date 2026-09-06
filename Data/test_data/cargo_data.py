"""Portable cargo permit loading for the MyICA test suite.

The default permit file is expected at the repository root as
``Cargo_Test_Data.txt``.  An explicit path may be supplied, and the loader
handles UTF-8 BOMs and blank lines deterministically.
"""

from __future__ import annotations

from pathlib import Path

DEFAULT_CARGO_FILENAME = "Cargo_Test_Data.txt"


def _repo_root() -> Path:
    """Return the repository root by looking for ``.git`` and the cargo file."""
    start = Path(__file__).resolve()
    for parent in start.parents:
        if (parent / ".git").exists() and (parent / DEFAULT_CARGO_FILENAME).exists():
            return parent
    # Fallback: Data/test_data -> Data -> repo root
    return start.parents[2]


def _resolve_path(path: str | Path | None) -> Path:
    """Resolve an explicit path, or fall back to the repository-anchored default."""
    if path is None:
        return _repo_root() / DEFAULT_CARGO_FILENAME
    return Path(path).expanduser().resolve()


def load_cargo_permits(
    path: str | Path | None = None,
    *,
    min_count: int | None = None,
) -> list[str]:
    """Load non-empty permit numbers from a text file.

    Parameters
    ----------
    path:
        Permit file path.  When omitted, ``Cargo_Test_Data.txt`` in the
        repository root is used.
    min_count:
        If given, raise ``ValueError`` when fewer entries are available.
        This lets callers fail early instead of indexing past the file.

    Returns
    -------
    List of stripped, non-empty permit strings.

    Raises
    ------
    FileNotFoundError
        If the permit file does not exist.
    ValueError
        If ``min_count`` is specified and the file contains fewer entries.
    """
    resolved = _resolve_path(path)

    if not resolved.exists():
        raise FileNotFoundError(
            f"Cargo permit file not found: {resolved}"
        )

    with resolved.open(encoding="utf-8-sig", mode="r") as fh:
        permits = [line.strip() for line in fh if line.strip() != ""]

    if min_count is not None and len(permits) < min_count:
        raise ValueError(
            f"Cargo permit file has {len(permits)} entries, "
            f"need at least {min_count}: {resolved}"
        )

    return permits
