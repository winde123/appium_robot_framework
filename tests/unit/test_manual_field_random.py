"""Unit tests for seeded, reproducible profile test data."""

from datetime import date, datetime, timedelta
from pathlib import Path
import random
import re
import textwrap

from faker import Faker
import pytest

from Data.test_data import manual_field_random


class TestProfileRecordReplay:
    def test_same_seed_and_reference_date_produce_identical_records(self):
        r1 = manual_field_random.generate_profile_record(
            seed=12345, reference_date="2024-06-01"
        )
        r2 = manual_field_random.generate_profile_record(
            seed=12345, reference_date="2024-06-01"
        )
        assert r1 == r2
        assert r1["seed"] == 12345
        assert r1["reference_date"] == "2024-06-01"

    def test_different_seed_produces_different_records(self):
        r1 = manual_field_random.generate_profile_record(seed=1)
        r2 = manual_field_random.generate_profile_record(seed=2)
        assert r1 != r2

    def test_reference_date_affects_expiry(self):
        r1 = manual_field_random.generate_profile_record(
            seed=99, reference_date="2020-01-01"
        )
        r2 = manual_field_random.generate_profile_record(
            seed=99, reference_date="2025-01-01"
        )
        # Same seed but different reference dates should produce different data
        # and expiry dates should differ.
        assert r1["pp_expiry"] != r2["pp_expiry"]

    def test_record_contains_expected_fields(self):
        record = manual_field_random.generate_profile_record()
        expected_keys = {
            "name",
            "nric",
            "dob",
            "pp_num",
            "pp_expiry",
            "foreign_pp_num",
            "country",
            "cty_code",
            "phno",
            "email",
            "seed",
            "reference_date",
        }
        assert set(record.keys()) == expected_keys


class TestGlobalRngIsolation:
    def test_python_global_random_unchanged(self):
        random.seed(0)
        first = random.random()
        second = random.random()
        random.seed(0)
        _ = random.random()
        manual_field_random.generate_profile_record()
        after = random.random()
        assert after == second

    def test_faker_instances_are_independent(self):
        fake = Faker()
        fake.seed_instance(42)
        expected = [fake.name() for _ in range(3)]

        manual_field_random.generate_profile_record()
        manual_field_random.generate_profile_record(seed=42)

        fake2 = Faker()
        fake2.seed_instance(42)
        reproduced = [fake2.name() for _ in range(3)]
        assert reproduced == expected

    def test_factory_instances_are_independent(self):
        f1 = manual_field_random._ProfileFactory(seed=7)
        f2 = manual_field_random._ProfileFactory(seed=7)
        assert f1.to_dict() == f2.to_dict()
        f3 = manual_field_random._ProfileFactory(seed=8)
        assert f1.to_dict() != f3.to_dict()


class TestFieldShapesAndChecksums:
    def test_nric_format_and_checksum(self):
        nric = manual_field_random.generaterandomNRIC()
        assert re.fullmatch(r"S\d{7}[A-Z]", nric)
        weights = (2, 7, 6, 5, 4, 3, 2)
        lookup = ["J", "Z", "I", "H", "G", "F", "E", "D", "C", "B", "A"]
        total = sum(int(nric[i + 1]) * w for i, w in enumerate(weights))
        assert nric[-1] == lookup[total % 11]

    def test_passport_format_and_checksum(self):
        pp = manual_field_random.generaterandomPPNumber()
        assert re.fullmatch(r"K\d{7}[A-Z]", pp)
        weights = (2, 7, 6, 5, 4, 3, 2)
        lookup = ["E", "D", "B", "A", "H", "K", "N", "P", "R", "Z", "G"]
        total = sum(int(pp[i + 1]) * w for i, w in enumerate(weights))
        assert pp[-1] == lookup[total % 11]

    def test_car_plate_format_and_checksum(self):
        plate = manual_field_random.generaterandomCarPlateNumber()
        assert re.fullmatch(r"S[A-Z]{2}\d{4}[A-Z]", plate)
        weights = (10, 15, 14, 15, 16, 17)
        lookup = [
            "A", "B", "C", "D", "E", "G", "H", "J", "K", "L",
            "M", "P", "R", "S", "T", "U", "X", "Y", "Z",
        ]
        char_to_num = {c: i + 1 for i, c in enumerate("ABCDEFGHIJKLMNOPQRSTUVWXYZ")}
        # S + two letters + four digits + checksum
        total = char_to_num[plate[1]] * weights[0] + char_to_num[plate[2]] * weights[1]
        total += sum(int(plate[i + 1]) * weights[i] for i in range(2, 6))
        assert plate[-1] == lookup[total % 19]

    def test_dob_format_and_range(self):
        dob = manual_field_random.generaterandomDOB()
        assert re.fullmatch(r"\d{2}/\d{2}/\d{4}", dob)
        parsed = datetime.strptime(dob, "%d/%m/%Y").date()
        assert date(1965, 1, 1) <= parsed <= date(2023, 1, 1)

    def test_pp_expiry_format_and_relative_to_reference(self):
        ref = date(2020, 1, 1)
        record = manual_field_random.generate_profile_record(
            seed=1, reference_date=ref.isoformat()
        )
        expiry = record["pp_expiry"]
        assert re.fullmatch(r"\d{2}/\d{2}/\d{4}", expiry)
        parsed = datetime.strptime(expiry, "%d/%m/%Y").date()
        earliest = ref + timedelta(weeks=52)
        assert parsed >= earliest

    def test_phone_number_is_seven_digits(self):
        phno = manual_field_random.generateRandomPhNo()
        assert isinstance(phno, int)
        assert 1_000_000 <= phno <= 9_999_999

    def test_email_uses_test_domain(self):
        email = manual_field_random.generateRandomEmail()
        assert email.endswith("@test.co")
        assert "@" in email

    def test_cty_code_sg_is_65_and_other_is_random(self):
        assert manual_field_random.generateRandomCtyCode("SG") == 65
        other = manual_field_random.generateRandomCtyCode("US")
        assert isinstance(other, int)
        assert 1 <= other <= 998


class TestRobotImportAndKeywords:
    def test_module_imports_without_side_effects(self):
        # Reimporting should not generate module-level random constants.
        import importlib

        mod = importlib.reload(manual_field_random)
        legacy_constants = ["NRIC", "NAME", "DOB", "EMAIL", "PHNO", "PPNUM"]
        for name in legacy_constants:
            assert not hasattr(mod, name)

    def test_expected_keywords_are_exposed(self):
        from robot.running.testlibraries import TestLibrary

        lib = TestLibrary.from_name("Data.test_data.manual_field_random")
        names = {k.name for k in lib.keywords}
        expected = {
            "Generate Profile Record",
            "Generate Random Cty Code",
            "Generate Random Ph No",
            "Generate Random Name",
            "Generate Random Email",
            "Generaterandom DOB",
            "Generate PP Date Exp",
            "Generaterandom NRIC",
            "Generaterandom PP Number",
            "Generaterandom Car Plate Number",
            "Generate Foreign Passport Num",
            "Generatelistof DOBS",
            "Generatelistof Names",
            "Generatelistof NRIC",
            "Generate Listof PP Num",
            "Generate Listof Vehno",
            "Generate Listof Permit",
            "Readfromfile",
        }
        assert expected.issubset(names)
        assert "Main" not in names
        assert "Cargo Data" not in names

    def test_no_accidental_keywords_from_helpers(self):
        from robot.running.testlibraries import TestLibrary

        lib = TestLibrary.from_name("Data.test_data.manual_field_random")
        names = {k.name for k in lib.keywords}
        # Internal helpers/classes must not become keywords.
        assert "Profile Factory" not in names
        assert "Robot Log" not in names


class TestFactoryValidation:
    def test_invalid_seed_string_raises_clear_error(self):
        with pytest.raises(ValueError, match="numeric string"):
            manual_field_random.generate_profile_record(seed="not-a-number")

    def test_invalid_seed_type_raises_clear_error(self):
        with pytest.raises(TypeError, match="int, str or None"):
            manual_field_random.generate_profile_record(seed=3.14)

    def test_bool_seed_is_rejected(self):
        with pytest.raises(TypeError, match="bool"):
            manual_field_random.generate_profile_record(seed=True)

    def test_invalid_reference_date_string_raises_clear_error(self):
        with pytest.raises(ValueError, match="ISO date string"):
            manual_field_random.generate_profile_record(reference_date="06-01-2024")

    def test_datetime_reference_date_is_rejected(self):
        from datetime import datetime as dt

        with pytest.raises(TypeError, match="datetime"):
            manual_field_random.generate_profile_record(reference_date=dt.now())

    def test_invalid_reference_date_type_raises_clear_error(self):
        with pytest.raises(TypeError, match="date or ISO string"):
            manual_field_random.generate_profile_record(reference_date=123)

    def test_invalid_country_type_raises_clear_error(self):
        with pytest.raises(TypeError, match="str or None"):
            manual_field_random.generate_profile_record(country=123)

    def test_country_is_normalized_to_uppercase(self):
        record = manual_field_random.generate_profile_record(country="sg")
        assert record["country"] == "SG"
        assert record["cty_code"] == 65

    def test_seed_roundtrips_through_string(self):
        r1 = manual_field_random.generate_profile_record(seed=42)
        r2 = manual_field_random.generate_profile_record(seed=str(r1["seed"]))
        assert r1 == r2

    def test_reference_date_roundtrips_through_string(self):
        r1 = manual_field_random.generate_profile_record(reference_date="2022-02-15")
        r2 = manual_field_random.generate_profile_record(
            seed=r1["seed"], reference_date=r1["reference_date"]
        )
        assert r1 == r2

    def test_country_roundtrips_and_reproduces_record(self):
        r1 = manual_field_random.generate_profile_record(
            seed=7, reference_date="2021-01-01", country="sg"
        )
        r2 = manual_field_random.generate_profile_record(
            seed=r1["seed"],
            reference_date=r1["reference_date"],
            country=r1["country"],
        )
        assert r1 == r2


class TestMainScript:
    def test_main_output_has_original_field_semantics(self, capsys):
        manual_field_random._main()
        captured = capsys.readouterr().out.strip()
        parts = captured.split()
        assert len(parts) == 4
        nric, pp, car, email = parts
        assert re.fullmatch(r"S\d{7}[A-Z]", nric)
        assert re.fullmatch(r"K\d{7}[A-Z]", pp)
        assert re.fullmatch(r"S[A-Z]{2}\d{4}[A-Z]", car)
        assert "@" in email


class TestCompatibilityKeywords:
    def test_list_helpers_return_requested_length(self):
        assert len(manual_field_random.generatelistofDOBS(5)) == 5
        assert len(manual_field_random.generatelistofNames(3)) == 3
        assert len(manual_field_random.generatelistofNRIC(4)) == 4
        assert len(manual_field_random.generateListofPPNum(2)) == 2
        assert len(manual_field_random.generateListofVehno(2)) == 2
        assert len(manual_field_random.generateListofPermit(15)) == 15

    def test_permit_list_format_matches_legacy(self):
        permits = manual_field_random.generateListofPermit(12)
        assert permits[0] == "OO5E9900000"
        assert permits[10] == "OO5E9900010"
        assert permits[11] == "OO5E9900011"


class TestRobotBoundaryExecution:
    """Device-free real Robot execution against the SGAC profile keywords."""

    @staticmethod
    def _make_robot_suite(tmp_path, resource_path, manual_lib_path, with_nric_stub=False):
        stub_lib = tmp_path / "stub_ui.py"
        stub_lib.write_text(
            textwrap.dedent(
                """
                TYPED = []

                def record_typed_value(value):
                    TYPED.append(value)

                def get_typed_values():
                    return TYPED[:]

                def clear_typed_values():
                    TYPED.clear()
                """
            ),
            encoding="utf-8",
        )

        nric_stub = ""
        if with_nric_stub:
            nric_stub = (
                "Input NRIC into input field for android device\n"
                "    [Arguments]    ${nric_field_locator}    ${textstring}\n"
                "    Record Typed Value    ${textstring}\n"
            )

        robot_content = """\
*** Settings ***
Library    {stub_lib}
Resource    {resource}
Library    {manual_lib}

*** Keywords ***
Click on element
    [Arguments]    ${{elementid}}
    No Operation
Type text
    [Arguments]    ${{elementid}}    ${{textstring}}
    Record Typed Value    ${{textstring}}
{nric_stub}
*** Test Cases ***
No-arg generates and returns profile
    Clear Typed Values
    ${{record}}=    Create resident profile manually
    Should Not Be Equal    ${{record}}    ${{NONE}}
    Should Be Equal As Integers    ${{record}}[cty_code]    65
    ${{expected}}=    Create List    ${{record}}[name]    ${{record}}[nric]    ${{record}}[dob]    ${{record}}[cty_code]    ${{record}}[phno]    ${{record}}[email]
    ${{typed}}=    Get Typed Values
    Should Be Equal    ${{typed}}    ${{expected}}

No-arg record is reproducible from its metadata
    ${{record}}=    Create resident profile manually
    ${{rebuilt}}=    Generate Profile Record    seed=${{record}}[seed]    reference_date=${{record}}[reference_date]    country=${{record}}[country]
    Should Be Equal    ${{rebuilt}}    ${{record}}

Supplied profile is used and returned
    Clear Typed Values
    ${{record}}=    Generate Profile Record    country=SG
    ${{result}}=    Create resident profile manually    ${{record}}
    Should Be Equal    ${{result}}    ${{record}}
    ${{expected}}=    Create List    ${{record}}[name]    ${{record}}[nric]    ${{record}}[dob]    ${{record}}[cty_code]    ${{record}}[phno]    ${{record}}[email]
    ${{typed}}=    Get Typed Values
    Should Be Equal    ${{typed}}    ${{expected}}
""".format(
            stub_lib=stub_lib,
            resource=resource_path,
            manual_lib=manual_lib_path,
            nric_stub=nric_stub,
        )

        robot_file = tmp_path / "test.robot"
        robot_file.write_text(robot_content, encoding="utf-8")
        return robot_file, stub_lib

    def _run_robot_suite(self, robot_file, tmp_path):
        import io
        from robot import run

        stdout = io.StringIO()
        stderr = io.StringIO()
        rc = run(
            str(robot_file),
            outputdir=str(tmp_path),
            output="NONE",
            log="NONE",
            report="NONE",
            stdout=stdout,
            stderr=stderr,
        )
        if rc != 0:
            pytest.fail(
                f"Robot execution failed with rc={rc}\nstdout:\n{stdout.getvalue()}\n"
                f"stderr:\n{stderr.getvalue()}"
            )

    def test_android_create_resident_profile_keyword(self, tmp_path):
        import importlib
        import sys
        import textwrap

        repo_root = Path(__file__).resolve().parents[2]
        robot_file, stub_lib = self._make_robot_suite(
            tmp_path=tmp_path,
            resource_path=repo_root / "Resources" / "android" / "SGACcommands.robot",
            manual_lib_path=repo_root / "Data" / "test_data" / "manual_field_random.py",
            with_nric_stub=True,
        )
        self._run_robot_suite(robot_file, tmp_path)
        sys.path.insert(0, str(tmp_path))
        try:
            stub_ui = importlib.import_module("stub_ui")
        finally:
            sys.path.pop(0)
        assert len(stub_ui.get_typed_values()) == 6

    def test_ios_create_resident_profile_keyword(self, tmp_path):
        import importlib
        import sys
        import textwrap

        repo_root = Path(__file__).resolve().parents[2]
        robot_file, stub_lib = self._make_robot_suite(
            tmp_path=tmp_path,
            resource_path=repo_root / "Resources" / "ios" / "SGACcommands.robot",
            manual_lib_path=repo_root / "Data" / "test_data" / "manual_field_random.py",
            with_nric_stub=False,
        )
        self._run_robot_suite(robot_file, tmp_path)
        sys.path.insert(0, str(tmp_path))
        try:
            stub_ui = importlib.import_module("stub_ui")
        finally:
            sys.path.pop(0)
        assert len(stub_ui.get_typed_values()) == 6
