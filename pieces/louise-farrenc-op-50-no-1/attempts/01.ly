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

rightHand = \relative c'' {
  \global
  \tempo "Andante grazioso"
  b2-3( g8 b c4-4) |
  b4( g8 b c4) b8( c) |
  d4-3( b8 d e4) b8( d) |
  e4( c8 e g4) e8( g) |

  f4-4( d8 f e c e c) |
  d4-3( b8 d e4) b8( d) |
  e4-3( c8 e f4-5) c8( f) |
  a4-5( f8 a g f e d) |

  c4-5( a8 c b a g f) |
  e4( c8 e g4-3) e8( g) |
  fis4-2( d8 fis a4) fis8( a) |
  b4( g8 b d4-5) b8( d) |

  cis4-3( a8 cis e4) cis8( e) |
  f4-4( d8 f a4) f8( a) |
  bes4-4( g8 bes c4-5) g8( c) |
  a4-3( f8 a bes4) f8( bes) |

  g2~ g8( a b c) |
  d4.-3( c8 b4-1 a) |
  g2~ g8( fis e d) |
  c4.-4( b8 a4 g) |

  c4( e8 g c4-5) g8( c) |
  b4( g8 b d4) b8( d) |
  c4( a8 c f4) c8( f) |
  e4( c8 e g4-5) e8( g) |

  f4-5( d8 f e c e c) |
  d4-4( b8 d c a c a) |
  b4-5( g8 b a fis a fis) |
  g2.-5 r4 \bar "|."
}

leftHand = \fixed c {
  \global
  g,8( d <g b>4~ <g b>8) d( <g b>4) |
  g,8( d <g b>4~ <g b>8) d( <g b>4) |
  c8( g <c' e'>4~ <c' e'>8) g( <c' e'>4) |
  c8( g <c' e'>4~ <c' e'>8) g( <c' e'>4) |

  d8( a <d' f'>4~ <d' f'>8) a( <d' f'>4) |
  g,8( d <g b>4~ <g b>8) d( <g b>4) |
  c8( g <c' e'>4~ <c' e'>8) g( <c' e'>4) |
  f,8( c <f a>4~ <f a>8) c( <f a>4) |

  f,8( c <f a>4~ <f a>8) c( <f a>4) |
  c8( g <c' e'>4~ <c' e'>8) g( <c' e'>4) |
  d8( a <d' fis'>4~ <d' fis'>8) a( <d' fis'>4) |
  g,8( d <g b>4~ <g b>8) d( <g b>4) |

  a,8( e <a cis'>4~ <a cis'>8) e( <a cis'>4) |
  d8( a <d' f'>4~ <d' f'>8) a( <d' f'>4) |
  g,8( d <g bes>4~ <g bes>8) d( <g bes>4) |
  f,8( c <f a>4~ <f a>8) c( <f a>4) |

  c8( e g c' e' c' g e) |
  d8( fis a d' fis' d' a fis) |
  g,8( b, d g b g d b,) |
  c8( e g c' e' c' g e) |

  c8( g <c' e'>4~ <c' e'>8) g( <c' e'>4) |
  g,8( d <g b>4~ <g b>8) d( <g b>4) |
  f,8( c <f a>4~ <f a>8) c( <f a>4) |
  c8( g <c' e'>4~ <c' e'>8) g( <c' e'>4) |

  d8( a <d' f'>4~ <d' f'>8) a( <d' f'>4) |
  g,8( d <g b>4~ <g b>8) d( <g b>4) |
  d8( a <d' fis'>4) d8( a <c' fis'>4) |
  <g, d b>2. r4
}

dynamics = {
  s1\p | s1 | s1 | s1 |
  s1 | s1 | s1 | s1 |
  s1 | s1 | s1 | s1 |
  s1\< | s1 | s1\!^\markup \italic "dim." | s1 |
  s1\p | s1 | s1 | s1 |
  s1 | s1 | s1 | s1 |
  s1\< | s1 | s1\!^\markup \italic "dim." | s1 |
}

\score {
  \new PianoStaff <<
    \new Staff = "upper" \rightHand
    \new Dynamics \dynamics
    \new Staff = "lower" { \clef bass \leftHand }
  >>
  \layout {
    system-count = 7
    \context {
      \Score
      \override Fingering.staff-padding = #'()
    }
  }
}
