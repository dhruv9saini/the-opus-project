\version "2.24.3"

% Step 3: third-agent reconciliation of both independent attempts against
% printed LOC2014568419, complete PDF page 1. Human verification pending.
\header {
  title = "The Favorite Vienna Waltz"
  composer = "Anonymous"
  subtitle = "G. Willig, Philadelphia, before 1820?"
  tagline = "The OPUS Project · CC0 · Reconciled draft; human verification pending"
}

% Preserve the source's dots on both sides even at the end of the system.
\defineBarLine ":|.|:-literal" #'(":|.|:" #f " |.|")

upper = \absolute {
  \clef treble \key bes \major \time 3/8
  % Printed system 1, measures 1–6.
  bes8.\turn[ c'16 d'16 es'16] |
  d'16[ f'16 d''16 f'16 d''16 f'16] |
  c'16[ es'16 c''16 es'16 c''16 es'16] |
  d'16[ f'16 bes'16 f'16 bes'16 f'16] |
  bes8.\turn[ c'16 d'16 es'16] |
  d'16[ f'16 d''16 f'16 d''16 f'16] |
  \break
  % Printed system 2, measures 7–13.
  c'16[ es'16 c''16 es'16 c''16 es'16] |
  <d' bes'>4 r8 \bar ":|.|:"
  r8 bes16[ d'16 f'16 bes'16] |
  d''16[ c''16 b'!16 c''16 b'16 c''16] |
  r8 c'16[ f'16 a'16 c''16] |
  c''16[ bes'16 a'16 bes'16 a'16 bes'16] |
  bes8.\turn[ c'16 d'16 es'16] |
  \break
  % Printed system 3, measures 14–20.
  d'16[ f'16 d''16 f'16 d''16 f'16] |
  c'16[ es'16 c''16 es'16 c''16 es'16] |
  <d' bes'>4. _\markup \italic "Fine" \bar ":|.|:"
  \key es \major
  g16[ bes16 es'16 bes16 g'16 bes16] |
  g16[ bes16 es'16 bes16 g'16 bes16] |
  <<
    { \voiceOne \grace { g'16 } aes'8[ \grace { g'16 } aes'8 \grace { g'16 } aes'8] }
    \\
    { \voiceTwo bes4. }
  >> \oneVoice |
  <bes f'>4 d'16[ bes16] |
  \break
  % Printed system 4: measures 21–28, including both endings and pickup.
  g16[ bes16 es'16 bes16 g'16 bes16] |
  g16[ bes16 es'16 bes16 g'16 bes16] |
  <<
    { \voiceOne \grace { g'16 } aes'8[ \grace { g'16 } aes'8] f'16[ d'16] }
    \\
    { \voiceTwo bes4 s8 }
  >> \oneVoice |
  \set Score.repeatCommands = #'((volta "1"))
  <g es'>4. \bar ":|."
  \set Score.repeatCommands = #'((volta #f) (volta "2"))
  \partial 4 <g es'>4 \bar "||"
  \set Score.repeatCommands = #'((volta #f))
  \partial 8 \bar ".|:" bes'16[ c''16] |
  bes'16[ c''16 bes'16 c''16 d''16 es''16] |
  <es' bes'>4 g'16[ bes'16] |
  \break
  % Printed system 5, measures 29–35.
  \grace { bes'16 } aes'8[ aes'8] f'16[ d'16] |
  es'16[ g'16 bes8] bes'16[ c''16] |
  bes'16[ c''16 bes'16 c''16 d''16 es''16] |
  <es' bes'>4 g'16[ bes'16] |
  \grace { bes'16 } aes'8[ aes'8] f'16[ d'16] |
  \set Score.repeatCommands = #'((volta "1"))
  \partial 4 <g es'>4 \bar "||"
  \set Score.repeatCommands = #'((volta #f) (volta "2"))
  <g es'>4. _\markup \italic "D.C." \bar ":|.|:-literal"
  \set Score.repeatCommands = #'((volta #f))
}

lower = \absolute {
  \clef bass \key bes \major \time 3/8
  bes,,8[ bes,8 bes,8] |
  bes,,8[ bes,8 bes,8] |
  f,8[ f8 f8] |
  bes,,8[ bes,8 bes,8] |
  bes,,8[ bes,8 bes,8] |
  bes,,8[ bes,8 bes,8] |
  f,8[ f8 f8] |
  bes,4 r8 |
  bes,,8[ bes,8 bes,8] |
  f,8[ f8 f8] |
  f,8[ f8 f8] |
  bes,,8[ bes,8 bes,8] |
  bes,,8[ bes,8 bes,8] |
  bes,,8[ bes,8 bes,8] |
  f,8[ f8 f8] |
  bes,4. |
  \key es \major
  es8[ es8 es8] |
  es8[ es8 es8] |
  bes,8[ bes,8 bes,8] |
  bes,8[ bes,8 bes,8] |
  es8[ es8 es8] |
  es8[ es8 es8] |
  bes,8[ bes,8 bes,8] |
  es4. |
  \partial 4 es4 |
  \partial 8 r8 |
  es8[ g8 bes8] |
  es8[ g8 bes8] |
  bes,8[ f8 bes8] |
  es8[ g8 bes8] |
  es8[ g8 bes8] |
  es8[ g8 bes8] |
  bes,8[ f8 bes8] |
  \partial 4 es4 |
  es4. |
}

\paper {
  #(set-paper-size "a4")
  indent = 0\mm
  ragged-last = ##f
  system-count = 5
}

\score {
  \new PianoStaff <<
    \new Staff = "upper" \upper
    \new Staff = "lower" \lower
  >>
  \layout { }
}
