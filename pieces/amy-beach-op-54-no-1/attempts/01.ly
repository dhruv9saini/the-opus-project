\version "2.24.3"

#(set-global-staff-size 16)

\header {
  title = "Scottish Legend"
  opus = "Op. 54, No. 1"
  composer = "Mrs. H. H. A. Beach (1867–1944)"
  source = "Arthur P. Schmidt, 1903; IMSLP 867556"
  copyright = "Copyright 1903 by Arthur P. Schmidt."
  tagline = ##f
}

global = {
  \time 6/8
  \key bes \major
  \set PianoStaff.connectArpeggios = ##t
}

upper = \fixed c' {
  \global
  \tempo "Lento con molto espressione" 4. = 40
  \partial 8 c'8(

  % Printed page 2, system 1 — mm. 1–3
  <c' f'>8[ <c' g'> <f' a'> <f' bes'> <a' c''> <bes' d''>]) |
  <f' bes'>4( <g' d''>8) <f' c''>4( <ees' bes'>8) |
  <c' f'>8[( <c' g'> <f' a'> <f' bes'>] <f' c''>8 <g' d''>) \break |

  % Printed page 2, system 2 — mm. 4–7
  <cis' e' a'>4( <a' cis''>16[ <g' bes'>]) <a' c''>8.[( <g' bes'>16 <f' a'>8]) |
  <cis' e' a'>8->( <f' a'>) <ees' g'> <c' f'>[ <f' a'> <a' c''>] |
  <bes' d'' f''>8-> <a' cis'' e''> <g' bes' d''>
    \tuplet 3/2 { <a' c''>8( <bes' d''> <c'' ees''>) }
    <bes' d''>8 |
  <f' a'>8.[( <g' bes'>16 <a' c''>8]) <f' bes' d''>8[ <g' c'' ees''> <fis' a' cis''>] \break |

  % Printed page 2, system 3 — mm. 8–11
  <ees' g' bes'>4^\markup \italic "rit." <d' f' a'>8
    \afterGrace <ees' g' bes'>4.\fermata { f'16[ ees'] } |
  <fis' a' cis''>4\fermata <g' bes' d''>8
    <a' c''>8.[ <g' bes'>16 <fis' a'>8] |
  <g' bes'>8[ <a' c''> <bes' d''>] <g' bes'>4 <fis' a'>8 |
  <ees' g'>8[ <d' f'> <ees' g'>] <f' a'>8[ <bes' d''> <a' c''>] \break |

  % Printed page 2, system 4 — mm. 12–15
  <a' c''>8.[ <g' bes'>16 <a' c''>8] <f' a'>4 <ees' g'>8 |
  <d' f'>8[ <ees' g'> <f' a'>] <g' bes'>8.[ <fis' a'>16 <g' bes'>8] |
  <ees' g'>8( <d' f'>) <c' ees'> <d' f'>4 <c' ees'>8 |
  <c' f'>8[ <d' g'> <f' bes'>] <g' c''>8.[ <fis' a'>16 <g' bes'>8] \break |

  % Printed page 2, system 5 — mm. 16–19
  <c' f'>8[ <cis' e'> <f' a'> <bes' d''> <a' c''> <fis' a'>] |
  <f' bes'>8[ <g' c''> <f' bes'>] <ees' g'>8.[( <d' f'>16 <ees' g'>8])\fermata |
  \bar "||" \key d \major
  <a cis' fis'>8[( <a d' fis'> <cis' e' a'> <d' fis' b'>] <cis' e' a'>4) |
  <d' fis' b'>8[ <cis' e' a'> <b d' g'>] <a cis' fis'>8[ <cis' e' a'> <b d' g'>] \break |

  % Printed page 3, system 1 — mm. 20–23
  <a cis' fis'>8.[( <b d' g'>16 <cis' e' a'>8]) <d' fis' b'>8[ <cis' e' a'> <b d' g'>] |
  <cis' e' a'>8.[( <d' fis' b'>16 <cis' e' a'>8]) <b d' gis'>8[ <cis' e' a'> <b d' gis'>] |
  <a cis' fis'>8[ <b d' g'> <cis' e' a'>] <d' fis' b'>4 <cis' e' a'>8 |
  <a cis' fis'>8.[( <b d' g'>16 <cis' e' a'>8]) <e' a' cis''>8-> <d' fis' b'> <cis' e' a'> \break |

  % Printed page 3, system 2 — mm. 24–27
  <cis' e' a'>8[ <b d' gis'> <a cis' fis'>] <b d' g'>8[ <cis' e' a'> <b d' g'>] |
  <a cis' fis'>8[ <b d' g'> <a cis' fis'>]
    \tuplet 3/2 { <g b e'>16( <a cis' fis'> <b d' g'>) }
    <a cis' fis'>8 <b d' g'> |
  <cis' e' a'>8^\markup \italic "a tempo"[ <b d' gis'> <a cis' fis'>]
    <b d' g'>8[ <cis' e' a'> <d' fis' b'>] |
  <cis' e' a'>8.[( <d' fis' b'>16 <cis' e' a'>8])
    <e' a' cis''>4 <d' fis' b'>8 \break |

  % Printed page 3, system 3 — mm. 28–31
  <e' a' cis''>8-> <d' fis' b'>-> <cis' e' a'>->
    <e' gis' cis''>-> <d' fis' b'>-> <cis' e' a'>-> |
  <b d' g'>8[ <a cis' fis'>] <b d' g'>8
    \tuplet 3/2 { <a cis' fis'>16-> <b d' g'>-> <cis' e' a'>-> }
    <e' a' cis''>4\fermata |
  \bar "||" \key bes \major
  <f' a' d''>8^\markup \bold "Tempo I"[( <g' bes' ees''>16 <f' a' d''>])
    <ees' g' c''>8.[( <f' a' d''>16 <ees' g' c''>8]) <d' f' bes'>8 |
  <f' bes' d''>8.[( <g' c'' ees''>16 <f' bes' d''>8])
    <ees' g' c''>4 <d' f' bes'>8 \break |

  % Printed page 3, system 4 — mm. 32–35
  <c' f' a'>8[( <f' a'>16 <ees' g'>]) <d' f'>8.[( <ees' g'>16 <d' f'>8]) <c' ees'>8 |
  <c' ees'>8[ <d' f'> <ees' g'>] <f' a'>8[ <g' bes'> <f' a'>] |
  <f' bes'>8.[( <g' c''>16 <f' bes'>8]) <ees' g'>4 <d' f'>8 |
  <cis' e'>16[ <d' fis'> <e' g'> <fis' a'>] <g' bes'>4.\fermata <f' bes'>8 \break |

  % Printed page 3, system 5 — mm. 36–39
  <f' bes'>8.[( <g' c''>16 <f' bes'>8]) <ees' g'>8[ <fis' a'> <g' bes'>] |
  <f' a'>8.[( <g' bes'>16 <f' a'>8]) <ees' g'>8[ <d' f'> <ees' g'>] |
  <c' f'>8[ <cis' e'> <f' a'> <bes' d''> <a' c''> <fis' a'>] |
  <f' bes'>8[ <g' c''> <f' bes'>]
    <ees' g'>8.[( <d' f'>16 <ees' g'>8])
    <d' f' bes'>4.\fermata \bar "|."
}

lower = \fixed c' {
  \global
  \partial 8 f,8(

  % Printed page 2, system 1 — mm. 1–3
  <bes,, bes,>8[ <f, f> <bes, d> <d f> <f bes d'> <bes d' f'>]) |
  <bes, f bes>4 <f bes d'>8 <ees bes ees'>4 <f bes d'>8 |
  <f, f>8[ <c c'> <f a> <a c'> <c' f'> <f a c'>] |

  % Printed page 2, system 2 — mm. 4–7
  <a, e a>4 <e a cis'>8 <a cis' e'>4 <e a cis'>8 |
  <fis, fis>8[ <cis fis a> <fis a cis'> <a cis' fis'> <cis' fis' a'> <fis a cis'>] |
  <g, d g>4 <d g bes>8 <g bes d'>4 <d g bes>8 |
  <f, c f>4 <c f a>8 <f a c'>4 <f, f>8 |

  % Printed page 2, system 3 — mm. 8–11
  <ees, bes, ees>4 <bes, ees g>8 <ees g bes>4 <ees, ees>8 |
  <d, a, d>4 <a, d fis>8 <d fis a>4\fermata <d, d>8 |
  <g, d g>4 <d g bes>8 <g bes d'>4 <d g bes>8 |
  <c, g, c>8[ <g, c ees> <c ees g> <ees g c'> <g c' ees'> <c' ees' g'>] |

  % Printed page 2, system 4 — mm. 12–15
  <f, c f>4 <c f a>8 <f a c'>4 <f, f>8 |
  <bes,, f, bes,>4 <f, bes, d>8 <bes, d f>4 <bes,, bes,>8 |
  <ees, bes, ees>4 <bes, ees g>8 <ees g bes>4 <ees, ees>8 |
  <f, c f>4 <c f a>8 <f a c'>4 <f, f>8 |

  % Printed page 2, system 5 — mm. 16–19
  <bes,, bes,>8[ <f, f> <bes, d> <d f> <f bes d'> <bes d' f'>] |
  <ees, bes, ees>4 <bes, ees g>8 <ees g bes>4\fermata <f, f>8 |
  \key d \major
  <d, a, d>8[ <a, d fis> <d fis a> <fis a d'> <a d' fis'> <d' fis' a'>] |
  <g, d g>4 <d g b>8 <g b d'>4 <d g b>8 |

  % Printed page 3, system 1 — mm. 20–23
  <a, e a>4 <e a cis'>8 <a cis' e'>4 <e a cis'>8 |
  <fis, cis fis>4 <cis fis a>8 <fis a cis'>4 <fis, fis>8 |
  <d, a, d>8[ <a, d fis> <d fis a> <fis a d'> <a d' fis'> <d' fis' a'>] |
  <e, b, e>4 <b, e gis>8 <e gis b>4 <e, e>8 |

  % Printed page 3, system 2 — mm. 24–27
  <a, e a>4 <e a cis'>8 <a cis' e'>4 <e a cis'>8 |
  <d, a, d>4 <a, d fis>8 <d fis a>4 <d, d>8 |
  <g, d g>8[ <d g b> <g b d'> <b d' g'> <d' g' b'> <g b d'>] |
  <a, e a>4 <e a cis'>8 <a cis' e'>4 <a, a>8 |

  % Printed page 3, system 3 — mm. 28–31
  <d, a, d>8-> <a, d fis>-> <d fis a>-> <fis a d'>->
    <a d' fis'>-> <d' fis' a'>-> |
  <g, d g>4 <d g b>8 <a, e a>4\fermata <a, a>8 |
  \key bes \major
  <bes,, f, bes,>4 <f, bes, d>8 <bes, d f>4 <bes,, bes,>8 |
  <ees, bes, ees>4 <bes, ees g>8 <ees g bes>4 <ees, ees>8 |

  % Printed page 3, system 4 — mm. 32–35
  <f, c f>4 <c f a>8 <f a c'>4 <f, f>8 |
  <bes,, f, bes,>8[ <f, bes, d> <bes, d f> <d f bes> <f bes d'> <bes d' f'>] |
  <ees, bes, ees>4 <bes, ees g>8 <ees g bes>4 <ees, ees>8 |
  <f, c f>8[ <c f a> <f a c'> <a c' f'> <c' f' a'> <f a c'>] |

  % Printed page 3, system 5 — mm. 36–39
  <bes,, f, bes,>4 <f, bes, d>8 <bes, d f>4 <bes,, bes,>8 |
  <ees, bes, ees>4 <bes, ees g>8 <ees g bes>4 <ees, ees>8 |
  <f, c f>8[ <c f a> <f a c'> <a c' f'> <c' f' a'> <f a c'>] |
  <bes,, f, bes,>4 <f, bes, d>8 <bes, d f>4.
}

dynamics = {
  \partial 8 s8\p
  s2.^\markup \italic "sempre cantabile" | s2. | s4.\< s4.\! |
  s4.\< s4.\! | s2.\mf | s2. | s2.\> |
  s2.\pp | s2.\mf | s2.^\markup \italic "a tempo" | s4.\> s4.\! |
  s2.\pp | s2. | s2. | s2. |
  s2.^\markup \italic "rit. e molto" | s2.\pp^\markup \italic "lunga" |
  s2.\mf^\markup \italic "poco più animato" | s2. |
  s2.\< | s2. | s2.\f | s2. |
  s2.\> | s2.\pp^\markup \italic "rit." | s2.\< | s2.\!\ff^\markup \italic "sostenuto" |
  s2.\ff | s2.^\markup \italic "rit." | s2.\pp^\markup \italic "lento" |
  s2.^\markup \italic "dolcissimo" |
  s2. | s2. | s2.^\markup \italic "rall." | s2.^\markup \italic "m.s." |
  s2.^\markup \italic "più tranquillo" | s2.\p | s2.\>^\markup \italic "sempre dim." |
  s4.\ppp s4.\> | s2.\!\ppp
}

pedal = {
  \partial 8 s8
  \repeat unfold 39 {
    s8\sustainOn s8 s8 s8 s8 s8\sustainOff |
  }
}

\paper {
  #(set-paper-size "letter")
  top-margin = 0.45\in
  bottom-margin = 0.45\in
  left-margin = 0.55\in
  right-margin = 0.55\in
  system-system-spacing.basic-distance = #13
  score-system-spacing.basic-distance = #14
}

\layout {
  \context {
    \Score
    \override BarNumber.break-visibility = ##(#f #f #f)
  }
}

\score {
  \new PianoStaff \with { instrumentName = "Piano" } <<
    \new Staff = "upper" { \upper }
    \new Dynamics { \dynamics }
    \new Staff = "lower" { \clef bass \lower }
    \new Dynamics { \pedal }
  >>
}
