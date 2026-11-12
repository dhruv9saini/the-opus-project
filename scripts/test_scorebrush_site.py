"""Packaging acceptance for the pinned ScoreBrush human-review integration."""
import hashlib
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
import build_site

class ScoreBrushSiteTests(unittest.TestCase):
    def test_real_bundle_is_complete_and_excludes_development_and_user_data(self):
        assets = build_site.scorebrush_assets()
        self.assertGreater(len(assets), 250)
        self.assertIn(Path("reviewer/scorebrush/vendor/pdf.worker.mjs"), assets)
        self.assertIn(Path("reviewer/scorebrush/LICENSE"), assets)
        self.assertFalse(any("qa" in p.parts for p in assets))
        self.assertFalse(any(p.suffix in (".pdf", ".zip") for p in assets))

    def test_combined_build_publishes_both_review_workflows(self):
        # This compiler stub tests packaging only; CI separately requires isolation.
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "site"
            def fixture_pdf(source, target, *, cwd):
                target.write_bytes(b"%PDF-1.4 synthetic packaging fixture")
            with patch.object(build_site.sys, "argv", ["build_site.py", str(output)]), patch.object(build_site, "ensure_available"), patch.object(build_site, "compile_score", side_effect=fixture_pdf):
                self.assertEqual(build_site.main(), 0)
            for path in ("reviewer/index.html", "reviewer/scorebrush/app.js",
                         "reviewer/works.json", "contributor/index.html",
                         "contributor/score/shared-client.js", "contributor/score/shared-config.json"):
                self.assertTrue((output / path).is_file(), path)
            works = json.loads((output / "reviewer/works.json").read_text())["scores"]
            self.assertTrue(works)
            for work in works:
                self.assertEqual(work["render_sha256"], hashlib.sha256(
                    (output / work["pdf_url"]).read_bytes()).hexdigest())
            self.assertFalse((output / "reviewer/tests").exists())
            self.assertFalse((output / "contributor/score/qa").exists())
            self.assertFalse((output / "service").exists())
            self.assertIsNone(json.loads((output / "contributor/score/shared-config.json").read_text())["apiBase"])

    def fake_root(self, directory):
        root = Path(directory)
        (root / "scripts").mkdir()
        runtime = root / "reviewer/scorebrush"
        runtime.mkdir(parents=True)
        (runtime / "test.js").write_bytes(b"// pinned")
        for name in ("index.html", "opus-web.css", "app.mjs", "opus-review.mjs", "README.md"):
            (root / "reviewer" / name).write_text("fixture")
        record = {"path": "test.js", "size": 9, "sha256": hashlib.sha256(b"// pinned").hexdigest()}
        manifest = root / "scripts/scorebrush_files.json"
        manifest.write_text(json.dumps({"schema": 1, "files": [record]}))
        return root, record, manifest

    def test_changed_missing_linked_and_unsafe_runtime_are_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root, record, manifest = self.fake_root(directory)
            asset = root / "reviewer/scorebrush/test.js"
            asset.write_bytes(b"// changed")
            with self.assertRaisesRegex(ValueError, "changed"):
                build_site.scorebrush_assets(root)
            asset.unlink()
            with self.assertRaisesRegex(ValueError, "missing"):
                build_site.scorebrush_assets(root)
            asset.symlink_to(root / "reviewer/index.html")
            with self.assertRaisesRegex(ValueError, "linked"):
                build_site.scorebrush_assets(root)
            for name in ("../escape", "/absolute", "qa/tests.js", "a\\b"):
                manifest.write_text(json.dumps({"schema": 1, "files": [{**record, "path": name}]}))
                with self.assertRaisesRegex(ValueError, "unsafe"):
                    build_site.scorebrush_assets(root)

    def test_copy_has_no_unlisted_user_data_and_refuses_existing_output(self):
        with tempfile.TemporaryDirectory() as directory:
            root, _, _ = self.fake_root(directory)
            (root / "reviewer/scorebrush/private-review.json").write_text("do not publish")
            output = root / "out"
            output.mkdir()
            build_site.copy_reviewer_assets(output, root)
            self.assertTrue((output / "reviewer/scorebrush/test.js").is_file())
            self.assertFalse((output / "reviewer/scorebrush/private-review.json").exists())
            with self.assertRaises(ValueError):
                build_site.copy_reviewer_assets(output, root)

    def test_index_hashes_the_actual_deployed_code_and_pdf(self):
        with tempfile.TemporaryDirectory() as directory:
            out = Path(directory)
            (out / "reviewer").mkdir()
            (out / "pieces/synthetic").mkdir(parents=True)
            (out / "pieces/synthetic/score.ly").write_bytes(b"code bytes")
            (out / "pieces/synthetic/score.pdf").write_bytes(b"render bytes")
            entry = {"slug": "synthetic", "step": 3,
                     "lilypond_url": "pieces/synthetic/score.ly", "pdf_url": "pieces/synthetic/score.pdf"}
            with patch.object(build_site, "load_metadata", return_value={"source_sha256": "b" * 64}):
                build_site.write_reviewer_index(out, [entry])
            result = json.loads((out / "reviewer/works.json").read_text())["scores"][0]
            self.assertEqual(result["code_sha256"], hashlib.sha256(b"code bytes").hexdigest())
            self.assertEqual(result["render_sha256"], hashlib.sha256(b"render bytes").hexdigest())
            self.assertEqual(result["source_sha256"], "b" * 64)

if __name__ == "__main__":
    unittest.main()
