# OPUS@Home for Mac

OPUS@Home is a menu bar app that contributes to The OPUS Project with your own Codex or Claude Code subscription. Turn it on, and while your Mac is charging it runs your agent in the background. Each run handles one piece of work from [AGENTS.md](../AGENTS.md), such as a new transcription attempt, a reconciliation, or a work from `wanted.txt`, and opens a pull request from your GitHub account.

## Install

1. Download `OPUS-at-Home.zip` from the [latest build](https://github.com/the-opus-project/the-opus-project.github.io/releases/tag/opus-at-home-latest) and unzip it.
2. Move **OPUS@Home** to Applications and open it. The app is not notarized yet, so macOS blocks the first launch. Open **System Settings > Privacy & Security** and click **Open Anyway**. Or run `xattr -dr com.apple.quarantine "/Applications/OPUS@Home.app"`.
3. Click the music note in the menu bar. Under **Setup needed**, copy and run each command it lists:
   - Git and Python: `xcode-select --install`
   - GitHub CLI: `brew install gh && gh auth login`
   - Codex (`brew install --cask codex && codex login`) or Claude Code (`curl -fsSL https://claude.ai/install.sh | bash`, then run `claude` once to sign in)
   - LilyPond: `brew install lilypond`
4. Switch it on.

macOS 14 or later is required.

## When it runs

All conditions can be changed in **Settings**:

- **Only while charging** (on by default). If you unplug, the current run stops and its partial work is discarded.
- **Only after N minutes idle** (off by default).
- **Usage limits.** By default it uses only quota that would otherwise go unused: it starts within 24 hours of your weekly reset and stops when the weekly limit runs out. Alternatively, it can run any time up to a weekly cap you choose, such as 50%. In both modes it pauses when the 5-hour limit reaches 90%.

It reads your remaining usage from Codex (`codex app-server`) or from Claude Code's sign-in, and checks again every 5 minutes during a run. A run stops when weekly usage reaches 98% (or your cap in "any time" mode), when the 5-hour limit reaches its cap, or when the agent reports its limit is reached. That way it never moves on to paid Codex credits or extra usage. Usage-based API keys report no weekly limit, so use the "any time" mode with them.

Each run has a time limit (120 minutes by default). While a run is active, the Mac does not go to sleep.

## What a run does

1. Updates its own copy of the repository in `~/Library/Application Support/OPUS@Home/repo`. Your other clones are never touched.
2. Lists pieces that already have open pull requests, or that you worked on before, and tells the agent to skip them. Steps 1, 2 and 3 must come from different contributors.
3. Runs the agent without supervision:
   - **Codex:** `codex exec --sandbox workspace-write` with network access, so it can download scans.
   - **Claude Code:** `claude -p --permission-mode bypassPermissions`. Claude Code runs commands without asking, so use it only on a Mac where that is acceptable.
4. Keeps only LilyPond files and `metadata.json` under `pieces/`, plus `wanted.txt` and the regenerated `catalog.json`, so pull requests contain scores only. It checks that the agent wrote the `Source`, `Step` and `Model` lines.
5. Commits the work, pushes it to your fork (created on the first run), and opens a pull request. GitHub runs the full score check.

The **Log** button opens the latest run's full transcript. Recent runs and their pull requests are listed in the menu.

## Command line

The app binary also works from Terminal, which is useful for testing:

```sh
"/Applications/OPUS@Home.app/Contents/MacOS/OPUSAtHome" --status
"/Applications/OPUS@Home.app/Contents/MacOS/OPUSAtHome" --run-once --no-pr --agent codex
```

`--status` shows setup, power state, current usage, and whether a run would start now. `--run-once` ignores the schedule. With `--no-pr`, the work is committed only on a local branch.

## Build

On a Mac with Xcode or the Command Line Tools:

```sh
mac/build.sh
```

This produces `mac/dist/OPUS-at-Home.zip`, a universal app signed with an ad-hoc signature. The `opus-at-home` workflow builds, tests and screenshots the app on every change. On `main`, it publishes the `opus-at-home-latest` release.
