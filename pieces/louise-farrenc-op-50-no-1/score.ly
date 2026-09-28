\version "2.24.3"

% Reconciled candidate from IMSLP #511615, PDF page 3 (printed page 2).
% Compared against attempts/01.ly and attempts/02.ly and rechecked against
% the original scan. This remains pending human proof-reading.
% The small numerals over notes are fingerings. Three-note groups in m10,
% m11, m18–19, m23, and m26–27 have visually unresolved secondary beams in both
% available scans; their metrical 8+16+16 or 16+16+8 readings below are
% provisional, and unmarked eighth-note triplets remain possible. Compare
% each ambiguous group with a better scan before review or publication.

\header {
  title = "Étude No. 1"
  subtitle = "25 Études faciles, Op. 50"
  composer = "Louise Farrenc"
  dedication = "Dédiées à Mes petites Elèves."
  tagline = ##f
}

#(set-default-paper-size "a3")
#(set-global-staff-size 16)

\paper {
  top-margin = 10\mm
  bottom-margin = 10\mm
  left-margin = 12\mm
  right-margin = 12\mm
  ragged-last-bottom = ##f
}

rightHand = \relative e'' {
  \clef treble \time 4/4 \key c \major
  \tempo "Andante grazioso."
  \mark \markup { \italic "Pour bien lier le chant." }
  e4-5\p g,16 c16 e8 d4-4 g,16 b16 d8-3 |
  f4 g,16 d'16 f8-3 e4 c16 e16 g8-1 |
  a4 c,16 f16 a8 g4 c,16 e16 g8-5 |
  f8-4 d16 g,16 e'8-4 c16 g16 e'8-5 c16 g16 d'8 b16 g16 |
  e'4 g,16 c16 e8 d4 g,16 b16 d8 |
  f4 a,16 d16-3 f8-5 e4 a,16 c16 e8-3 |
  a4-5 c,16 es16 a8 g8 e16 c16 e8-4 c16 a16 |
  f'8-5 d16 a16 d8-4 b16 g16 c8-5 g16 e16 r4 |
  d'4 g,16 b16 d8-3 e4 cis16-2 e16 g8 |
  % m10: the scan shows a single beam on each three-note group. In 4/4,
  % hidden/blurred secondary beams (8+16+16, used here) or unmarked
  % eighth-note triplets are possible; neither reading is proven.
  d8-2 b16 d16 b'8 d,16 b16 a'8 d,16 b16 g'8-4 d16 b16 |
  % m11: the subdivision of these descending groups also needs review.
  f'8-5 c16 a16 fis'8-4 c16 a16 d8-4 c16 a16 d8-3 c16 a16 |
  cis4-3 d16-4 b16 g8 d'16 b16 g8 d'16 b16 g8 |
  es'4-3 g,8 bes16 es16 f4 bes,8 d16 f16 |
  g4^\markup { \italic "cresc." } bes,8-1 es16 g16 bes4-5 g,8 bes16 cis16 |
  d4 g,8 b16 d16 e4 fis,8 a16 d16 |
  g,4~ g16 b16 d8 g4~ g16 es16 c8 |
  g4~ g16 f16 d8 es4~ es16 d16 c8 |
  b4~ b16 e16 g8 b8 g16 b16 d8 b16 d16 |
  % m19: descending 3-note beams are another visually unresolved division.
  a'8 d,16 b16 g'8 d16 b16 fis'8 d16 b16 f'8 d16 b16 |
  e4\p g,16 c16 e8 d4 g,16 b16 d8 |
  f4 g,16 d'16 f8 e4 c16 e16 g8 |
  a4 c,16 f16 a8 g4 c,16 e16 g8 |
  % m23: as in m10, secondary beams versus unmarked triplets are unclear.
  f8 d16 g,16 e'8 c16 g16 e'8 c16 g16 d'8 b16 g16 |
  e'4 g,16 c16 e8 d4 g,16 b16 d8 |
  f4^\markup { \italic "cresc." } b,16 d16 f8 e4 a,16 c16 e8 |
  a4 c,16 es16 a8 g8 e16 c16 e8 c16 a16 |
  % m27: three one-beat groups followed by the source's quarter rest;
  % the placement of secondary beams within those groups is provisional.
  f'8 d16 a16 d8 b16 g16 d'8 g,16 e16 r4 \bar "|."
}

leftHand = {
  \clef bass \time 4/4 \key c \major
  \set tieWaitForNote = ##t
  c16-4~ e16~ g8~ <c e g>4 g,16~ d16~ g8~ <g, d g>4 |
  b,16-4~ d16~ g8~ <b, d g>4 c16-4~ e16~ g8~ <c e g>4 |
  d16-4~ f16~ a8~ <d f a>4 e16-5~ g16~ c'8~ <e g c'>4 |
  << { \voiceOne g2 g2 } \\ { \voiceTwo b,4-4 c4 g,2 } >> \oneVoice |
  c16~ e16~ g8~ <c e g>4 g,16~ d16~ g8~ <g, d g>4 |
  d16-4~ f16~ a8~ <d f a>4 a,16~ e16~ a8~ <a, e a>4 |
  << { \voiceOne \set tieWaitForNote = ##t c'8-5~ es'8~ <c' es'>4 } \\ { \voiceTwo fis4~ fis4 } >> \oneVoice <a c' e'>4 <a c' e'>4 |
  <f a d'>4 <g b d'>4 <c' e'>4 d4 |
  g16~ b16~ e'8~ <g b e'>4 g16~ ais16~ cis'8~ <g ais cis'>4 |
  g16~ b16~ e'8~ <g b e'>4 g16~ b16~ e'8~ <g b e'>4 |
  d16~ a16~ c'8~ <d a c'>4 d16~ fis16~ c'8~ <d fis c'>4 |
  g16-4~ b16~ d'8~ <g b d'>4 g16~ b16~ d'8~ <g b d'>4 |
  g16~ bes16~ es'8~ <g bes es'>4 f16~ as16~ c'8~ <f as c'>4 |
  <es g>16~ bes16~ es'8~ <es g bes es'>4 es16~ g16~ bes8~ <es g bes>4 |
  d16~ g16~ b8~ <d g b>4^\markup { \italic "Dim." } d16~ a16~ d'8~ <d a d'>4 |
  g,16 b,16 d8 g4 g,16 d16 es8 g4 |
  g,16 b,16 d8 g4 g,16 d16 es8 g4 |
  g,16 b,16 d8 g4 r2 |
  R1 |
  c16~ e16~ g8~ <c e g>4 g,16~ d16~ f8~ <g, d f>4 |
  a,16~ d16~ f8~ <a, d f>4 c16~ e16~ g8~ <c e g>4 |
  f16~ a16~ c'8~ <f a c'>4 d16~ f16~ c'8~ <d f c'>4 |
  << { \voiceOne g2 g2 } \\ { \voiceTwo b,4 c4 g,2 } >> \oneVoice |
  c16~ e16~ g8~ <c e g>4 g,16~ d16~ f8~ <g, d f>4 |
  gis16-4~ b16~ e'8~ <gis b e'>4 a16-3~ c'16~ e'8~ <a c' e'>4 |
  fis16-5~ c'16~ es'8~ <fis c' es'>4 <g c' e'>4^\markup { \italic "Dim." } <a c' e'>4 |
  <f a d'>4 <g b d'>4 <c' e'>4 c4 \bar "|."
}

\score {
  \new PianoStaff <<
    \new Staff = "right" \rightHand
    \new Staff = "left" \leftHand
  >>
  \layout { }
}
