\version "2.24.3"

% Step 2: independent visual transcription from the printed page only.
% Source: LOC 2023842814, J. W. Pepper Excelsior Method,
% PDF page 25 / printed page 23; complete 2nd Recreation.
% The printed thumb is x; 1--4 refer to the remaining fingers.

\header {
  title = "2nd Recreation"
  subtitle = "Excelsior Method for the Reed Organ"
  composer = "Composer uncredited"
  arranger = "Edited and compiled by T. H. Rollinson"
  copyright = "Transcription: CC0 1.0 · J. W. Pepper edition, copyright 1881"
  tagline = "The OPUS Project · Independent transcription 2 · Human verification pending"
}

thumb = \finger \markup \normal-text "×"

trebleMusic = \absolute {
  \key g \major
  \time 3/4
  \clef treble
  \override Fingering.direction = #UP
  \tempo "WALTZ."
  % Source system 1.
  b'2.-2~ |
  b'4 a'4 b'4 |
  c''2.-3( |
  e'2.-1) |
  c''2.-3~ |
  c''4 b'4 c''4 |
  d''2.-4( |
  g'2.\thumb) | \break
  % Source system 2.
  e''2.-2 |
  fis''2-3 e''4 |
  d''2.-1~ |
  d''4 c''4\thumb b'4-1 |
  b'2.-3 |
  a'2-2 d'4\thumb |
  g'2.-2~ |
  g'4 r4 r4 \bar "|."
}

bassMusic = \absolute {
  \key g \major
  \time 3/4
  \clef bass
  \override Fingering.direction = #UP
  \set fingeringOrientations = #'(up)
  % Source system 1.
  g4-4 <b-2 d'\thumb>4 <b d'>4 |
  g4 <b d'>4 <b d'>4 |
  fis4-4 <c'-1 d'\thumb>4 <c' d'>4 |
  d4-4 <a-1 c'\thumb>4 <a c'>4 |
  d4-4 <fis-2 a\thumb>4 <fis a>4 |
  d4 <fis a>4 <fis a>4 |
  b,4-4 <d-2 a\thumb>4 <d a>4 |
  b,4 <d a>4 <d a>4 |
  % Source system 2.
  c4-4 <e-2 a\thumb>4 <e a>4 |
  c4 <e a>4 <e a>4 |
  d4-4 <g-1 b\thumb>4 <g b>4 |
  d4 <g b>4 <g b>4 |
  d4-4 <g-1 c'\thumb>4 <g c'>4 |
  d4 <g c'>4 <g c'>4 |
  g4-4 <b-2 d'\thumb>4 <b d'>4 |
  <g b d'>4 r4 r4 \bar "|."
}

expression = {
  s2.\p |
  s4 s2\< |
  s4\! s2 |
  s2. |
  s2. |
  s2. |
  s2.\< |
  s2.\! |
  s2.\f |
  s2. |
  s2. |
  s2. |
  s4 s2\> |
  s2 s4\! |
  s2.\p |
  s2. |
}

\paper {
  #(set-paper-size "a4")
  indent = 0\mm
  ragged-last = ##f
  ragged-bottom = ##t
  system-system-spacing.basic-distance = #28
}

\score {
  \new PianoStaff <<
    \new Staff = "treble" \trebleMusic
    \new Dynamics \expression
    \new Staff = "bass" \bassMusic
  >>
  \layout { }
  \midi { }
}
