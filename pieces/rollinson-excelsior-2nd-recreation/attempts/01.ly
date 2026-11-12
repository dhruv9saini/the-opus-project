\version "2.24.3"

% Step 1: direct visual transcription of the printed page.
% Sole musical source: LOC2023842814, PDF page 25, printed page 23.
% Historical fingering is preserved: x denotes the thumb, digits run 1–4.
\header {
  title = "2nd Recreation"
  subtitle = "Waltz · Excelsior Method for the Reed Organ"
  composer = "Composer unidentified"
  arranger = "Compiled by T. H. Rollinson"
  tagline = "The OPUS Project · Agent transcription · Human verification pending"
}

global = { \key g \major \time 3/4 }

upper = \absolute {
  \global
  \clef treble
  \override Fingering.direction = #UP
  \tempo "WALTZ."
  b'2.-2( |
  b'4) a'4 b'4\< |
  c''2.-3(\! |
  fis'2.-1) |
  c''2.-3( |
  c''4) b'4 c''4 |
  d''2.-4(\< |
  g'2.-\finger \markup \normal-text "x")\! |
  \break
  e''2.-2 |
  fis''2-3 e''4 |
  d''2.-1( |
  d''4) b'4-\finger \markup \normal-text "x" g'4-1 |
  b'2.-3\> |
  a'2-2 d'4-\finger \markup \normal-text "x"\! |
  g'2.-2( |
  g'4) r4 r4 \bar "|."
}

lower = \absolute {
  \global
  \clef bass
  \override Fingering.direction = #UP
  g4-4 <b d'>4-\finger \markup \normal-text \override #'(baseline-skip . 1.6) \center-column { "x" "2" } <b d'>4 |
  g4 <b d'>4 <b d'>4 |
  fis4-4 <c' d'>4-\finger \markup \normal-text \override #'(baseline-skip . 1.6) \center-column { "x" "1" } <c' d'>4 |
  d4-4 <a c'>4-\finger \markup \normal-text \override #'(baseline-skip . 1.6) \center-column { "x" "1" } <a c'>4 |
  d4-4 <fis a>4-\finger \markup \normal-text \override #'(baseline-skip . 1.6) \center-column { "x" "2" } <fis a>4 |
  d4 <fis a>4 <fis a>4 |
  b,4-4 <d g>4-\finger \markup \normal-text \override #'(baseline-skip . 1.6) \center-column { "x" "2" } <d g>4 |
  b,4 <d g>4 <d g>4 |
  c4-4 <e a>4-\finger \markup \normal-text \override #'(baseline-skip . 1.6) \center-column { "x" "2" } <e a>4 |
  c4 <e a>4 <e a>4 |
  d4-4 <g b>4-\finger \markup \normal-text \override #'(baseline-skip . 1.6) \center-column { "x" "1" } <g b>4 |
  d4 <g b>4 <g b>4 |
  d4-4 <a c'>4-\finger \markup \normal-text \override #'(baseline-skip . 1.6) \center-column { "x" "1" } <a c'>4 |
  d4 <a c'>4 <a c'>4 |
  g4-4 <b d'>4-\finger \markup \normal-text \override #'(baseline-skip . 1.6) \center-column { "x" "2" } <b d'>4 |
  <g b d'>4 r4 r4 \bar "|."
}

dynamics = {
  s2.\p s2.*7
  s2.\f s2.*5
  s2.\p s2.
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
    \new Dynamics \dynamics
    \new Staff = "lower" \lower
  >>
  \layout { }
  \midi { \tempo 4 = 120 }
}
