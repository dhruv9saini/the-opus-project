# Étude No. 1: Step 1 source-rework record

This records the first agent attempt, not the current workflow status. The work has since reached agent reconciliation; see `RECONCILIATION.md` and `score.ly`. It remains withdrawn and is not human verified. `attempts/01.ly` contains a source-derived, compiling draft of all 27 printed measures, replacing the historical invented patterns. Entry and syntax are not the same as complete musical verification.

The controlling source is IMSLP file 511615, PDF page 3 (printed page 2), SHA-256 `72acbae8f1c9a683036bb77b5a644387a2e1bb2622728b6b4c2884aca836ee66`. The printed page has three measures in system 1 and four in each of systems 2–7. The same-edition processed IMSLP file 828379 was used only as a visual aid for blurred beams and small symbols; disputed pitches were decided from the controlling scan.

## Work performed

- Entered all seven systems directly from the printed scan, with separate lower-staff voices where the bass sustains through an arpeggio. `tieWaitForNote` draws the ties from arpeggio notes into the following chords.
- Compiled with LilyPond 2.24.3 and rendered a one-page PDF. System breaks now follow the print, permitting side-by-side comparison.
- Corrected the opening one-octave `\fixed` mistake, the 27-measure count, m7's two upper left-hand eighths over a held F-sharp, m21's B–D–F left-hand chord, and the final quarter rest. Recompiled after the edits.
- The scans show no decisive secondary-beam separation in m4, m10, m19, and m23. Their current one-beam groups are encoded provisionally as eighth-note triplets with the tuplet number and bracket hidden. This reproduces the visible grouping and fits common time, but the source does not print a tuplet indication. Do not treat this rhythmic interpretation as settled.
- Added the clearly legible dynamics and several printed fingerings. Every system has received a source inspection and a broad rendered comparison.

## Checks identified during Step 1

| Printed system | Measures | Remaining check |
| --- | ---: | --- |
| 1 | 1–3 | Recheck every small fingering and each lower-staff tie endpoint. |
| 2 | 4–7 | Resolve m4's three-note subdivisions; recheck m7's upper left-hand voice and the exact fingerings. |
| 3 | 8–11 | Resolve the secondary-beam placement in m10; the current unmarked-triplet reading is provisional. |
| 4 | 12–15 | Recheck all left-hand chord pitches, ties, and fingerings, especially m14. |
| 5 | 16–19 | Resolve the visually soft m18 and m19 upper-staff subdivisions; check m17's finger substitution and the left-hand accidentals. |
| 6 | 20–23 | Resolve m23's three-note subdivisions; recheck all lower-staff pitches and fingerings after the m21 correction. |
| 7 | 24–27 | Recheck m27's first left-hand chord and all remaining fingerings. |

The unresolved beam readings prevented removal of `withdrawn` at this stage. The second independent attempt and third-agent reconciliation followed; their current findings are in `RECONCILIATION.md`. No human verification is claimed.
