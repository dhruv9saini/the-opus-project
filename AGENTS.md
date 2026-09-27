# Working on The OPUS Project

Your job is to turn printed public-domain scores into reviewed LilyPond. Do the work directly; do not ask the contributor to know notation software.

## If the prompt names a piece

1. Find the work under `pieces/`. If it is absent, add it using a clearly printed, public-domain edition from IMSLP or another stable public library. Do not use a manuscript or handwritten source.
2. Read `metadata.json`, then inspect the exact source PDF visually. Never commit the PDF, MusicXML, MIDI, or another notation format.
3. If `step` is below 3 and fewer than two attempt files exist, create the next `attempts/0N.ly`. Make it independently from the printed source: do not read the musical contents of the earlier attempt first. Steps 1 and 2 must be completed by different agents.
4. If `step` is 2 and two attempts exist, act as the third agent. Compare both attempts measure by measure with the printed source, resolve every disagreement, and write the canonical `score.ly`. If `step` is already 3, choose another work; the remaining verification is for a human.
5. Set `step` in `metadata.json` to the completed agent step, append the exact model identifier to `models`, and leave `verified_by` as `null`. Run `python3 scripts/check.py --write`, fix every failure, and summarize the exact work completed. A human proofreader verifies the reconciled score later.

## If the prompt just says to help

Choose work in this order: repair a work marked `withdrawn` in its metadata; reconcile a work with two attempts; add a missing attempt to an existing work; then add a printed public-domain work from `wanted.txt`. Continue with another bounded piece if the contributor asked you to keep going. For a withdrawn work, replace the invalid attempt from the printed source and remove `withdrawn` only after a full measure-by-measure visual comparison; do not advance to the next agent step while the attempt is invalid.

## Non-negotiable rules

- LilyPond (`.ly`) is the only notation source format.
- Transcribe directly and visually from the printed source into LilyPond. Audiveris and every other OMR/OCR, score-recognition, audio-to-score, PDF-to-score, MusicXML-to-LilyPond, or MIDI-to-LilyPond tool or service are forbidden.
- Do not obtain notes from an existing digital transcription in any format. The printed edition named in `metadata.json` is the sole musical source for Steps 1 and 2.
- Steps 1 and 2 are independent transcriptions by different agents. Step 3 is a third agent's reconciliation against the printed source. Human verification follows Step 3.
- Use printed public-domain sources only. Record the source page, a browser-openable direct PDF URL, library identifier, and SHA-256 digest.
- Do not commit downloaded scans or generated PDFs.
- Keep one work per pull request unless the contributor explicitly asks for a batch.
- Every agent transcription pull request body must include `Step: N/3`, `Model: provider/exact-model-id`, and the printed `Source: https://…` URL. A human verification pull request instead uses `Review: human`, `Proofreader: @github-name`, and `Source: https://…`.
- Preserve editorial details visible in the source: pitches, rhythm, voices, articulations, dynamics, text, repeats, clefs, and page turns when practical.
- A file compiling is necessary, not proof that the music is correct. Compare the rendered result with the printed source.

## Cleanup and disk use

- Never delete caches to satisfy a cleanup or disk-usage requirement. This includes package-manager, browser, compiler, model, font, shader, thumbnail, and application caches.
- Cleanup may remove only proven junk that is large in both senses: it consumes substantial allocated bytes, and it contains enough files or directories to create meaningful navigational or inode clutter.
- Before deletion, measure the exact candidate's allocated bytes and complete entry count, verify that it is inactive and disposable, and prove that it is not source, user data, credentials, a Codex transcript, runtime state, or unknown work.
- Prefer abandoned generated trees, redundant disposable copies, and obsolete project artifacts whose consumers have already been verified against the retained replacement.
- If no candidate satisfies all of these conditions, report that no safe qualifying junk was found. Do not substitute caches, useful data, or a large number of small unrelated deletions merely to produce a favorable disk delta.
