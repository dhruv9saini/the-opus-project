\version "2.24.3"

% Independent Step 2, visually entered from LOC2023842814,
% PDF page 29 (printed page 27), all four systems of 4th Recreation.
\header {
  title = "4th Recreation"
  subtitle = "The Excelsior Organ Method · printed page 27"
  composer = "Uncredited; T. H. Rollinson, editor/compiler"
  tagline = "The OPUS Project · CC0 · Agent transcription; human verification pending"
}
\paper { #(set-paper-size "a4") }

thumb = \markup \normal-text \fontsize #-2 "×"

right = {
  \clef treble \key d \major \time 4/4
  \tempo "Andante"
  % Source system 1.
  fis'4.-2 g'8 fis'4 e'4 |
  d'4. e'8 d'4 fis'4 |
  a'4 e'4 a'4 g'4 |
  fis'2. a'4-3 | \break
  % Source system 2.
  b'8-4[ g'-2 d'_\thumb g'-2] b'-4[ d'_\thumb b'-4 g'-2] |
  a'8-3[ fis'-1 d'_\thumb fis'-1] a'-3[ d'_\thumb fis'-1 d'_\thumb] |
  b'8-4[ a' g' fis'] e'_\thumb[ fis'-1 g'-2 gis'-3] |
  a'2.-4 g'4 | \break
  % Source system 3.
  fis'8-2[ a'-4 a'-4 a'-4] g'-3[ a' e' a'] |
  e'8[ a' a' a'] fis'[ a' a' a'] |
  a'2 a'4 g'4 |
  fis'2. a'4 | \break
  % Source system 4.
  b'8[ g' d' g'] b'[ d' a' d'] |
  g'8[ d' d' d'] g'4 fis'4 |
  e'4 g'4 a'8[ g' fis' e'] |
  d'2~ d'4 r4
  \bar "|."
  \textEndMark \markup \musicglyph "scripts.ufermata"
}

left = {
  \clef bass \key d \major \time 4/4
  % Source system 1.
  d8-4[ a^\thumb a^\thumb a^\thumb] d[ a a a] |
  fis8[ a a a] fis[ a d a] |
  cis8-4[ a^\thumb a^\thumb a^\thumb] e-3[ a^\thumb a a] |
  d8[ a a a] d[ a fis d] |
  % Source system 2.
  g2-1 g4 e4-3 |
  fis2-2 fis4 d4-4 |
  g2-1 e2-3 |
  a8^\thumb[ gis-1 a^\thumb b-1] a^\thumb[ gis-1 fis-2 e-3] |
  % Source system 3.
  d2 e4 d4 |
  cis2 d2 |
  fis8[ a a a] fis[ a cis-4 a] |
  d8-4[ a a a] d[ a fis d] |
  % Source system 4.
  g2 g4 fis4 |
  b2^\thumb b4 a4 |
  g4-2 e4 a2^\thumb |
  d8([ a fis a] d4) r4
}

\score {
  \new PianoStaff <<
    \new Staff = "upper" \right
    \new Staff = "lower" \left
  >>
  \layout { }
}
