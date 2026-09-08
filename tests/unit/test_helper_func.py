"""Unit tests for Resources/helper_func.py.

Device-free, network-free, and image-free.
"""

import math
from datetime import date, timedelta
from decimal import Decimal
from fractions import Fraction

import pytest

from Resources import helper_func


class TestRemoveWhitespaces:
    def test_removes_spaces(self):
        assert helper_func.remove_whitespaces("a b c") == "abc"

    def test_coerces_to_string(self):
        assert helper_func.remove_whitespaces(12345) == "12345"
        assert helper_func.remove_whitespaces(12.34) == "12.34"

    def test_named_argument_uses_original_parameter_name(self):
        # The original parameter name was ``string``; Python and Robot
        # named calls must continue to work.
        assert helper_func.remove_whitespaces(string="a b") == "ab"


class TestReverseListElements:
    def test_reverses_in_place(self):
        original = [1, 2, 3]
        result = helper_func.reverse_list_elements(original)
        assert result is original
        assert original == [3, 2, 1]

    def test_empty_list(self):
        assert helper_func.reverse_list_elements([]) == []


class TestMaskingString:
    def test_valid_nric(self):
        assert helper_func.masking_string("S1234567D") == "*****567D"

    def test_exact_minimum_length(self):
        assert helper_func.masking_string("123456") == "*****6"

    def test_short_input_raises(self):
        with pytest.raises(ValueError, match="at least 6 characters"):
            helper_func.masking_string("12345")
        with pytest.raises(ValueError, match="at least 6 characters"):
            helper_func.masking_string("")


class TestStringSplitter:
    def test_even_split(self):
        assert helper_func.string_splitter("123456", 2) == ["12", "34", "56"]

    def test_uneven_split(self):
        assert helper_func.string_splitter("12345", 2) == ["12", "34", "5"]

    def test_chunk_larger_than_string(self):
        assert helper_func.string_splitter("123", 10) == ["123"]

    def test_empty_string(self):
        assert helper_func.string_splitter("", 2) == []

    def test_zero_chunk_raises(self):
        with pytest.raises(ValueError, match="positive integer"):
            helper_func.string_splitter("123", 0)

    def test_negative_chunk_raises(self):
        with pytest.raises(ValueError, match="positive integer"):
            helper_func.string_splitter("123", -1)

    def test_non_integral_chunk_raises(self):
        with pytest.raises(ValueError, match="integer"):
            helper_func.string_splitter("123", 2.5)
        with pytest.raises(ValueError, match="integer"):
            helper_func.string_splitter("123", Decimal("1.5"))
        with pytest.raises(ValueError, match="integer"):
            helper_func.string_splitter("123", Fraction(3, 2))
        with pytest.raises(ValueError, match="integer"):
            helper_func.string_splitter("123", "two")

    def test_non_finite_chunk_raises(self):
        with pytest.raises(ValueError, match="integer"):
            helper_func.string_splitter("123", float("inf"))
        with pytest.raises(ValueError, match="integer"):
            helper_func.string_splitter("123", float("nan"))
        with pytest.raises(ValueError, match="integer"):
            helper_func.string_splitter("123", Decimal("Infinity"))
        with pytest.raises(ValueError, match="integer"):
            helper_func.string_splitter("123", Decimal("NaN"))

    def test_integral_decimal_and_fraction_accepted(self):
        assert helper_func.string_splitter("1234", Decimal("2")) == ["12", "34"]
        assert helper_func.string_splitter("1234", Decimal("2.0")) == ["12", "34"]
        assert helper_func.string_splitter("1234", Fraction(2, 1)) == ["12", "34"]


class TestAddSpaceBetweenString:
    def test_basic(self):
        assert helper_func.add_space_between_string("123") == "1 2 3"

    def test_empty(self):
        assert helper_func.add_space_between_string("") == ""

    def test_coerces_phone_number(self):
        # Phone-number variables may be passed as integers.
        assert helper_func.add_space_between_string(1234) == "1 2 3 4"

    def test_strips_boundary_whitespace(self):
        # Original behaviour: leading/trailing spaces were stripped.
        assert helper_func.add_space_between_string(" a ") == "a"
        assert helper_func.add_space_between_string("  12  ") == "1 2"


class TestConvertIntToSecs:
    def test_returns_timedelta(self):
        result = helper_func.convert_int_to_secs(30)
        assert isinstance(result, timedelta)
        assert result == timedelta(seconds=30)

    def test_zero_seconds(self):
        assert helper_func.convert_int_to_secs(0) == timedelta(seconds=0)

    def test_fractional_seconds_preserved(self):
        # Regression: truncation to int would lose fractional seconds.
        result = helper_func.convert_int_to_secs(0.5)
        assert result == timedelta(seconds=0.5)
        assert result.total_seconds() == 0.5

    def test_float_seconds_preserved(self):
        result = helper_func.convert_int_to_secs(1.25)
        assert result == timedelta(seconds=1.25)

    def test_numeric_string_accepted(self):
        # Regression: Robot passes keyword arguments as strings ("30").
        assert helper_func.convert_int_to_secs("30") == timedelta(seconds=30)


class TestDateFieldFormatter:
    def test_valid_date(self):
        assert helper_func.date_field_formatter("01/01/2026") == "01 / 01 / 2026"

    def test_preserves_exact_spacing(self):
        # Regression guard: output must be "dd / mm / yyyy" with single spaces.
        assert helper_func.date_field_formatter("31/12/2025") == "31 / 12 / 2025"

    def test_invalid_format_raises(self):
        with pytest.raises(ValueError, match="dd/mm/yyyy"):
            helper_func.date_field_formatter("2026-01-01")

    def test_invalid_calendar_date_raises(self):
        with pytest.raises(ValueError, match="invalid calendar date"):
            helper_func.date_field_formatter("31/02/2026")

    def test_non_string_raises(self):
        with pytest.raises(ValueError, match="expects a string"):
            helper_func.date_field_formatter(20260101)


class TestCurrentDateGenerator:
    def test_format(self):
        result = helper_func.current_date_generator()
        assert result == date.today().strftime("%d/%m/%Y")
        assert len(result.split("/")) == 3
