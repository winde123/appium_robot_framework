from datetime import date, datetime, timedelta
from pathlib import Path
from random import Random
import importlib.util
import secrets
import string
import sys

from faker import Faker

# Load the sibling ``cargo_data`` helper without mutating ``sys.path``.
_cargo_data_path = Path(__file__).resolve().parent / "cargo_data.py"
_cargo_spec = importlib.util.spec_from_file_location(
    "manual_field_random._cargo_data", _cargo_data_path
)
cargo_data = importlib.util.module_from_spec(_cargo_spec)
_cargo_spec.loader.exec_module(cargo_data)


def _robot_log(message: str, level: str = "INFO") -> None:
    """Log to Robot Framework when running, otherwise ignore silently.

    The import is guarded so it only happens when Robot is already active;
    importing Robot's BuiltIn library outside a run mutates the global random
    generator, which breaks reproducibility tests.
    """
    if "robot.libraries.BuiltIn" not in sys.modules:
        return
    try:
        from robot.libraries.BuiltIn import BuiltIn
        BuiltIn().log(message, level)
    except Exception:  # noqa: BLE001
        pass


class _ProfileFactory:
    """Seeded, self-contained factory for reproducible profile test data.

    The factory seeds its own Python ``Random`` and ``Faker`` instances so it
    never mutates the global random generators.  A reference date controls
    relative expiry dates, allowing replay by seed + reference date.
    """

    def __init__(self, seed=None, reference_date=None, country=None):
        if isinstance(seed, bool):
            raise TypeError("seed must not be bool")
        if seed is None:
            seed = secrets.randbits(32)
        elif isinstance(seed, str):
            try:
                seed = int(seed)
            except ValueError as exc:
                raise ValueError(
                    f"seed must be an integer or numeric string, got {seed!r}"
                ) from exc
        elif not isinstance(seed, int):
            raise TypeError(
                f"seed must be int, str or None, got {type(seed).__name__}"
            )
        self.seed = seed

        if reference_date is None:
            reference_date = date.today()
        elif isinstance(reference_date, str):
            try:
                reference_date = date.fromisoformat(reference_date)
            except ValueError as exc:
                raise ValueError(
                    f"reference_date must be an ISO date string (YYYY-MM-DD), "
                    f"got {reference_date!r}"
                ) from exc
        elif isinstance(reference_date, datetime):
            raise TypeError(
                "reference_date must be a date, not a datetime; "
                "pass .date() or an ISO date string"
            )
        elif not isinstance(reference_date, date):
            raise TypeError(
                f"reference_date must be date or ISO string, "
                f"got {type(reference_date).__name__}"
            )
        self.reference_date = reference_date

        if country is None:
            country = ""
        elif not isinstance(country, str):
            raise TypeError(
                f"country must be str or None, got {type(country).__name__}"
            )
        self.country = country.upper()

        self._rng = Random(seed)
        self._faker = Faker()
        self._faker.seed_instance(seed)

    # ------------------------------------------------------------------
    # Field generators (formats and checksums match the original code)
    # ------------------------------------------------------------------
    def generate_random_cty_code(self, cty: str = "") -> int:
        country = (cty or self.country).upper()
        if country == "SG":
            return 65
        return self._rng.randrange(1, 999)

    def generate_random_ph_no(self) -> int:
        return self._rng.randrange(1000000, 9999999)

    def generate_random_name(self) -> str:
        random_name = str(self._faker.name())
        random_name = random_name.replace(".", " ")
        random_name = random_name.upper()
        return random_name

    def generate_random_email(self, name: str | None = None) -> str:
        if name is None:
            name = self.generate_random_name()
        return name.replace(" ", "_") + "@" + "test.co"

    def generate_random_dob(self) -> str:
        start_date = date.fromisoformat("1965-01-01")
        end_date = date.fromisoformat("2023-01-01")
        random_date = self._faker.date_between(start_date, end_date)
        return random_date.strftime("%d/%m/%Y")

    def generate_pp_date_exp(self) -> str:
        start_dt = self.reference_date + timedelta(weeks=52)
        end_dt = start_dt + timedelta(weeks=100)
        random_dt = self._faker.date_between(start_dt, end_dt)
        return random_dt.strftime("%d/%m/%Y")

    def generate_random_nric(self) -> str:
        weights = (2, 7, 6, 5, 4, 3, 2)
        lookup_list = ["J", "Z", "I", "H", "G", "F", "E", "D", "C", "B", "A"]
        running_sum = 0
        random_num_string = "S"
        for w in weights:
            random_int = self._rng.randrange(10)
            random_num_string += str(random_int)
            running_sum += random_int * w
        lookup_index = running_sum % 11
        return random_num_string + lookup_list[lookup_index]

    def generate_random_pp_number(self) -> str:
        weights = (2, 7, 6, 5, 4, 3, 2)
        lookup_list = ["E", "D", "B", "A", "H", "K", "N", "P", "R", "Z", "G"]
        running_sum = 0
        random_num_string = "K"
        for w in weights:
            random_int = self._rng.randrange(10)
            random_num_string += str(random_int)
            running_sum += random_int * w
        lookup_index = running_sum % 11
        return random_num_string + lookup_list[lookup_index]

    def generate_random_car_plate_number(self) -> str:
        weights = (10, 15, 14, 15, 16, 17)
        lookup_list = [
            "A", "B", "C", "D", "E", "G", "H", "J", "K", "L",
            "M", "P", "R", "S", "T", "U", "X", "Y", "Z",
        ]
        running_sum = 0
        alpha_starting_char = "S"
        char_seq_list = list(string.ascii_uppercase)
        num_seq_list = list(range(1, 27))
        alphabet_conv_dict = {
            char: num for char, num in zip(char_seq_list, num_seq_list)
        }

        for index, seq_i in enumerate(range(6)):
            if index <= 1:
                random_char = self._rng.choice(string.ascii_uppercase)
                alpha_starting_char = alpha_starting_char + random_char
                running_sum += alphabet_conv_dict[random_char] * weights[seq_i]
            else:
                random_int = self._rng.randrange(10)
                alpha_starting_char += str(random_int)
                running_sum += random_int * weights[seq_i]

        lookup_index = running_sum % 19
        alpha_starting_char += lookup_list[lookup_index]
        return alpha_starting_char

    def generate_foreign_passport_num(self) -> str:
        return self._faker.passport_number()

    # ------------------------------------------------------------------
    # List helpers
    # ------------------------------------------------------------------
    def generate_list_of_dobs(self, n: int) -> list[str]:
        return [self.generate_random_dob() for _ in range(n)]

    def generate_list_of_names(self, n: int) -> list[str]:
        return [self.generate_random_name() for _ in range(n)]

    def generate_list_of_nric(self, n: int) -> list[str]:
        return [self.generate_random_nric() for _ in range(n)]

    def generate_list_of_pp_num(self, n: int) -> list[str]:
        return [self.generate_random_pp_number() for _ in range(n)]

    def generate_list_of_vehno(self, n: int) -> list[str]:
        return [self.generate_random_car_plate_number() for _ in range(n)]

    def generate_list_of_permit(self, n: int) -> list[str]:
        permits = []
        for i in range(n):
            if i < 10:
                permits.append(f"OO5E990000{i}")
            else:
                permits.append(f"OO5E99000{i}")
        return permits

    # ------------------------------------------------------------------
    # Full record
    # ------------------------------------------------------------------
    def to_dict(self) -> dict:
        return {
            "name": self.generate_random_name(),
            "nric": self.generate_random_nric(),
            "dob": self.generate_random_dob(),
            "pp_num": self.generate_random_pp_number(),
            "pp_expiry": self.generate_pp_date_exp(),
            "foreign_pp_num": self.generate_foreign_passport_num(),
            "country": self.country,
            "cty_code": self.generate_random_cty_code(),
            "phno": self.generate_random_ph_no(),
            "email": self.generate_random_email(),
            "seed": self.seed,
            "reference_date": self.reference_date.isoformat(),
        }


# ===================================================================
# Robot-facing keywords
# ===================================================================

def generate_profile_record(seed=None, reference_date=None, country=None) -> dict:
    """Return a fresh profile record with reproducibility metadata.

    The record contains generated fields plus ``seed``, ``reference_date`` and
    ``country`` so the exact same data can be replayed later.
    """
    factory = _ProfileFactory(seed=seed, reference_date=reference_date, country=country)
    record = factory.to_dict()
    _robot_log(
        f"Profile record: seed={record['seed']} "
        f"reference_date={record['reference_date']} "
        f"country={record['country']!r}"
    )
    return record


# ------------------------------------------------------------------
# Backwards-compatible single-field generators (no-argument entry points)
# ------------------------------------------------------------------

def generateRandomCtyCode(cty: str = "") -> int:
    return _ProfileFactory().generate_random_cty_code(cty)


def generateRandomPhNo() -> int:
    return _ProfileFactory().generate_random_ph_no()


def generateRandomName() -> str:
    return _ProfileFactory().generate_random_name()


def generateRandomEmail() -> str:
    return _ProfileFactory().generate_random_email()


def generaterandomDOB() -> str:
    return _ProfileFactory().generate_random_dob()


def generatePPDateExp() -> str:
    return _ProfileFactory().generate_pp_date_exp()


def generaterandomNRIC() -> str:
    return _ProfileFactory().generate_random_nric()


def generaterandomPPNumber() -> str:
    return _ProfileFactory().generate_random_pp_number()


def generaterandomCarPlateNumber() -> str:
    return _ProfileFactory().generate_random_car_plate_number()


def generateForeignPassportNum() -> str:
    return _ProfileFactory().generate_foreign_passport_num()


def generatelistofDOBS(n: int) -> list[str]:
    return _ProfileFactory().generate_list_of_dobs(n)


def generatelistofNames(n: int) -> list[str]:
    return _ProfileFactory().generate_list_of_names(n)


def generatelistofNRIC(n: int) -> list[str]:
    return _ProfileFactory().generate_list_of_nric(n)


def generateListofPPNum(n: int) -> list[str]:
    return _ProfileFactory().generate_list_of_pp_num(n)


def generateListofVehno(n: int) -> list[str]:
    return _ProfileFactory().generate_list_of_vehno(n)


def generateListofPermit(n: int) -> list[str]:
    return _ProfileFactory().generate_list_of_permit(n)


def readfromfile(path: str | None = None) -> list[str]:
    """Compatibility wrapper around ``cargo_data.load_cargo_permits``.

    Enforces a minimum of 100 permits so the 100-permit Android cargo test
    fails loudly when the data file is insufficient, rather than indexing
    past the end of the list.
    """
    return cargo_data.load_cargo_permits(path=path, min_count=100)


def _main():
    profile = generate_profile_record()
    car_num = generaterandomCarPlateNumber()
    nric_ppnum_string = (
        f"{profile['nric']} {profile['pp_num']} "
        f"{car_num} {profile['email']}"
    )
    print(nric_ppnum_string)


if __name__ == "__main__":
    _main()
