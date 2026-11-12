\version "2.24.3"

% Step 1: entered directly from the printed J. W. Pepper edition.
% Sole musical source: LOC 2023842814, PDF page 29 / printed page 27.
% The printed fingering system uses x for the thumb and 1--4 for fingers.
% No individual composer is named for this recreation.

\header {
  title = "4th Recreation"
  subtitle = "Excelsior Method for the Reed Organ"
  composer = "Composer uncredited"
  arranger = "Edited and compiled by T. H. Rollinson"
  copyright = "Transcription: CC0 1.0 · Source edition: J. W. Pepper, copyright 1881"
  tagline = "The OPUS Project · Independent transcription 1 · Human verification pending"
}

thumb = \finger \markup \normal-text "×"

rightHand = \absolute {
  \clef treble
  \key d \major
  \time 4/4
  \override Fingering.direction = #DOWN
  \tempo "Andante"
  % Source system 1, measures 1--4.
  fis'4.-2 g'8 fis'4 e'4 |
  d'4. e'8 d'4 fis'4 |
  a'4 d'4 a'4 g'4 |
  fis'2. a'4-3 | \break
  % Source system 2, measures 5--8.
  b'8-4[ g'-2 d'\thumb g'-2] b'-4[ d'\thumb b'-4 g'-2] |
  a'8-3[ fis'-1 cis'\thumb fis'-1] a'-3[ cis'\thumb fis'-1 cis'\thumb] |
  b'8-4[ a' g' fis'] e'\thumb[ fis'-1 g'-2 gis'-3] |
  a'2.-4 g'4 | \break
  % Source system 3, measures 9--12.
  fis'8-2[ a'-4 a'-4 a'-4] g'-3[ a' e' a'] |
  e'8[ a' a' a'] fis'[ a' a' a'] |
  a'2 a'4 g'4 |
  fis'2. a'4 | \break
  % Source system 4, measures 13--16.
  b'8[ g' d' g'] b'[ d' a' d'] |
  a'8[ e' e' e'] a'4 fis'4 |
  e'4 g'4 a'8[ g' fis' e'] |
  d'2~ d'4 r4 \bar "|."
  \once \override Score.RehearsalMark.self-alignment-X = #CENTER
  \once \override Score.RehearsalMark.break-visibility = #end-of-line-visible
  \mark \markup \musicglyph "scripts.ufermata"
}

leftHand = \absolute {
  \clef bass
  \key d \major
  \time 4/4
  \override Fingering.direction = #UP
  % Source system 1, measures 1--4.
  d8-4[ a\thumb a\thumb a\thumb] d[ a a a] |
  fis8[ a a a] fis[ a d a] |
  cis8-4[ a\thumb a\thumb a\thumb] e-3[ a\thumb a a] |
  d8[ a a a] d[ a fis d] |
  % Source system 2, measures 5--8.
  a2-1 a4 fis4-3 |
  fis2-2 fis4 d4-4 |
  g2-1 e2-3 |
  a8\thumb[ gis-1 a\thumb b-1] a\thumb[ g!-1 fis-2 e-3] |
  % Source system 3, measures 9--12.
  e2 e4 d4 |
  cis2 d2 |
  fis8[ a a a] fis[ a d-4 a] |
  d8-4[ a a a] d[ a fis d] |
  % Source system 4, measures 13--16.
  g2 g4 fis4 |
  b2\thumb b4 a4 |
  g4-2 e4 a2\thumb |
  d8( [ a fis a] ) d4 r4 \bar "|."
}

\paper {
  #(set-paper-size "a4")
  indent = 0\mm
  ragged-last = ##f
  system-system-spacing.basic-distance = #24
}

\score {
  \new PianoStaff <<
    \new Staff = "right" \rightHand
    \new Staff = "left" \leftHand
  >>
  \layout { }
  \midi { }
}
