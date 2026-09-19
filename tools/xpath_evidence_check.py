#!/usr/bin/env python3
"""Offline locator verifier: evaluate YAML XPath locators against captured page sources.

Purpose: verify fork locator files (Data/{sgac1,sgac2}/{android,ios}/**/*.yaml) against
Appium page-source XML captures (Android UiAutomator2 ``<hierarchy>`` dumps or iOS
XCUITest ``<AppiumAUT>`` dumps) WITHOUT a device. A key is considered verified for a
capture when its XPath resolves to EXACTLY ONE node in that capture.

Usage (from the repository root):

    venv/bin/python tools/xpath_evidence_check.py \
        --yaml Data/sgac2/android/sgac/sgac_landing_page.yaml \
        --evidence Output/evidence/sgac2-build15-regression-2026-09-10 \
        [--match res-] [--keys SGAC-MANAGE-PROFILES-BUTTON ...] [--verbose] [--json out.json]

Exit status is 0 when every checked key resolves to exactly one node in at least one
evidence file, otherwise 1. Template keys (values containing ``{}``) and non-XPath values
are reported and skipped, never counted as failures. Nothing here touches a device.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import yaml

try:
    from lxml import etree
except ImportError as exc:  # pragma: no cover - environment guard
    sys.exit(f"lxml is required (pip install lxml): {exc}")


def _strip_prefix(value: str) -> str:
    value = value.strip()
    if value.lower().startswith("xpath="):
        value = value[len("xpath="):]
    return value


def _is_xpath(value: str) -> bool:
    return value.startswith(("/", "(", "."))


def load_keys(yaml_paths: list[Path]) -> dict[str, str]:
    keys: dict[str, str] = {}
    for path in yaml_paths:
        data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
        if not isinstance(data, dict):
            raise SystemExit(f"{path}: expected a mapping of KEY: locator")
        for key, value in data.items():
            keys[str(key)] = "" if value is None else str(value)
    return keys


def collect_evidence(paths: list[Path], match: str | None) -> list[Path]:
    files: list[Path] = []
    for path in paths:
        if path.is_dir():
            files.extend(sorted(p for p in path.rglob("*.xml")))
        elif path.suffix.lower() == ".xml":
            files.append(path)
        else:
            raise SystemExit(f"{path}: not an XML file or directory")
    if match:
        files = [f for f in files if match in f.name]
    return files


def parse_evidence(files: list[Path]) -> dict[Path, etree._ElementTree]:
    parser = etree.XMLParser(recover=True, huge_tree=True)
    trees: dict[Path, etree._ElementTree] = {}
    for f in files:
        try:
            trees[f] = etree.parse(str(f), parser)
        except (etree.XMLSyntaxError, OSError) as exc:
            print(f"WARN: could not parse {f}: {exc}", file=sys.stderr)
    return trees


def evaluate(keys: dict[str, str], trees: dict[Path, etree._ElementTree]) -> dict[str, dict]:
    results: dict[str, dict] = {}
    for key, raw in keys.items():
        value = _strip_prefix(raw)
        entry = {"locator": value, "status": "", "one": [], "multi": [], "zero": [], "error": ""}
        if not value:
            entry["status"] = "empty (skipped)"
        elif "{}" in value:
            entry["status"] = "template (skipped)"
        elif not _is_xpath(value):
            entry["status"] = "not-xpath (skipped)"
        else:
            try:
                compiled = etree.XPath(value)
            except etree.XPathSyntaxError as exc:
                entry["status"] = "invalid-xpath"
                entry["error"] = str(exc)
                results[key] = entry
                continue
            for path, tree in trees.items():
                try:
                    nodes = compiled(tree)
                except etree.XPathEvalError as exc:
                    entry["status"] = "invalid-xpath"
                    entry["error"] = str(exc)
                    break
                count = len(nodes) if isinstance(nodes, list) else 1
                bucket = "one" if count == 1 else ("multi" if count > 1 else "zero")
                entry[bucket].append(str(path))
            if not entry["status"]:
                if entry["one"]:
                    entry["status"] = "verified"
                elif entry["multi"]:
                    entry["status"] = "ambiguous"
                else:
                    entry["status"] = "unresolved"
        results[key] = entry
    return results


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--yaml", action="append", required=True, type=Path, help="locator YAML (repeatable)")
    ap.add_argument("--evidence", action="append", required=True, type=Path, help="XML file or directory (repeatable)")
    ap.add_argument("--match", help="only evidence files whose name contains this substring")
    ap.add_argument("--keys", nargs="*", help="restrict to these keys")
    ap.add_argument("--verbose", action="store_true", help="list matching files per key")
    ap.add_argument("--json", type=Path, help="write the full result mapping to this JSON file")
    args = ap.parse_args(argv)

    keys = load_keys(args.yaml)
    if args.keys:
        missing = [k for k in args.keys if k not in keys]
        if missing:
            raise SystemExit(f"keys not found in YAML: {', '.join(missing)}")
        keys = {k: keys[k] for k in args.keys}
    files = collect_evidence(args.evidence, args.match)
    if not files:
        raise SystemExit("no evidence XML files found")
    trees = parse_evidence(files)
    results = evaluate(keys, trees)

    width = max(len(k) for k in results) if results else 10
    print(f"evidence files: {len(trees)}")
    failures = 0
    for key, entry in results.items():
        one, multi, zero = len(entry["one"]), len(entry["multi"]), len(entry["zero"])
        example = Path(entry["one"][0]).name if entry["one"] else "-"
        print(f"{key:<{width}}  {entry['status']:<20} one={one:<4} multi={multi:<4} zero={zero:<4} e.g. {example}")
        if entry["error"]:
            print(f"{'':<{width}}  {entry['error']}")
        if args.verbose:
            for bucket in ("one", "multi"):
                for path in entry[bucket]:
                    print(f"{'':<{width}}    [{bucket}] {Path(path).name}")
        if entry["status"] in ("ambiguous", "unresolved", "invalid-xpath"):
            failures += 1
    if args.json:
        args.json.write_text(json.dumps(results, indent=2), encoding="utf-8")
    print(f"checked {len(results)} keys: {failures} not verified")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
