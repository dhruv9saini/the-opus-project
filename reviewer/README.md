# Human review with ScoreBrush

The OPUS comparison page links to this browser integration of **ScoreBrush 0.1.1**.
No Windows installation, repository clone or LilyPond installation is needed to
proofread. Choose a reconciled work, compare its printed source and rendered
transcription, and use ScoreBrush's Draw and New finding tools.

The site build supplies the selected work's LilyPond and generated PDF, with
their exact hashes, the Git revision when available, and the recorded source
edition hash. If a public library blocks browser downloads, use **Download the
recorded source**, then select that original PDF. A different edition is rejected.
Downloads are bounded to 100 MiB per file and never execute notation or code.

Findings and history save in this browser's ScoreBrush databases. Coverage drafts
save separately for the exact source/code/PDF snapshot; changing revisions never
carries an old coverage claim onto the new revision. They remain
separate from Score Desk's databases in proposed PR #8. Keep downloaded backups;
browser storage is not a shared project submission or a redundant backup.

After reviewing:

1. Use **Save review backup** to retain the actual PDFs, LilyPond and findings.
   ScoreBrush also offers correction ZIPs and returned-revision review.
2. State the pages and passages checked and choose a result.
3. **Download OPUS report** records that coverage, findings and exact checked
   code/PDF/source identities. A report for a returned local revision identifies
   that candidate; it does not incorrectly claim the published build's revision.
4. **Post report to OPUS** opens an editable GitHub Discussion draft. Attach the
   JSON report and review backup, then submit it yourself. Nothing is posted
   automatically. GitHub sign-in is needed only for posting.

A report is evidence for the human reviewer step. It never sets verified_by,
claims complete coverage from a partial check, applies AI changes or publishes
a score. A maintainer must check complete coverage and the exact current
revision before recording human verification. The existing comparison and
discussion remain available.

## Release, source and licensing

This is an **OPUS web integration**, not an official ScoreBrush release.
The vendored browser application is pinned to [ScoreBrush v0.1.1](https://github.com/aug5thmusic/scorebrush/releases/tag/v0.1.1),
commit 0885e414fa00427996501bbb91b805e10831b6c6.
[Exact upstream corresponding source](https://github.com/aug5thmusic/scorebrush/releases/download/v0.1.1/scorebrush-0.1.1.zip)
includes its tests, native host and dependency source materials. The OPUS
repository contains the readable browser runtime and this integration's source.

ScoreBrush is copyright (C) 2026 Auggie (@aug5thmusic), licensed
**AGPL-3.0-or-later**, with [additional permissions](scorebrush/LICENSING.md).
Its [license](scorebrush/LICENSE), [dependency details](scorebrush/DEPENDENCIES.md)
and [third-party notices](scorebrush/THIRD_PARTY_NOTICES.md) are retained.
The repository's CC0 dedication does not cover these files. The opus-bridge.js
adapter is also AGPL-3.0-or-later; the surrounding OPUS adapter files are CC0.

Only two upstream application files are modified: app.js exports an alias
of its existing API for the adapter, and index.html identifies the integration
and loads opus-bridge.js. Upstream storage, validation, PDF handling, brushes,
recovery and decision logic are unchanged. Development-only QA pages are not
published. The scripts/scorebrush_files.json manifest binds every bundled runtime
file to its SHA-256 and original upstream hash. The builder rejects missing,
linked, changed, duplicate or unsafe runtime paths.

The supported Windows release's native folder integration does not run on this
website. Browser folder access depends on the browser; on-page review and
downloaded backups do not need it. Sending a correction ZIP to an external AI
does not impose a sandbox on that AI. Use the project's restricted runner where
available or your agent's own isolation. Source fidelity and human verification
requirements in the OPUS handbook still apply.

## Verification

Run the Python site-packaging tests and Node reviewer tests, followed by the
browser integration test with synthetic PDFs. Tests use a disposable origin and
browser profile, never live review storage. The production site build also
validates the pinned runtime and derives reviewer/works.json from the actual
generated score PDFs.
