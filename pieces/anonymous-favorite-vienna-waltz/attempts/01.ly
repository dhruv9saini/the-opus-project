\version "2.24.3"

% Step 1: entered visually from LOC2014568419, PDF page 1 only.
% Pencil annotations in the scanned copy are not part of the printed edition.
\header {
  title = "The Favorite Vienna Waltz"
  composer = "Anonymous"
  subtitle = "G. Willig, Philadelphia, before 1820?"
  tagline = "The OPUS Project · CC0 · Agent transcription; human verification pending"
}
\paper { #(set-paper-size "a4") }

right = {
  \clef treble \key bes \major \time 3/8
  % Source system 1, bars 1–6.
  bes8.\turn[ c'16 d'16 ees'16] |
  d'16[ f' d'' f' d'' f'] |
  c'16[ ees' c'' ees' c'' ees'] |
  d'16[ f' bes' f' bes' f'] |
  bes8.\turn[ c'16 d'16 ees'16] |
  d'16[ f' d'' f' d'' f'] | \break
  % Source system 2, bars 7–13.
  c'16[ ees' c'' ees' c'' ees'] |
  <d' bes'>4 r8 \bar ":|.|:"
  r8 bes16[ c' d' ees'] |
  d''16[ c'' b'! c'' b' c''] |
  r8 c'16[ ees' f' g'] |
  c''16[ bes' a' bes' a' bes'] |
  bes8.\turn[ c'16 d'16 ees'16] | \break
  % Source system 3, bars 14–20.
  d'16[ f' d'' f' d'' f'] |
  c'16[ ees' c'' ees' c'' ees'] |
  <d' bes'>4. _\markup "Fine" \bar ":|.|:"
  \key ees \major
  g16[ bes ees' bes g' bes] |
  g16[ bes ees' bes g' bes] |
  << { \voiceOne \grace g'16 aes'8[ \grace g'16 aes'8 \grace g'16 aes'8] }
     \\ { \voiceTwo bes4. } >> \oneVoice |
  <bes f'>4 d'16[ bes] | \break
  % Source system 4, bars 21–26, with the two endings and next pickup.
  g16[ bes ees' bes g' bes] |
  g16[ bes ees' bes g' bes] |
  << { \voiceOne \grace g'16 aes'8[ \grace g'16 aes'8] f'16[ d'] }
     \\ { \voiceTwo bes4 s8 } >> \oneVoice |
  \set Score.repeatCommands = #'((volta "1."))
  <ees ees'>4. \bar ":|."
  \set Score.repeatCommands = #'((volta #f) (volta "2."))
  <ees ees'>4 \bar "||"
  \set Score.repeatCommands = #'((volta #f))
  \bar ".|:"
  bes'16[ c''] |
  bes'16[ c'' bes' c'' d'' ees''] |
  <ees' bes'>4 g'16[ bes'] | \break
  % Source system 5, remaining bars and endings.
  \grace bes'16 aes'8[ aes'] f'16[ d'] |
  ees'16[ g'] bes8 bes'16[ c''] |
  bes'16[ c'' bes' c'' d'' ees''] |
  <ees' bes'>4 g'16[ bes'] |
  \grace bes'16 aes'8[ aes'] f'16[ d'] |
  \set Score.repeatCommands = #'((volta "1."))
  <ees ees'>4 \bar "||"
  \set Timing.measurePosition = #(ly:make-moment 0)
  \set Score.repeatCommands = #'((volta #f) (volta "2."))
  <ees ees'>4. _\markup "D.C." \bar ":|.|:"
  \set Score.repeatCommands = #'((volta #f))
}

left = {
  \clef bass \key bes \major \time 3/8
  bes,,8[ bes, bes,] |
  bes,,8[ bes, bes,] |
  f,8[ f f] |
  bes,,8[ bes, bes,] |
  bes,,8[ bes, bes,] |
  bes,,8[ bes, bes,] |
  f,8[ f f] |
  bes,4 r8
  bes,,8[ bes, bes,] |
  f,8[ f f] |
  f,8[ f f] |
  bes,,8[ bes, bes,] |
  bes,,8[ bes, bes,] |
  bes,,8[ bes, bes,] |
  f,8[ f f] |
  bes,4.
  \key ees \major
  ees8[ ees ees] |
  ees8[ ees ees] |
  bes,8[ bes, bes,] |
  bes,8[ bes, bes,] |
  ees8[ ees ees] |
  ees8[ ees ees] |
  bes,8[ bes, bes,] |
  ees4.
  ees4 r8 |
  ees8[ g bes] |
  ees8[ g bes] |
  bes,8[ f bes] |
  ees8[ g bes] |
  ees8[ g bes] |
  ees8[ g bes] |
  bes,8[ f bes] |
  ees4
  \set Timing.measurePosition = #(ly:make-moment 0)
  ees4.
}

\score {
  \new PianoStaff <<
    \new Staff = "upper" \right
    \new Staff = "lower" \left
  >>
  \layout { }
}
