"""Generate QR-code images with treepoem.

This module does **not** import ``treepoem`` at import time; the optional
dependency is loaded only when a generation function is actually called.
"""

import argparse
from pathlib import Path


def _require_treepoem():
    """Return the ``treepoem`` module, raising a clear error if missing."""
    try:
        import treepoem
    except ImportError as exc:
        raise RuntimeError(
            "treepoem is required to generate QR codes. "
            "Install the optional dependencies from "
            "tools/examples/requirements-qr.txt and try again."
        ) from exc
    return treepoem


def generate_qr_code(data, output_path, barcode_type="qrcode", eclevel="Q"):
    """Generate a QR code and save it to ``output_path``.

    Args:
        data: The payload to encode in the QR code.
        output_path: Destination file path (string or :class:`pathlib.Path`).
        barcode_type: Barcode symbology passed to treepoem
            (default: ``qrcode``).
        eclevel: Error-correction level passed to treepoem
            (default: ``Q``).

    Returns:
        The absolute :class:`pathlib.Path` where the image was saved.

    Raises:
        RuntimeError: If ``treepoem`` is not installed.
    """
    treepoem = _require_treepoem()
    img = treepoem.generate_barcode(
        barcode_type=barcode_type,
        data=data,
        options={"eclevel": eclevel},
    )
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    img.convert("1").save(str(output_path))
    return output_path.resolve()


def main(argv=None):
    """Command-line entry point."""
    parser = argparse.ArgumentParser(
        description="Generate a QR code image (requires treepoem)."
    )
    parser.add_argument(
        "--data",
        default="https://example.com",
        help="Data to encode in the QR code",
    )
    parser.add_argument(
        "--output",
        "-o",
        default="Output/qr.gif",
        help="Output image path",
    )
    parser.add_argument(
        "--eclevel",
        default="Q",
        help="QR error-correction level (e.g. L, M, Q, H)",
    )
    args = parser.parse_args(argv)
    output_path = generate_qr_code(args.data, args.output, eclevel=args.eclevel)
    print(f"QR code saved to {output_path}")


if __name__ == "__main__":
    main()
