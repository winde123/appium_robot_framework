"""Unit tests for portable cargo permit loading."""

from pathlib import Path
import tempfile

import pytest

from Data.test_data import cargo_data


class TestCargoDataLoading:
    def test_default_load_returns_at_least_100_permits(self):
        permits = cargo_data.load_cargo_permits()
        assert isinstance(permits, list)
        assert len(permits) >= 100
        assert all(isinstance(p, str) and p for p in permits)

    def test_explicit_path_load(self):
        default = cargo_data.load_cargo_permits()
        root = cargo_data._repo_root()
        explicit = cargo_data.load_cargo_permits(root / cargo_data.DEFAULT_CARGO_FILENAME)
        assert explicit == default

    def test_utf8_bom_is_stripped(self, tmp_path: Path):
        path = tmp_path / "bom.txt"
        # Raw UTF-8 BOM followed by plain text
        path.write_bytes(b"\xef\xbb\xbfAA111\nBB222\n")
        permits = cargo_data.load_cargo_permits(path)
        assert permits == ["AA111", "BB222"]

    def test_blank_lines_are_ignored(self, tmp_path: Path):
        path = tmp_path / "blanks.txt"
        path.write_text("AA111\n\n   \nBB222\n\n", encoding="utf-8")
        permits = cargo_data.load_cargo_permits(path)
        assert permits == ["AA111", "BB222"]

    def test_lines_are_stripped(self, tmp_path: Path):
        path = tmp_path / "spaces.txt"
        path.write_text("  AA111  \n\tBB222\t\n", encoding="utf-8")
        permits = cargo_data.load_cargo_permits(path)
        assert permits == ["AA111", "BB222"]

    def test_missing_file_raises_useful_error(self, tmp_path: Path):
        missing = tmp_path / "does_not_exist.txt"
        with pytest.raises(FileNotFoundError) as exc_info:
            cargo_data.load_cargo_permits(missing)
        assert "Cargo permit file not found" in str(exc_info.value)
        assert str(missing) in str(exc_info.value)

    def test_insufficient_entries_raises_useful_error(self, tmp_path: Path):
        path = tmp_path / "short.txt"
        path.write_text("AA111\nBB222\nCC333\n", encoding="utf-8")
        with pytest.raises(ValueError) as exc_info:
            cargo_data.load_cargo_permits(path, min_count=5)
        assert "3 entries" in str(exc_info.value)
        assert "need at least 5" in str(exc_info.value)

    def test_file_is_closed_after_reading(self, tmp_path: Path):
        from unittest.mock import MagicMock, patch

        real_file = tmp_path / "close.txt"
        real_file.write_text("AA111\nBB222\n", encoding="utf-8")

        mock_file = MagicMock()
        mock_file.__enter__ = MagicMock(return_value=mock_file)
        mock_file.__exit__ = MagicMock(return_value=False)
        mock_file.__iter__ = MagicMock(return_value=iter(["AA111\n", "BB222\n"]))

        with patch.object(Path, "open", return_value=mock_file):
            permits = cargo_data.load_cargo_permits(real_file)

        assert permits == ["AA111", "BB222"]
        mock_file.__enter__.assert_called_once()
        mock_file.__exit__.assert_called_once()

    def test_cwd_independent_default(self, tmp_path: Path):
        import os

        default = cargo_data.load_cargo_permits()
        original_cwd = os.getcwd()
        try:
            os.chdir(tmp_path)
            from_cwd = cargo_data.load_cargo_permits()
        finally:
            os.chdir(original_cwd)
        assert from_cwd == default


class TestCargoDataCompatibility:
    def test_readfromfile_wrapper_enforces_100_permit_minimum(self):
        from Data.test_data import manual_field_random

        permits = manual_field_random.readfromfile()
        assert isinstance(permits, list)
        assert len(permits) >= 100

    def test_readfromfile_propagates_custom_path(self, tmp_path: Path):
        from Data.test_data import manual_field_random

        path = tmp_path / "permits.txt"
        path.write_text("\n".join(f"P{i:04d}" for i in range(120)), encoding="utf-8")
        permits = manual_field_random.readfromfile(str(path))
        assert len(permits) == 120
        assert permits[0] == "P0000"

    def test_readfromfile_rejects_short_file(self, tmp_path: Path):
        from Data.test_data import manual_field_random

        path = tmp_path / "short.txt"
        path.write_text("\n".join(f"P{i}" for i in range(50)), encoding="utf-8")
        with pytest.raises(ValueError):
            manual_field_random.readfromfile(str(path))
