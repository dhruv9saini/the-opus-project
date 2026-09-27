#!/usr/bin/env python3
"""Build the deployable static site, including generated score PDFs."""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

from check import ROOT, expected_catalog, render_catalog

PUBLIC_FILES = (
    "index.html",
    "about.html",
    "contribute.html",
    "proofread.html",
    "styles.css",
    "app.js",
    "proofread.js",
    "LICENSE",
)


def fail(message: str) -> None:
    raise ValueError(message)


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: python3 scripts/build_site.py OUTPUT", file=sys.stderr)
        return 2
    output = Path(sys.argv[1]).resolve()
    if output.exists():
        fail(f"output already exists: {output}")
    parent = output.parent
    if not parent.is_dir() or parent.is_symlink():
        fail(f"output parent must be an existing, non-symlink directory: {parent}")

    lilypond = shutil.which("lilypond")
    if not lilypond:
        fail("lilypond is not installed")
    catalog, _ = expected_catalog()

    output.mkdir(mode=0o755)
    for relative in PUBLIC_FILES:
        shutil.copy2(ROOT / relative, output / relative)
    (output / "catalog.json").write_text(render_catalog(catalog), encoding="utf-8")

    for entry in catalog["scores"]:
        source_relative = Path(str(entry["lilypond_url"]))
        source = ROOT / source_relative
        deployed_source = output / source_relative
        deployed_source.parent.mkdir(mode=0o755, parents=True, exist_ok=True)
        shutil.copy2(source, deployed_source)
        output_base = (output / Path(str(entry["pdf_url"]))).with_suffix("")
        result = subprocess.run(
            [
                lilypond,
                "-dno-point-and-click",
                "-o",
                str(output_base),
                str(deployed_source),
            ],
            cwd=output,
            capture_output=True,
            text=True,
            timeout=120,
            check=False,
        )
        if result.returncode:
            detail = (result.stdout + result.stderr)[-4000:]
            fail(f"{source_relative}: LilyPond failed\n{detail}")
        pdf = output / Path(str(entry["pdf_url"]))
        if not pdf.is_file() or pdf.stat().st_size == 0:
            fail(f"{source_relative}: LilyPond did not produce {pdf}")

    print(f"built {len(catalog['scores'])} works in {output}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ValueError, OSError, subprocess.TimeoutExpired) as error:
        print(f"error: {error}", file=sys.stderr)
        raise SystemExit(1)
