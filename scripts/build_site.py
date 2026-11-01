#!/usr/bin/env python3
"""Build the deployable static site, including generated score PDFs."""

from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path

from check import PIECES, ROOT, expected_catalog, load_metadata, render_catalog

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


def scorebrush_assets(root: Path | None = None) -> dict[Path, Path]:
    """Publish only the exact pinned ScoreBrush runtime, never QA or local data."""
    root = ROOT if root is None else root
    manifest = json.loads((root / "scripts/scorebrush_files.json").read_text(encoding="utf-8"))
    if manifest.get("schema") != 1 or not isinstance(manifest.get("files"), list) or not manifest["files"]:
        fail("invalid ScoreBrush runtime manifest")
    names = set()
    assets = {}
    for record in manifest["files"]:
        name = record.get("path")
        if (not isinstance(name, str) or not name or chr(92) in name or ":" in name
                or name.startswith("/") or any(part in ("", ".", "..") for part in name.split("/"))
                or name.casefold() in names or "qa" in name.split("/")):
            fail("unsafe or duplicate ScoreBrush runtime path")
        names.add(name.casefold())
        relative = Path("reviewer/scorebrush") / name
        source = root / relative
        if any(root.joinpath(*relative.parts[:i]).is_symlink() for i in range(1, len(relative.parts) + 1)):
            fail(f"linked ScoreBrush runtime asset: {name}")
        if (not source.is_file() or source.stat().st_size != record.get("size")
                or hashlib.sha256(source.read_bytes()).hexdigest() != record.get("sha256")):
            fail(f"missing or changed ScoreBrush runtime asset: {name}")
        assets[relative] = source
    for name in ("index.html", "style.css", "app.mjs", "opus-review.mjs", "README.md"):
        relative = Path("reviewer") / name
        source = root / relative
        if not source.is_file() or source.is_symlink():
            fail(f"missing or linked OPUS reviewer asset: {name}")
        assets[relative] = source
    return assets


def copy_reviewer_assets(output: Path, root: Path | None = None) -> None:
    assets = scorebrush_assets(root)
    if not output.is_dir() or output.is_symlink() or (output / "reviewer").exists() or (output / "reviewer").is_symlink():
        fail("reviewer output must be a new directory in an existing output")
    for relative, source in assets.items():
        target = output / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)


def write_reviewer_index(output: Path, entries: list[dict]) -> None:
    """Bind human review to the source edition and the actual deployed bytes."""
    result = subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT, capture_output=True, text=True, timeout=10, check=False)
    revision = result.stdout.strip() if result.returncode == 0 else None
    scores = []
    for entry in entries:
        if entry["step"] != 3:
            continue
        metadata = load_metadata(PIECES / entry["slug"] / "metadata.json")
        scores.append({**entry, "source_sha256": metadata["source_sha256"],
                       "code_sha256": hashlib.sha256((output / entry["lilypond_url"]).read_bytes()).hexdigest(),
                       "render_sha256": hashlib.sha256((output / entry["pdf_url"]).read_bytes()).hexdigest(),
                       "revision": revision})
    (output / "reviewer/works.json").write_text(
        json.dumps({"schema": 1, "scores": scores}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def review_queue() -> dict[str, object]:
    entries: list[dict[str, object]] = []
    for metadata_path in sorted(PIECES.glob("*/metadata.json")):
        data = load_metadata(metadata_path)
        if data["step"] != 3 or not data.get("withdrawn", False):
            continue
        source_relative = (metadata_path.parent / "score.ly").relative_to(ROOT).as_posix()
        entries.append({
            "slug": data["slug"],
            "title": data["title"],
            "composer": data["composer"],
            "catalogue": data["catalogue"],
            "step": data["step"],
            "verified_by": None,
            "lilypond_url": source_relative,
            "pdf_url": str(Path(source_relative).with_suffix(".pdf")),
            "source_page": data["source_page"],
            "source_pdf": data["source_pdf"],
            "crosscheck_name": data["crosscheck_name"],
            "crosscheck_url": data["crosscheck_url"],
            "draft": True,
        })
    return {"schema": 1, "scores": entries}


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
    reviews = review_queue()
    scorebrush_assets()

    output.mkdir(mode=0o755)
    for relative in PUBLIC_FILES:
        shutil.copy2(ROOT / relative, output / relative)
    copy_reviewer_assets(output)
    (output / "catalog.json").write_text(render_catalog(catalog), encoding="utf-8")
    (output / "reviews.json").write_text(render_catalog(reviews), encoding="utf-8")

    for entry in [*catalog["scores"], *reviews["scores"]]:
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

    write_reviewer_index(output, [*catalog["scores"], *reviews["scores"]])

    print(f"built {len(catalog['scores'])} catalog works and {len(reviews['scores'])} review drafts in {output}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ValueError, OSError, subprocess.TimeoutExpired) as error:
        print(f"error: {error}", file=sys.stderr)
        raise SystemExit(1)
