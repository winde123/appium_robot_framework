#!/usr/bin/env python3
"""T40 parity linter for the SGAC fork refactor.

Checks:
1. Locator key parity between Data/sgac1/** and Data/sgac2/** YAML files.
2. Import path hygiene in *.robot Settings sections.
3. Hardcoded fork-specific values outside robotconfig.yaml.

Run from the repository root:
    python3 tools/check_fork_parity.py
    python3 tools/check_fork_parity.py --strict
"""

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path

import yaml

FORK_VALUE = "sg.gov.ica.mobile.app"
EXCLUDED_DIR_PARTS = {"venv", "wheelhouse", "Output"}
ALLOWLIST_NAME = "fork_parity_allowlist.yaml"

SECTION_RE = re.compile(r"^\s*\*{3,}\s*(.+?)\s*\*{3,}\s*$")
IMPORT_RE = re.compile(r"^\s*(Resource|Variables)\s+(\S+)", re.IGNORECASE)


@dataclass(frozen=True)
class Finding:
    check: str
    severity: str  # 'error' or 'warning'
    path: Path
    line: int
    message: str


def repo_root() -> Path:
    """Return the repository root (parent of the tools/ directory)."""
    return Path(__file__).resolve().parent.parent


def is_under_excluded_dir(path: Path, root: Path) -> bool:
    """Return True if any path part under root is an excluded directory."""
    return any(part in EXCLUDED_DIR_PARTS for part in path.relative_to(root).parts)


def collect_robot_files(root: Path) -> list[Path]:
    """Return all *.robot files under root, excluding venv/wheelhouse/Output."""
    files = [
        p
        for p in root.rglob("*.robot")
        if not is_under_excluded_dir(p, root)
    ]
    return sorted(files)


def collect_python_files(root: Path, subdir: Path) -> list[Path]:
    """Return all *.py files under subdir, excluding venv/wheelhouse/Output."""
    files = [
        p
        for p in subdir.rglob("*.py")
        if not is_under_excluded_dir(p, root)
    ]
    return sorted(files)


def _yaml_files(dirpath: Path) -> dict[Path, Path]:
    """Map relative path -> absolute path for all YAML files under dirpath."""
    result: dict[Path, Path] = {}
    if not dirpath.is_dir():
        return result
    for ext in ("*.yaml", "*.yml"):
        for p in dirpath.rglob(ext):
            result[p.relative_to(dirpath)] = p
    return result


class _Allowlist:
    """Intentional fork divergences loaded from tools/fork_parity_allowlist.yaml.

    Tracks which entries were consumed so stale entries can be reported.
    """

    def __init__(self, root: Path):
        self.path = root / "tools" / ALLOWLIST_NAME
        self.files_sgac1_only: set[str] = set()
        self.files_sgac2_only: set[str] = set()
        self.keys: dict[str, dict[str, set[str]]] = {}
        self.used: set[tuple[str, str, str]] = set()
        if not self.path.is_file():
            return
        with self.path.open(encoding="utf-8") as fh:
            data = yaml.safe_load(fh) or {}
        files = data.get("files") or {}
        self.files_sgac1_only = set(files.get("sgac1_only") or [])
        self.files_sgac2_only = set(files.get("sgac2_only") or [])
        for rel, sides in (data.get("keys") or {}).items():
            self.keys[rel] = {
                "sgac1_only": set((sides or {}).get("sgac1_only") or []),
                "sgac2_only": set((sides or {}).get("sgac2_only") or []),
            }

    def allowed_file(self, rel: str, side: str) -> bool:
        pool = self.files_sgac1_only if side == "sgac1_only" else self.files_sgac2_only
        if rel in pool:
            self.used.add(("files", side, rel))
            return True
        return False

    def filter_keys(self, rel: str, side: str, keys: list[str]) -> list[str]:
        allowed = self.keys.get(rel, {}).get(side, set())
        kept = []
        for key in keys:
            if key in allowed:
                self.used.add((rel, side, key))
            else:
                kept.append(key)
        return kept

    def stale_entries(self) -> list[tuple[str, str, str]]:
        entries = [
            ("files", "sgac1_only", rel) for rel in self.files_sgac1_only
        ] + [
            ("files", "sgac2_only", rel) for rel in self.files_sgac2_only
        ] + [
            (rel, side, key)
            for rel, sides in self.keys.items()
            for side, keys in sides.items()
            for key in keys
        ]
        return sorted(set(entries) - self.used)

    def used_count(self) -> int:
        return len(self.used)


def check_locator_parity(root: Path) -> list[Finding]:
    """Diff top-level YAML key sets between Data/sgac1 and Data/sgac2.

    Divergences listed in tools/fork_parity_allowlist.yaml are suppressed;
    allowlist entries that no longer match anything are reported as errors.
    """
    findings: list[Finding] = []
    sgac1 = root / "Data" / "sgac1"
    sgac2 = root / "Data" / "sgac2"

    if not sgac1.is_dir() or not sgac2.is_dir():
        # Migration has not started; caller prints a SKIP note.
        return findings

    allowlist = _Allowlist(root)
    files1 = _yaml_files(sgac1)
    files2 = _yaml_files(sgac2)

    for rel in sorted(files1.keys() - files2.keys()):
        if allowlist.allowed_file(rel.as_posix(), "sgac1_only"):
            continue
        findings.append(
            Finding(
                check="locator_parity",
                severity="error",
                path=files1[rel],
                line=1,
                message=f"present in Data/sgac1 but missing in Data/sgac2: {rel}",
            )
        )
    for rel in sorted(files2.keys() - files1.keys()):
        if allowlist.allowed_file(rel.as_posix(), "sgac2_only"):
            continue
        findings.append(
            Finding(
                check="locator_parity",
                severity="error",
                path=files2[rel],
                line=1,
                message=f"present in Data/sgac2 but missing in Data/sgac1: {rel}",
            )
        )

    for rel in sorted(files1.keys() & files2.keys()):
        p1, p2 = files1[rel], files2[rel]
        try:
            with p1.open(encoding="utf-8") as fh:
                data1 = yaml.safe_load(fh)
            with p2.open(encoding="utf-8") as fh:
                data2 = yaml.safe_load(fh)
        except yaml.YAMLError as exc:
            findings.append(
                Finding(
                    check="locator_parity",
                    severity="error",
                    path=p1,
                    line=1,
                    message=f"YAML parse error while comparing {rel}: {exc}",
                )
            )
            continue

        if not isinstance(data1, dict) or not isinstance(data2, dict):
            if type(data1) is not type(data2):
                findings.append(
                    Finding(
                        check="locator_parity",
                        severity="error",
                        path=p1,
                        line=1,
                        message=(
                            f"top-level type mismatch in {rel}: "
                            f"{type(data1).__name__} vs {type(data2).__name__}"
                        ),
                    )
                )
            continue

        keys1 = set(data1.keys())
        keys2 = set(data2.keys())
        missing = allowlist.filter_keys(
            rel.as_posix(), "sgac1_only", sorted(keys1 - keys2)
        )
        extra = allowlist.filter_keys(
            rel.as_posix(), "sgac2_only", sorted(keys2 - keys1)
        )

        if missing:
            findings.append(
                Finding(
                    check="locator_parity",
                    severity="error",
                    path=p2,
                    line=1,
                    message=(
                        f"missing keys in {rel} (present in sgac1 but not sgac2): "
                        f"{', '.join(missing)}"
                    ),
                )
            )
        if extra:
            findings.append(
                Finding(
                    check="locator_parity",
                    severity="error",
                    path=p2,
                    line=1,
                    message=(
                        f"extra keys in {rel} (present in sgac2 but not sgac1): "
                        f"{', '.join(extra)}"
                    ),
                )
            )

    for rel, side, entry in allowlist.stale_entries():
        findings.append(
            Finding(
                check="locator_parity",
                severity="error",
                path=allowlist.path,
                line=1,
                message=(
                    f"stale allowlist entry ({rel} / {side}): {entry} — "
                    "no matching divergence exists any more; remove it"
                ),
            )
        )

    if allowlist.used_count():
        print(
            f"NOTE: {allowlist.used_count()} intentional divergences suppressed "
            f"via tools/{ALLOWLIST_NAME}"
        )

    return findings


def _read_lines(path: Path) -> list[str]:
    """Read a text file, falling back to latin-1 on decode errors."""
    try:
        return path.read_text(encoding="utf-8").splitlines()
    except UnicodeDecodeError:
        return path.read_text(encoding="latin-1").splitlines()


def _check_path_escapes_root(
    root: Path,
    file_path: Path,
    lineno: int,
    keyword: str,
    import_path: str,
    findings: list[Finding],
) -> None:
    """Flag relative paths that resolve above the repository root."""
    if import_path.startswith("/") or import_path.startswith("${"):
        # Absolute or variable-interpolated: we cannot/statically check escaping.
        return

    try:
        resolved = (file_path.parent / import_path).resolve()
    except OSError:
        return

    try:
        resolved.relative_to(root.resolve())
    except ValueError:
        findings.append(
            Finding(
                check="import_hygiene",
                severity="error",
                path=file_path,
                line=lineno,
                message=f"{keyword} relative path escapes repository root: {import_path}",
            )
        )


def _check_variables_data_path(
    file_path: Path,
    lineno: int,
    import_path: str,
    findings: list[Finding],
) -> None:
    """Flag locator Variables imports that bypass ${FORK_DATA_DIR}."""
    if "Data/test_data/" in import_path:
        return

    for literal in ("Data/sgac1/", "Data/sgac2/"):
        if literal in import_path:
            findings.append(
                Finding(
                    check="import_hygiene",
                    severity="error",
                    path=file_path,
                    line=lineno,
                    message=(
                        "Variables import uses literal fork path "
                        f"(must use ${{FORK_DATA_DIR}}): {import_path}"
                    ),
                )
            )
            return

    for literal, label in (("Data/android/", "android"), ("Data/ios/", "ios")):
        if literal in import_path:
            findings.append(
                Finding(
                    check="import_hygiene",
                    severity="warning",
                    path=file_path,
                    line=lineno,
                    message=(
                        f"Variables import uses old Data/{label} tree "
                        f"(pending Wave 2 migration): {import_path}"
                    ),
                )
            )
            return


def _check_import_hygiene_file(root: Path, file_path: Path) -> list[Finding]:
    """Check a single .robot file for import hygiene issues."""
    findings: list[Finding] = []
    section: str | None = None

    for lineno, raw in enumerate(_read_lines(file_path), start=1):
        stripped = raw.strip()
        if not stripped or stripped.startswith("#"):
            continue

        section_match = SECTION_RE.match(raw)
        if section_match:
            section = section_match.group(1).strip().lower()
            continue

        if section != "settings":
            continue

        import_match = IMPORT_RE.match(raw)
        if not import_match:
            continue

        keyword = import_match.group(1).capitalize()
        import_path = import_match.group(2)

        _check_path_escapes_root(
            root, file_path, lineno, keyword, import_path, findings
        )
        if keyword.lower() == "variables":
            _check_variables_data_path(file_path, lineno, import_path, findings)

    return findings


def check_import_hygiene(root: Path) -> list[Finding]:
    """Scan *.robot Settings sections for bad Resource/Variables imports."""
    findings: list[Finding] = []
    for path in collect_robot_files(root):
        findings.extend(_check_import_hygiene_file(root, path))
    return findings


def check_hardcoded_values(root: Path) -> list[Finding]:
    """Scan *.robot and Resources/*.py for hardcoded fork-specific strings."""
    findings: list[Finding] = []

    for path in collect_robot_files(root):
        # Explicit exclusions for docs/ and Data/ (collect_robot_files should not
        # find .robot files there, but be defensive).
        if "docs" in path.parts or "Data" in path.parts:
            continue
        findings.extend(_scan_file_for_hardcoded(root, path))

    for path in collect_python_files(root, root / "Resources"):
        findings.extend(_scan_file_for_hardcoded(root, path))

    return findings


def _scan_file_for_hardcoded(root: Path, path: Path) -> list[Finding]:
    """Return findings for occurrences of FORK_VALUE in a file."""
    findings: list[Finding] = []
    in_resources = "Resources" in path.parts
    in_tests = "tests" in path.parts

    for lineno, line in enumerate(_read_lines(path), start=1):
        if FORK_VALUE not in line:
            continue

        if in_resources:
            severity = "error"
            note = "hardcoded fork value in Resources/"
        elif in_tests:
            severity = "warning"
            note = "hardcoded fork value (pending Wave 2 migration)"
        else:
            severity = "warning"
            note = "hardcoded fork value"

        findings.append(
            Finding(
                check="hardcoded_values",
                severity=severity,
                path=path,
                line=lineno,
                message=f"{note}: '{FORK_VALUE}'",
            )
        )

    return findings


def format_finding(root: Path, finding: Finding) -> str:
    """Format a finding for human-readable output."""
    try:
        display = finding.path.relative_to(root)
    except ValueError:
        display = finding.path
    return f"{finding.severity.upper()}: {display}:{finding.line} {finding.message}"


def report(findings: list[Finding], strict: bool) -> None:
    """Print a grouped human-readable report."""
    root = repo_root()
    parity = [f for f in findings if f.check == "locator_parity"]
    imports = [f for f in findings if f.check == "import_hygiene"]
    hardcoded = [f for f in findings if f.check == "hardcoded_values"]

    print("=" * 60)
    print("Fork parity linter")
    print("=" * 60)
    print()

    print("1. Locator key parity (Data/sgac1 vs Data/sgac2)")
    print("-" * 60)
    sgac1 = root / "Data" / "sgac1"
    sgac2 = root / "Data" / "sgac2"
    if not sgac1.is_dir() or not sgac2.is_dir():
        print(
            "SKIP: Data/sgac1 and/or Data/sgac2 do not exist yet (migration not started)."
        )
    elif not parity:
        print("OK: no parity issues found.")
    else:
        for f in parity:
            print(format_finding(root, f))
    print()

    print("2. Import path hygiene")
    print("-" * 60)
    if not imports:
        print("OK: no import hygiene issues found.")
    else:
        for f in imports:
            print(format_finding(root, f))
    print()

    print("3. Hardcoded fork values")
    print("-" * 60)
    if not hardcoded:
        print("OK: no hardcoded fork values found outside robotconfig.yaml.")
    else:
        for f in hardcoded:
            print(format_finding(root, f))
    print()

    errors = sum(1 for f in findings if f.severity == "error")
    warnings = sum(1 for f in findings if f.severity == "warning")

    print("=" * 60)
    mode_note = " (strict: warnings treated as errors)" if strict else ""
    print(f"Summary: {errors} errors, {warnings} warnings{mode_note}")
    print("=" * 60)


def compute_exit_code(findings: list[Finding], strict: bool) -> int:
    """Return 1 on errors, or on warnings when --strict; otherwise 0."""
    has_errors = any(f.severity == "error" for f in findings)
    if has_errors:
        return 1
    if strict and any(f.severity == "warning" for f in findings):
        return 1
    return 0


def parse_args(argv: list[str] | None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="SGAC fork parity linter (T40).",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Treat warnings as errors for exit-code purposes.",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    root = repo_root()

    try:
        findings: list[Finding] = []
        findings.extend(check_locator_parity(root))
        findings.extend(check_import_hygiene(root))
        findings.extend(check_hardcoded_values(root))
    except Exception as exc:  # noqa: BLE001
        print(f"ERROR: linter crashed: {exc}", file=sys.stderr)
        return 2

    report(findings, args.strict)
    return compute_exit_code(findings, args.strict)


if __name__ == "__main__":
    sys.exit(main())
