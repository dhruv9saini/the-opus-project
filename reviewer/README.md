# ScoreBrush Web

ScoreBrush Web is a browser port of **ScoreBrush 0.1.1**, with optional OPUS
score selection and human-review reports. ScoreBrush itself is the main web
application.

## Open your own score

1. Open this page and choose **New Project**.
2. Select the original source PDF, the transcription PDF, and its LilyPond
   source file. These are ordinary browser file pickers.
3. Choose **Open selected files**. Compare the scores, draw marks, and write
   findings. Each new project has its own review identity, even with identical
   inputs.
4. Use **Send to AI** for a correction ZIP and prompt, **Open AI response** or
   **Review Changes** for returned corrections, and **Save backup** to retain
   files, annotations and history.

PDFs are processed locally and reviews autosave in this browser profile.
Save downloaded backups for recovery or transfer. **Restore Backup** accepts
ScoreBrush backup ZIPs. Folder access and Load latest are available when
supported by the browser. The browser app handles PDF viewing and annotation;
LilyPond compilation and AI correction run in your separate tools.

## Review an OPUS score

Choose **OPUS scores & report** inside ScoreBrush, or follow an OPUS work's
**Open ScoreBrush Web** link. The build supplies its current LilyPond and
rendered PDF, their exact hashes, the repository revision when available, and
the recorded source-edition hash.

If a public library blocks automatic downloads, choose **Download the recorded
source**, then select that original PDF. A different edition is rejected.
Downloads are bounded to 100 MiB per file.

Use **OPUS scores & report** again to state the pages and passages checked,
choose a result, and download an OPUS report. Coverage drafts are retained
separately for each exact source/code/PDF snapshot. Save a review backup, then
use **Post report to OPUS** to open an editable GitHub Discussion draft. Attach
both files and submit it. GitHub sign-in is needed for posting.

Reports bind the actual reviewed files, including a returned local candidate.
They do not set verified_by, apply AI changes, claim complete coverage from a
partial check, or publish a score. A maintainer verifies complete coverage
against the exact current revision before recording human verification.
Shared contributions proposed in PR #8 are a separate server integration.

## Release, source and licensing

This is an **OPUS web port**, not an official ScoreBrush release.
The browser runtime is pinned to [ScoreBrush v0.1.1](https://github.com/aug5thmusic/scorebrush/releases/tag/v0.1.1),
commit 0885e414fa00427996501bbb91b805e10831b6c6.
[Exact upstream corresponding source](https://github.com/aug5thmusic/scorebrush/releases/download/v0.1.1/scorebrush-0.1.1.zip)
includes the original tests, native host and dependency source materials.

ScoreBrush is copyright (C) 2026 Auggie (@aug5thmusic), licensed
**AGPL-3.0-or-later**, with [additional permissions](scorebrush/LICENSING.md).
Its [license](scorebrush/LICENSE), [dependency details](scorebrush/DEPENDENCIES.md)
and [third-party notices](scorebrush/THIRD_PARTY_NOTICES.md) are retained.
The ScoreBrush runtime and adapted HTML are excluded from OPUS's CC0 dedication.
Original OPUS adapter code remains CC0 and is included in the combined app
under the applicable AGPL terms. Readable web source is in this repository.

The adapted HTML renders ScoreBrush directly. Three upstream modules have small
changes: app.js exports its existing API; startup.js resolves build metadata
relative to its own script; application-shell.js supports the browser New
Project handler. The OPUS adapter uses the existing storage, validation,
brushes, recovery, PDF handling and decision lifecycle.

The runtime manifest records exact bundled bytes, upstream hashes and the
original HTML identity. The build rejects missing, linked, changed, duplicate
or unsafe runtime paths and excludes QA pages and local review data.
The app's ScoreBrush databases remain separate from the proposed Score Desk
databases.

A correction package cannot impose a sandbox on an arbitrary external AI.
Use the project's restricted runner where available or the agent's own
isolation. OPUS source-fidelity and human-verification requirements still apply.

## Verification

Python packaging tests, Node validation/report tests and browser acceptance
exercise the public entrypoint. Browser tests use synthetic PDFs, a disposable
origin and fresh profiles. They cover standalone file opening and independent
projects, OPUS loading, drawn/text findings, autosave, coverage, report export,
independent backup restore, source recovery and changed-file rejection.

The CI workflow builds the complete deployable site and tests its packaged web
runtime. To run locally, install the pinned test driver with pnpm from
reviewer/tests, set SCOREBRUSH_BROWSER to an installed Chromium/Chrome executable,
and run reviewer/tests/browser.mjs.
