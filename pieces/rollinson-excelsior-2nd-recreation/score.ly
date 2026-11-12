\version "2.24.3"

% Step 3: both independent attempts reconciled visually against
% LOC2023842814, PDF page 25 / printed page 23, complete 16-bar work.
% Historical fingering is retained: x is the thumb, digits are 1–4.
\header {
  title = "2nd Recreation"
  subtitle = "Waltz · Excelsior Method for the Reed Organ"
  composer = "Composer uncredited"
  arranger = "Edited and compiled by T. H. Rollinson"
  copyright = "Transcription: CC0 1.0 · J. W. Pepper edition, copyright 1881"
  tagline = "The OPUS Project · Agent reconciliation · Human verification pending"
}

thumb = \finger \markup \normal-text "x"
pairTwo = \finger \markup \normal-text \override #'(baseline-skip . 1.6) \center-column { "x" "2" }
pairOne = \finger \markup \normal-text \override #'(baseline-skip . 1.6) \center-column { "x" "1" }
adjacentPair = \finger \markup \normal-text "1 x"

global = { \key g \major \time 3/4 }

upper = \absolute {
  \global \clef treble
  \override Fingering.direction = #UP
  \tempo "WALTZ."
  % Source system 1, measures 1–8.
  b'2.-2~ |
  b'4 a'4 b'4 |
  c''2.-3( |
  fis'2.-1) |
  c''2.-3~ |
  c''4 b'4 c''4 |
  d''2.-4( |
  g'2.\thumb) | \break
  % Source system 2, measures 9–16.
  e''2.-2 |
  fis''2-3 e''4 |
  d''2.-1~ |
  d''4 b'4\thumb g'4-1 |
  b'2.-3 |
  a'2-2 d'4\thumb |
  g'2.-2~ |
  g'4 r4 r4 \bar "|."
}

lower = \absolute {
  \global \clef bass
  \override Fingering.direction = #UP
  % Source system 1, measures 1–8.
  g4-4 <b d'>4\pairTwo <b d'>4 |
  g4 <b d'>4 <b d'>4 |
  fis4-4 <c' d'>4\adjacentPair <c' d'>4 |
  d4-4 <a c'>4\pairOne <a c'>4 |
  d4-4 <fis a>4\pairTwo <fis a>4 |
  d4 <fis a>4 <fis a>4 |
  b,4-4 <d g>4\pairTwo <d g>4 |
  b,4 <d g>4 <d g>4 |
  % Source system 2, measures 9–16.
  c4-4 <e a>4\pairTwo <e a>4 |
  c4 <e a>4 <e a>4 |
  d4-4 <g b>4\pairOne <g b>4 |
  d4 <g b>4 <g b>4 |
  d4-4 <a c'>4\pairOne <a c'>4 |
  d4 <a c'>4 <a c'>4 |
  g4-4 <b d'>4\pairTwo <b d'>4 |
  <g b d'>4 r4 r4 \bar "|."
}

expression = {
  \override Hairpin.to-barline = ##f
  s2.\p |
  s4 s2\< |
  s4\! s2 |
  s2.*3 |
  \once \override Hairpin.to-barline = ##t
  s2.\< |
  s2.\! |
  s2.\f |
  s2.*3 |
  s4 s2\> |
  s2 s4\! |
  s2.\p |
  s2. |
}

\paper {
  #(set-paper-size "a4")
  indent = 0\mm
  ragged-last = ##f
  system-count = 2
}

\score {
  \new PianoStaff <<
    \new Staff = "upper" \upper
    \new Dynamics \expression
    \new Staff = "lower" \lower
  >>
  \layout { }
}
