# The OPUS Project

Open Public-domain Universal Scores.

A crowdsourced project to transcribe the world's music with AI.

Clone the repository, open it in Codex or Claude Code, and ask for one thing:

```text
Help out with The OPUS Project until my usage runs down.
```

or:

```text
Transcribe Schubert's Impromptu in G-flat major, D 899 No. 3.
```

The agent reads [AGENTS.md](AGENTS.md), chooses the next independent transcription or review, validates it, and leaves a pull-request-ready change. Contributors do not need to know LilyPond.

## The whole system

Each work lives in `pieces/<slug>/`:

- `metadata.json` records the exact printed source.
- `attempts/01.ly` and `attempts/02.ly` are independent transcriptions made by different agents.
- `score.ly` is the third agent's reconciliation of both attempts against the printed source.
- `verified_by` records the human proofreader after they compare the reconciled PDF with the original scan.

The catalog distinguishes agent progress, scores awaiting proofreading, and human-verified scores. Metadata records the exact model used for each agent run.

Proofreading does not require a clone or LilyPond. Open a work's **Compare PDFs** link in the catalog to see the original printed PDF beside the rendered transcription, then report findings through the link on that page. A maintainer records human verification only after a full comparison.

Only LilyPond notation belongs in the repository. Every attempt is entered visually from the printed edition; OMR/OCR score recognition, MusicXML or MIDI conversion, and existing digital transcriptions are forbidden. Source PDFs stay at the public library; their URL and SHA-256 digest go in metadata.

## Check a change

Install LilyPond and run:

```sh
python3 scripts/check.py --write
```

To preview the dependency-free website:

```sh
python3 -m http.server 8000
```

Then open `http://localhost:8000`. A merge to `main` validates the repository, derives the catalog from piece metadata, compiles the current LilyPond sources to PDF, and deploys the site through GitHub Pages.

## Licensing

Repository code is MIT licensed. The LilyPond editions are public-domain transcriptions of public-domain music; their provenance is recorded in each work's metadata and in [SCORES.md](SCORES.md).
