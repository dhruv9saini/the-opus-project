\version "2.26.0"

% Independent Step 1 transcription from the printed scan only.
% Source: IMSLP02320, Bach-AnnaMagdalena1725.pdf, PDF p. 21,
% printed p. 26, No. IV, all four systems, 32 bars (No. V excluded).
% Edition: Bach-Gesellschaft Ausgabe 43.2, ed. Paul Waldersee,
% Leipzig: Breitkopf und Haertel, 1894, plate B.W. XLIII(2).
% Public domain in the USA (published 1894) and in life+70 jurisdictions
% (Petzold died 1733; Waldersee died 1906).
% The source's soprano clef and single-digit time signature are retained.
% Modern attribution: Christian Petzold; collected in A. M. Bach's notebook.

\header {
  title = "Menuet in G major"
  subtitle = "BWV Anh. 114 — Notebook for Anna Magdalena Bach, No. IV"
  composer = "Christian Petzold"
  tagline = ##f
}

\paper {
  #(set-paper-size "a4")
  indent = 0
  ragged-last-bottom = ##t
}

global = {
  \key g \major
  \override Staff.TimeSignature.style = #'single-number
  \time 3/4
}

% The edition places its two final fermatas over/under the repeat barline.
#(define ((barline-with-fermata direction) grob)
   (ly:stencil-add
     (ly:bar-line::print grob)
     (ly:stencil-translate
       (grob-interpret-markup grob
         (markup #:center-align #:musicglyph
           (if (= direction UP) "scripts.ufermata" "scripts.dfermata")))
       (cons 0 (* direction 3.4)))))

right = {
  \global
  \clef soprano
  \repeat volta 2 {
    % Source system 1: bars 1–8.
    d''4 g'8[ a' b' c''] |                       % 1
    d''4 g' g' |                                % 2
    e''4 c''8\mordent[ d'' e'' fis''] |          % 3
    g''4 g' g' |                                % 4
    c''4\mordent d''8[ c'' b' a'] |              % 5
    b'4 c''8[ b' a' g'] |                        % 6
    fis'4 g'8[ a' b' g'] |                       % 7
    \appoggiatura b'8 a'2. | \break              % 8
    % Source system 2: bars 9–16.
    d''4 g'8[ a' b' c''] |                       % 9
    d''4 g' g' |                                % 10
    e''4 c''8\mordent[ d'' e'' fis''] |          % 11
    g''4 g' g' |                                % 12
    c''4\mordent d''8[ c'' b' a'] |              % 13
    b'4 c''8[ b' a' g'] |                        % 14
    a'4 b'8[ a' g' fis'] |                       % 15
    g'2. |                                      % 16
  }
  \break
  \repeat volta 2 {
    % Source system 3: bars 17–24.
    b''4 g''8[ a'' b'' g''] |                    % 17
    a''4 d''8[ e'' fis'' d''] |                  % 18
    g''4 e''8[ fis'' g'' d''] |                  % 19
    cis''4 d''8[ e''] a'4 |                     % 20
    a'8[ b' cis'' d'' e'' fis''] |               % 21
    g''4 fis'' e'' |                            % 22
    fis''4 a' cis'' |                           % 23
    d''2. | \break                              % 24
    % Source system 4: bars 25–32.
    d''4 g'8[ fis'] g'4 |                        % 25
    e''4 g'8[ fis'] g'4 |                        % 26
    d''4 c'' b' |                               % 27
    a'8[ g' fis' g'] a'4 |                       % 28
    d'8[ e' fis' g' a' b'] |                     % 29
    c''4 b'\prall a' |                          % 30
    b'8[ d''] g'4 fis' |                         % 31
    << { \voiceOne d''2. } \\ { \voiceTwo <g' b'>2. } >>
    \oneVoice
    \once \override Staff.BarLine.stencil = #(barline-with-fermata UP)
    |                                           % 32
  }
}

left = {
  \global
  \clef bass
  \repeat volta 2 {
    << { \voiceOne d'2 s4 } \\ { \voiceTwo <g b>2 a4 } >>
    \oneVoice |                                 % 1
    b2. |                                       % 2
    c'2. |                                      % 3
    b2. |                                       % 4
    a2. |                                       % 5
    g2. |                                       % 6
    d'4 b g |                                   % 7
    d'4 d8[ c' b a] |                           % 8
    b2 a4 |                                     % 9
    g4 b g |                                    % 10
    c'2. |                                      % 11
    b4 c'8[ b a g] |                            % 12
    a2 fis4 |                                   % 13
    g2 b4 |                                     % 14
    c'4 d' d |                                  % 15
    g2 g,4 |                                    % 16
  }
  \repeat volta 2 {
    g2. |                                       % 17
    fis2. |                                     % 18
    e4 g e |                                    % 19
    a2 a,4 |                                    % 20
    a2. |                                       % 21
    b4 d' cis' |                                % 22
    d'4 fis a |                                 % 23
    d'4 d g! |                                  % 24
    << { \voiceOne r4 d'2 } \\ { \voiceTwo b2 b4 } >>
    \oneVoice |                                 % 25
    << { \voiceOne r4 e'2 } \\ { \voiceTwo c'2 c'4 } >>
    \oneVoice |                                 % 26
    b4 a g |                                    % 27
    d'2 r4 |                                    % 28
    << { \voiceOne r4 r4 fis4 } \\ { \voiceTwo c2. } >>
    \oneVoice |                                 % 29
    e4 g fis |                                  % 30
    g4 b, d |                                   % 31
    g4 d g,
    \once \override Staff.BarLine.stencil = #(barline-with-fermata DOWN)
    |                                           % 32
  }
}

\score {
  \new PianoStaff <<
    \new Staff = "upper" \right
    \new Staff = "lower" \left
  >>
  \layout { }
}
