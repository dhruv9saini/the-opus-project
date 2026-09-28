# Étude No. 4: agent reconciliation

Status: **candidate; withdrawn from the catalog; not human verified.** The canonical candidate is `score.ly`. The two files in `attempts/` remain the independent drafts, not approved scores.

The musical source is [IMSLP file 511615](https://imslp.org/tools/getindex/511615), PDF page 6, printed page 5. The downloaded PDF's SHA-256 is `72acbae8f1c9a683036bb77b5a644387a2e1bb2622728b6b4c2884aca836ee66`. IMSLP file 828379 is a clearer processed scan of the same printed edition and was used only to clarify blurred noteheads; the original file 511615 controlled the reading. No score-recognition tool or existing digital transcription supplied notes.

The scope is both piano staves, all five printed systems: 20 sounding bars and the two-eighth pickup between repeated sections. Bars 8 and 20 occupy four eighths each; the pickup occupies two. The candidate was compiled with LilyPond 2.26.0; its five-system render was compared with all five source systems, and a targeted correction pass followed. The current layout fits one A4 page at staff size 18.

## Source decisions

| Location | Reconciled reading |
| --- | --- |
| Bars 1–4, right hand | Sixteenth-note batteries and separate dotted-quarter held notes. The held note in bar 4 ends after the first half; the ascending second half has no extra held voice. Bar 3's first low repeated note is B3, its second is C4. Bar 4's first low repeated note is A3. |
| Bars 5–8, left hand | The batteries move to the bass. In bar 5 the first group is D-sharp3–F-sharp3–B3, followed by E3–G3–C4; this was settled from a crop showing all five bass staff lines. Bar 6 also begins D-sharp3. Bar 8 is the short bar before the two-eighth pickup. The printed barline starts a repeat at the pickup; its dots are to the right of the thick line. |
| Bars 9–12 | The bass batteries reach D4 in bars 9–10. Bar 11 has held D5 then C5 above the sixteenths; its first battery descends D5–G4–D4. Bar 12 has a held B4 in the first half only. |
| Bars 13–16, left hand | Sustained bass line G-sharp3/A3, F-sharp3/G3, E3/F-sharp3, then G3 through bar 16. The upper battery notes reach E4, D4, C4, and D4 respectively. |
| Bars 17–20 | The batteries return to the treble. The printed crescendo and diminuendo, melodic ties, shortened final bar, and bass E4 dotted quarter to E3 eighth are represented. The final E3 is in the space between the F3 and D3 bass lines in the original scan. |

## Findings for human review

- PDF page 6, fifth system, bar 20, bass staff: a small filled rectangle hangs below the F3 line while E4 and E3 sound. The candidate renders it as a whole-measure rest in a separate silent bass voice. The shape and position are clear, but the printed page does not establish whether that silent voice continues from an earlier bar. A proofreader should confirm the voice interpretation.
- Fingerings on the repeated figures, especially in printed systems 3–4, need a dedicated mark-by-mark human comparison. The prominent visible fingerings are encoded, but this pass cannot claim every small numeral is present.
- Every sounding note and printed mark still needs the project's independent human comparison before `withdrawn` can be removed or the work can be marked verified.
