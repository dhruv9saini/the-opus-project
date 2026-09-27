\version "2.24.3"

\header {
  title = "Étude No. 4"
  subtitle = "Pour les batteries avec une partie soutenue"
  composer = "Louise Farrenc"
  opus = "Op. 50, No. 4"
  tagline = ##f
}

#(set-default-paper-size "a3")
#(set-global-staff-size 16)

\paper {
  top-margin = 10\mm
  bottom-margin = 10\mm
  left-margin = 10\mm
  right-margin = 10\mm
  ragged-last-bottom = ##f
}

global = {
  \key g \major
  \time 6/8
}

rightHand = \fixed c' {
  \global
  \tempo "Poco Allegro"
  \repeat volta 2 {
    <<
      { b4.-4 c | b-4 a | a g | b c8-3 d e }
      \\
      {
        g16( fis g a b g a g a b c a) |
        g( fis g a b g fis e fis g a fis) |
        e( d e fis g e d c d e fis d) |
        g( fis g a b g fis e d c b a) |
      }
    >> |
    b4.-3 d-5 | b-3 a | g-1 fis-3 | d4.-2 r4. |
  }

  \partial 4 b8-2 d-5
  \repeat volta 2 {
    b4.-3 a | g4.-1 fis-3 |
    g4.-3 e-1 | fis4. g8-1 a b |
    <<
      { c4.-5 b | a-4 g | fis-2 e | d4. e8 fis g }
      \\
      {
        e16( d e fis g e d c d e fis d) |
        d( cis d e fis d c b c d e c) |
        c( b c d e c b a b c d b) |
        a( g a b c a g fis g a b g) |
      }
    >> |
    <<
      { a4.-4 b | c-5 b | a-4 g | fis4.~ fis4 r8 }
      \\
      {
        fis16( e fis g a fis g fis g a b g) |
        a( g a b c a g fis g a b g) |
        fis( e fis g a fis e d e fis g e) |
        d( cis d e fis d cis b cis d e cis) |
      }
    >> |
  }
  \bar "|."
}

leftHand = \fixed c {
  \global
  \repeat volta 2 {
    g4. d | g d |
    c g, | d4. d4 r8 |
    g16( fis g a b g a g a b c' a) |
    g( fis g a b g fis e fis g a fis) |
    e( d e fis g e d c d e fis d) |
    g( a b c' d' b g4) r8 |
  }

  \partial 4 r4
  \repeat volta 2 {
    g16( fis g a b g a g a b c' a) |
    g( fis g a b g fis e fis g a fis) |
    e( d e fis g e d c d e fis d) |
    d( cis d e fis d g,4.) |
    c4. g | d a |
    d a, | g4. r4. |
    d4. g, | a e |
    d4.~ d | g,4. d4 r8 |
  }
}

dynamics = {
  \repeat volta 2 {
    s2.\p^\markup \italic "e molto legato" | s2. | s2. | s2. |
    s2.\mf | s2. | s2. | s2. |
  }
  \partial 4 s4
  \repeat volta 2 {
    s2. | s2. | s2. | s2. |
    s2. | s2. | s2. | s2. |
    s2.\< | s2.\! | s2.^\markup \italic "dim." | s2. |
  }
}

\score {
  \new PianoStaff <<
    \new Staff = "upper" \rightHand
    \new Dynamics \dynamics
    \new Staff = "lower" { \clef bass \leftHand }
  >>
  \layout {
    system-count = 5
    \context {
      \Score
      \override Fingering.staff-padding = #'()
    }
  }
}
