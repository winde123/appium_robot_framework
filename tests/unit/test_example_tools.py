"""Unit tests for tools/examples helper scripts.

Device-free, network-free, and image-free.  The treepoem backend and any
file writes are mocked or asserted against.
"""

import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from unittest import mock

import pytest

from tools.examples import generate_qr_code, qr_date_validator

REPO_ROOT = Path(__file__).resolve().parents[2]


def _import_in_subprocess(module_path):
    """Import ``module_path`` in a fresh interpreter and return stdout/stderr."""
    cmd = [sys.executable, "-B", "-c", f"import {module_path}"]
    return subprocess.run(
        cmd, capture_output=True, text=True, cwd=REPO_ROOT
    )


class TestImportSafety:
    """Modules must be import-safe: no printing, no file writes, no optional deps."""

    def test_generate_qr_code_import_is_safe(self):
        result = _import_in_subprocess("tools.examples.generate_qr_code")
        assert result.returncode == 0
        assert result.stdout == ""
        assert result.stderr == ""

    def test_qr_date_validator_import_is_safe(self):
        result = _import_in_subprocess("tools.examples.qr_date_validator")
        assert result.returncode == 0
        assert result.stdout == ""
        assert result.stderr == ""

    def test_legacy_qr_shim_import_is_safe(self):
        result = _import_in_subprocess("Data.test_data.generate_qr_128_test")
        assert result.returncode == 0
        assert result.stdout == ""
        assert result.stderr == ""

    def test_legacy_date_shim_import_is_safe(self):
        result = _import_in_subprocess("Data.test_data.validateQRdate")
        assert result.returncode == 0
        assert result.stdout == ""
        assert result.stderr == ""


class TestGenerateQrCode:
    def test_missing_treepoem_raises_clear_error_and_writes_nothing(self, capsys, tmp_path):
        output = tmp_path / "should_not_exist.gif"
        with mock.patch.dict("sys.modules", {"treepoem": None}):
            with pytest.raises(RuntimeError, match="treepoem is required"):
                generate_qr_code.generate_qr_code("hello", str(output))
        assert not output.exists()
        captured = capsys.readouterr()
        assert captured.out == ""
        assert captured.err == ""

    def test_happy_path(self, tmp_path):
        fake_image = mock.MagicMock()
        fake_treepoem = mock.MagicMock()
        fake_treepoem.generate_barcode.return_value = fake_image

        output = tmp_path / "qr.gif"
        with mock.patch.dict("sys.modules", {"treepoem": fake_treepoem}):
            result = generate_qr_code.generate_qr_code(
                data="https://example.com",
                output_path=output,
                eclevel="H",
            )

        assert result == output.resolve()
        fake_treepoem.generate_barcode.assert_called_once_with(
            barcode_type="qrcode",
            data="https://example.com",
            options={"eclevel": "H"},
        )
        fake_image.convert.assert_called_once_with("1")
        fake_image.convert.return_value.save.assert_called_once_with(str(output))

    def test_main_prints_saved_path(self, capsys, tmp_path):
        fake_image = mock.MagicMock()
        fake_treepoem = mock.MagicMock()
        fake_treepoem.generate_barcode.return_value = fake_image

        output = tmp_path / "qr.gif"
        with mock.patch.dict("sys.modules", {"treepoem": fake_treepoem}):
            generate_qr_code.main(["--data", "x", "--output", str(output)])

        captured = capsys.readouterr()
        assert f"QR code saved to {output.resolve()}" in captured.out

    def test_legacy_shim_run_with_missing_treepoem_writes_nothing(self, tmp_path):
        output = tmp_path / "qr.gif"
        code = (
            "import sys, runpy\n"
            "sys.modules['treepoem'] = None\n"
            f"sys.argv = ['generate_qr_128_test.py', '--data', 'x', "
            f"'--output', '{output}']\n"
            "runpy.run_path('Data/test_data/generate_qr_128_test.py', run_name='__main__')\n"
        )
        result = subprocess.run(
            [sys.executable, "-B", "-c", code],
            capture_output=True,
            text=True,
            cwd=REPO_ROOT,
        )
        assert result.returncode != 0
        assert "treepoem is required" in result.stderr
        assert result.stdout == ""
        assert not output.exists()


class TestQrDateValidator:
    def test_compute_default(self):
        base = datetime(2026, 1, 1, 12, 0, 0)
        result = qr_date_validator.compute_qr_validity_date(from_date=base)
        assert result == datetime(2026, 12, 31, 12, 0, 0)

    def test_compute_custom_days(self):
        base = datetime(2026, 1, 1, 0, 0, 0)
        result = qr_date_validator.compute_qr_validity_date(days=7, from_date=base)
        assert result == datetime(2026, 1, 8, 0, 0, 0)

    def test_format_qr_date(self):
        dt = datetime(2026, 12, 31, 12, 0, 0)
        assert qr_date_validator.format_qr_date(dt) == "2026-12-31 12:00:00"

    def test_main_default(self, capsys):
        base = datetime(2026, 1, 1, 0, 0, 0)
        expected = datetime(2026, 12, 31, 0, 0, 0)
        with mock.patch.object(
            qr_date_validator, "compute_qr_validity_date", return_value=expected
        ):
            qr_date_validator.main(["--from-date", "2026-01-01 00:00:00"])
        captured = capsys.readouterr()
        assert "2026-12-31 00:00:00" in captured.out

    def test_main_matches_original_script(self, capsys):
        # The original exploratory script printed datetime.now()+timedelta(364).
        base = datetime(2026, 6, 6, 10, 30, 0)
        expected = datetime(2027, 6, 5, 10, 30, 0)
        with mock.patch.object(
            qr_date_validator, "compute_qr_validity_date", return_value=expected
        ):
            qr_date_validator.main(["--from-date", "2026-06-06 10:30:00"])
        captured = capsys.readouterr()
        assert "2027-06-05 10:30:00" in captured.out

    def test_legacy_date_shim_run(self, capsys, tmp_path):
        code = (
            "import sys, runpy\n"
            f"sys.argv = ['validateQRdate.py', '--from-date', '2026-01-01 00:00:00']\n"
            "runpy.run_path('Data/test_data/validateQRdate.py', run_name='__main__')\n"
        )
        result = subprocess.run(
            [sys.executable, "-B", "-c", code],
            capture_output=True,
            text=True,
            cwd=REPO_ROOT,
        )
        assert result.returncode == 0
        assert "2026-12-31 00:00:00" in result.stdout
        assert result.stderr == ""
