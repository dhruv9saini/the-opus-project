\version "2.24.3"

\header {
  title = "Étude No. 1"
  subtitle = "Pour bien lier le chant"
  composer = "Louise Farrenc"
  opus = "Op. 50, No. 1"
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

global = {
  \key c \major
  \time 4/4
}

% IMSLP #511615, PDF page 3 / printed page 2. This agent draft remains
% withdrawn pending complete independent source and render review.
rightHand = \fixed c {
  \global
  \tempo "Andante grazioso."
  e''4-5 g'16[ c''16 e''8] d''4-4 g'16[ b'16 d''8-3] |
  f''4-3 g'16[ d''16 f''8] e''4 c''16[ e''16 g''8] |
  a''4 c''16[ f''16 a''8] g''4 c''16[ e''16 g''8] | \break
  \omit TupletNumber \omit TupletBracket
  \tuplet 3/2 { f''8-4[ d''8 g'8] }
  \tuplet 3/2 { e''8-4[ c''8 g'8] }
  \tuplet 3/2 { e''8-5[ c''8 g'8] }
  \tuplet 3/2 { d''8[ b'8 g'8] } |
  e''4 g'16[ c''16 e''8] d''4 g'16[ b'16 d''8] |
  f''4 a'16[ d''16-3 f''8-5] e''4 a'16[ c''16 e''8-3] |
  a''4-5 c''16[ es''16 a''8] g''8[ e''16 c''16]
  e''8-4[ c''16 a'16] | \break
  f''8-5[ d''16 a'16] d''8-4[ b'16 g'16]
  c''8-5[ g'16 e'16] r4 |
  d''4 g'16[ b'16 d''8-3] e''4 cis''16-2[ e''16 g''8] |
  \tuplet 3/2 { d''8-2[ b'8 d''8] }
  \tuplet 3/2 { b''8[ d''8 b'8] }
  \tuplet 3/2 { a''8[ d''8 b'8] }
  \tuplet 3/2 { g''8-4[ d''8 b'8] } |
  f''8-5[ c''16 a'16] fis''8-4[ c''16 a'16]
  d''8-4[ c''16 a'16] d''8-3[ c''16 a'16] | \break
  cis''4-3 d''16-4[ b'16 g'8] d''16[ b'16 g'8]
  d''16[ b'16 g'8] |
  es''4-4 g'8[ bes'16 es''16] f''4 bes'8[ d''16 f''16] |
  g''4 bes'8[ es''16 g''16] bes''4 g'8[ bes'16 cis''16] |
  d''4 g'8[ b'!16 d''16] e''!4 fis'8[ a'16 d''16] | \break
  g'4~ g'16[ b'16 d''8-3] g''4~ g''16[ es''16-3 c''8] |
  g'4-1-4~ g'16[ f'16 d'8] es'4-4~ es'16[ d'16 c'8] |
  b4~ b16[ e'16 g'8-4] b'8-1[ g'16 b'16-2]
  d''8-4[ b'16-1 d''16-2] |
  \tuplet 3/2 { a''8-5[ d''8 b'8] }
  \tuplet 3/2 { g''8[ d''8 b'8] }
  \tuplet 3/2 { fis''8-4[ d''8 b'8] }
  \tuplet 3/2 { f''8-4[ d''8 b'8] } | \break
  e''4 g'16[ c''16 e''8] d''4 g'16[ b'16 d''8] |
  f''4 g'16[ d''16 f''8] e''4 c''16[ e''16 g''8] |
  a''4 c''16[ f''16 a''8] g''4 c''16[ e''16 g''8] |
  \tuplet 3/2 { f''8[ d''8 g'8] }
  \tuplet 3/2 { e''8[ c''8 g'8] }
  \tuplet 3/2 { e''8[ c''8 g'8] }
  \tuplet 3/2 { d''8[ b'8 g'8] } | \break
  e''4 g'16[ c''16 e''8] d''4 g'16[ b'16 d''8] |
  f''4 b'16[ d''16 f''8] e''4 a'16[ c''16 e''8] |
  a''4 c''16[ es''16 a''8] g''8[ e''16 c''16]
  e''8[ c''16 a'16] |
  f''16-5[ d''16 a'8] d''16-4[ b'16 g'8]
  d''16-5[ g'16 e'8] r4 \bar "|."
}

% The lower voice holds the bass tones while the upper voice arpeggiates.
% tieWaitForNote permits each arpeggiated pitch to tie into the chord.
leftUpper = \fixed c {
  \global
  \set tieWaitForNote = ##t
  c16-4~[ e16~ g8~] <c e g>4 g,16~[ d16~ g8~] <g, d g>4 |
  b,16-4~[ d16~ f8~] <b, d f>4 c16-4~[ e16~ g8~] <c e g>4 |
  d16-4~[ f16~ a8~] <d f a>4 c16-5~[ e16~ a8~] <c e a>4 |
  g2 g2 |
  c16~[ e16~ g8~] <c e g>4 g,16~[ d16~ g8~] <g, d g>4 |
  d16-4~[ f16~ a8~] <d f a>4 a,16~[ e16~ a8~] <a, e a>4 |
  c'8-5~[ es'8~] <fis c' es'>4
  <a c' e'>4 <a c' e'>4 |
  <f a d'>4 <g b d'>4 <c' e'>4 d4 |
  g16~[ b16~ e'8~] <g b e'>4
  g16~[ ais16~ cis'8~] <g ais cis'>4 |
  g16~[ b16~ e'8~] <g b e'>4
  g16~[ b16~ e'8~] <g b e'>4 |
  d16-5~[ a16~ c'8~] <d a c'>4
  d16~[ fis16~ c'8~] <d fis c'>4 |
  g16-4~[ b16~ e'8~] <g b e'>4
  g16~[ b16~ e'8~] <g b e'>4 |
  g16~[ bes16~ es'8~] <g bes es'>4
  f16~[ as16~ c'8~] <f as c'>4 |
  <es g>16~[ bes16~ es'8~] <es g bes es'>4
  es16~[ g16~ bes8~] <es g bes>4 |
  d16~[ g16~ b8~] <d g b>4
  d16~[ a16~ d'8~] <d a d'>4 |
  g,16[ b,16 d8] g4 g,16[ d16 es8] g4 |
  g,16[ b,16 d8] g4 g,16[ d16 es8] g4 |
  g,16[ b,16 d8] g4 r2 |
  R1 |
  c16~[ e16~ g8~] <c e g>4
  g,16~[ d16~ g8~] <g, d g>4 |
  b,16~[ d16~ f8~] <b, d f>4
  c16~[ e16~ g8~] <c e g>4 |
  f16~[ a16~ c'8~] <f a c'>4
  d16~[ f16~ c'8~] <d f c'>4 |
  g2 g2 |
  c16~[ e16~ g8~] <c e g>4
  g,16~[ d16~ g8~] <g, d g>4 |
  gis16-4~[ b16~ e'8~] <gis b e'>4
  a16-3~[ c'16~ e'8~] <a c' e'>4 |
  c'8-5~[ es'8~] <fis c' es'>4
  <g c' e'>4 <a c' e'>4 |
  <e a d'>4 <g b d'>4 <c' e'>4 c4
}

leftLower = \fixed c {
  \global
  c4~ c4 g,4~ g,4 |
  b,4~ b,4 c4~ c4 |
  d4~ d4 c4~ c4 |
  b,4-4 c4 g,2 |
  c4~ c4 g,4~ g,4 |
  d4~ d4 a,4~ a,4 |
  fis4~ fis4 a4 a4 |
  s1 |
  g4~ g4 g4~ g4 |
  g4~ g4 g4~ g4 |
  d4~ d4 d4~ d4 |
  g4~ g4 g4~ g4 |
  g4~ g4 f4~ f4 |
  es4~ es4 es4~ es4 |
  d4~ d4 d4~ d4 |
  s1 | s1 | s1 | s1 |
  c4~ c4 g,4~ g,4 |
  b,4~ b,4 c4~ c4 |
  f4~ f4 d4~ d4 |
  b,4 c4 g,2 |
  c4~ c4 g,4~ g,4 |
  gis4~ gis4 a4~ a4 |
  fis4~ fis4 g4 a4 |
  s1
}

dynamics = {
  s1\p | s1 | s1 | s1 | s1 | s1 | s1 |
  s1 | s1 | s1 | s1 |
  s1 | s1 | s1^\markup \italic "cresc." |
  s2 s2^\markup \italic "Dim." |
  s1 | s1 | s1 | s1 |
  s1\p | s1 | s1 | s1 |
  s1 | s1^\markup \italic "cresc." |
  s2 s2^\markup \italic "Dim." | s1
}

\score {
  \new PianoStaff <<
    \new Staff = "upper" \rightHand
    \new Dynamics \dynamics
    \new Staff = "lower" {
      \clef bass
      << \new Voice { \voiceOne \leftUpper }
         \new Voice { \voiceTwo \leftLower } >>
    }
  >>
  \layout {
    \context {
      \Score
      \override Fingering.staff-padding = #'()
    }
  }
}
