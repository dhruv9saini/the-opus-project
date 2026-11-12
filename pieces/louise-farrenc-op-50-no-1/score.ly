\version "2.24.3"

% Reconciled candidate from IMSLP #511615, PDF page 3 (printed page 2).
% Rechecked against a separate, high-resolution photograph of the same
% Leduc plate 5854: BnF A-38757, Wikimedia Commons btv1b10075962b page 6.
% Three-note groups have one beam in that print and no printed tuplet number.
% They are encoded as unnumbered eighth-note triplets to fit common time.
% This remains pending human proof-reading.

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
  \omit TupletNumber
  \omit TupletBracket
  \tempo "Andante grazioso."
  \mark \markup { \italic "Pour bien lier le chant." }
  e4-5\p \tuplet 3/2 { g,8 c8 e8 } d4-4 \tuplet 3/2 { g,8 b8 d8-3 } |
  f4 \tuplet 3/2 { g,8 d'8 f8-3 } e4 \tuplet 3/2 { c8 e8 g8-1 } |
  a4 \tuplet 3/2 { c,8 f8 a8 } g4 \tuplet 3/2 { c,8 e8 g8-5 } |
  \tuplet 3/2 { f8-4 d8 g,8 } \tuplet 3/2 { e'8-4 c8 g8 }
  \tuplet 3/2 { e'8-5 c8 g8 } \tuplet 3/2 { d'8 b8 g8 } |
  e'4 \tuplet 3/2 { g,8 c8 e8 } d4 \tuplet 3/2 { g,8 b8 d8 } |
  f4 \tuplet 3/2 { a,8 d8-3 f8-5 } e4 \tuplet 3/2 { a,8 c8 e8-3 } |
  a4-5 \tuplet 3/2 { c,8 es8 a8 } \tuplet 3/2 { g8 e8 c8 }
  \tuplet 3/2 { e8-4 c8 a8 } |
  \tuplet 3/2 { f'8-5 d8 a8 } \tuplet 3/2 { d8-4 b8 g8 }
  \tuplet 3/2 { c8-5 g8 e8 } r4 |
  d'4 \tuplet 3/2 { g,8 b8 d8-3 } e4 \tuplet 3/2 { cis8-2 e8 g8 } |
  \tuplet 3/2 { d8-2 b8 d8 } \tuplet 3/2 { b'8 d,8 b8 }
  \tuplet 3/2 { a'8 d,8 b8 } \tuplet 3/2 { g'8-4 d8 b8 } |
  \tuplet 3/2 { f'8-5 c8 a8 } \tuplet 3/2 { fis'8-4 c8 a8 }
  \tuplet 3/2 { d8-4 c8 a8 } \tuplet 3/2 { d8-3 c8 a8 } |
  cis4-3 \tuplet 3/2 { d8-4 b8 g8 } \tuplet 3/2 { d'8 b8 g8 }
  \tuplet 3/2 { d'8 b8 g8 } |
  es'4-3 \tuplet 3/2 { g,8 bes8 es8 } f4 \tuplet 3/2 { bes,8 d8 f8 } |
  g4^\markup { \italic "cresc." } \tuplet 3/2 { bes,8-1 es8 g8 }
  bes4-5 \tuplet 3/2 { g,8 bes8 cis8 } |
  d4 \tuplet 3/2 { g,8 b8 d8 } e4 \tuplet 3/2 { fis,8 a8 d8 } |
  g,4~ \tuplet 3/2 { g8 b8 d8 } g4~ \tuplet 3/2 { g8 es8 c8 } |
  g4~ \tuplet 3/2 { g8 f8 d8 } es4~ \tuplet 3/2 { es8 d8 c8 } |
  b4~ \tuplet 3/2 { b8 e8 g8 } \tuplet 3/2 { b8 g8 b8 }
  \tuplet 3/2 { d8 b8 d8 } |
  \tuplet 3/2 { a'8 d,8 b8 } \tuplet 3/2 { g'8 d8 b8 }
  \tuplet 3/2 { fis'8 d8 b8 } \tuplet 3/2 { f'8 d8 b8 } |
  e4\p \tuplet 3/2 { g,8 c8 e8 } d4 \tuplet 3/2 { g,8 b8 d8 } |
  f4 \tuplet 3/2 { g,8 d'8 f8 } e4 \tuplet 3/2 { c8 e8 g8 } |
  a4 \tuplet 3/2 { c,8 f8 a8 } g4 \tuplet 3/2 { c,8 e8 g8 } |
  \tuplet 3/2 { f8 d8 g,8 } \tuplet 3/2 { e'8 c8 g8 }
  \tuplet 3/2 { e'8 c8 g8 } \tuplet 3/2 { d'8 b8 g8 } |
  e'4 \tuplet 3/2 { g,8 c8 e8 } d4 \tuplet 3/2 { g,8 b8 d8 } |
  f4^\markup { \italic "cresc." } \tuplet 3/2 { b,8 d8 f8 }
  e4 \tuplet 3/2 { a,8 c8 e8 } |
  a4 \tuplet 3/2 { c,8 es8 a8 } \tuplet 3/2 { g8 e8 c8 }
  \tuplet 3/2 { e8 c8 a8 } |
  \tuplet 3/2 { f'8 d8 a8 } \tuplet 3/2 { d8 b8 g8 }
  \tuplet 3/2 { d'8 g,8 e8 } r4 \bar "|."
}

leftHand = {
  \clef bass \time 4/4 \key c \major
  \omit TupletNumber
  \omit TupletBracket
  \set tieWaitForNote = ##t
  \tuplet 3/2 { c8-4~ e8~ g8~ } <c e g>4
  \tuplet 3/2 { g,8~ d8~ g8~ } <g, d g>4 |
  \tuplet 3/2 { b,8-4~ d8~ g8~ } <b, d g>4
  \tuplet 3/2 { c8-4~ e8~ g8~ } <c e g>4 |
  \tuplet 3/2 { d8-4~ f8~ a8~ } <d f a>4
  \tuplet 3/2 { e8-5~ g8~ c'8~ } <e g c'>4 |
  << { \voiceOne g2 g2 } \\ { \voiceTwo b,4-4 c4 g,2 } >> \oneVoice |
  \tuplet 3/2 { c8~ e8~ g8~ } <c e g>4
  \tuplet 3/2 { g,8~ d8~ g8~ } <g, d g>4 |
  \tuplet 3/2 { d8-4~ f8~ a8~ } <d f a>4
  \tuplet 3/2 { a,8~ e8~ a8~ } <a, e a>4 |
  << { \voiceOne \set tieWaitForNote = ##t c'8-5~ es'8~ <c' es'>4 } \\ { \voiceTwo fis4~ fis4 } >> \oneVoice <a c' e'>4 <a c' e'>4 |
  <f_5 a d'>4 <g_4 b d'>4 <c' e'>4 d4 |
  \tuplet 3/2 { g8~ b8~ e'8~ } <g b e'>4
  \tuplet 3/2 { g8~ ais8~ cis'8~ } <g ais cis'>4 |
  \tuplet 3/2 { g8_5~ b8~ e'8~ } <g b e'>4
  \tuplet 3/2 { g8_4~ b8~ e'8~ } <g b e'>4 |
  \tuplet 3/2 { d8_5~ a8~ c'8~ } <d a c'>4
  \tuplet 3/2 { d8~ fis8~ c'8~ } <d fis c'>4 |
  \tuplet 3/2 { g8-4~ b8~ d'8~ } <g b d'>4
  \tuplet 3/2 { g8~ b8~ d'8~ } <g b d'>4 |
  \tuplet 3/2 { g8~ bes8~ es'8~ } <g bes es'>4
  \tuplet 3/2 { f8~ as8~ c'8~ } <f as c'>4 |
  \tuplet 3/2 { <es g>8~ bes8~ es'8~ } <es g bes es'>4
  \tuplet 3/2 { es8~ g8~ bes8~ } <es g bes>4 |
  \tuplet 3/2 { d8~ g8~ b8~ } <d g b>4^\markup { \italic "Dim." }
  \tuplet 3/2 { d8~ a8~ d'8~ } <d a d'>4 |
  \tuplet 3/2 { g,8 b,8 d8 } g4
  \tuplet 3/2 { g,8 d8 es8 } g4 |
  \tuplet 3/2 { g,8 b,8 d8 } g4
  \tuplet 3/2 { g,8 d8 es8 } g4 |
  \tuplet 3/2 { g,8 b,8 d8 } g4 r2 |
  R1 |
  \tuplet 3/2 { c8~ e8~ g8~ } <c e g>4
  \tuplet 3/2 { g,8~ d8~ f8~ } <g, d f>4 |
  \tuplet 3/2 { a,8~ d8~ f8~ } <a, d f>4
  \tuplet 3/2 { c8~ e8~ g8~ } <c e g>4 |
  \tuplet 3/2 { f8~ a8~ c'8~ } <f a c'>4
  \tuplet 3/2 { d8~ f8~ c'8~ } <d f c'>4 |
  << { \voiceOne g2 g2 } \\ { \voiceTwo b,4 c4 g,2 } >> \oneVoice |
  \tuplet 3/2 { c8~ e8~ g8~ } <c e g>4
  \tuplet 3/2 { g,8~ d8~ f8~ } <g, d f>4 |
  \tuplet 3/2 { gis8-4~ b8~ e'8~ } <gis b e'>4
  \tuplet 3/2 { a8-3~ c'8~ e'8~ } <a c' e'>4 |
  \tuplet 3/2 { fis8-5~ c'8~ es'8~ } <fis c' es'>4
  <g c' e'>4^\markup { \italic "Dim." } <a c' e'>4 |
  <f a d'>4 <g b d'>4 <c' e'>4 c4 \bar "|."
}

\score {
  \new PianoStaff <<
    \new Staff = "right" \rightHand
    \new Staff = "left" \leftHand
  >>
  \layout { }
}
