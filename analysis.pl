/*
a single sample query:
analysis([[[c, N0], [e, N1]],
         [[c, N0], [g, N2]]])

analysis(sample)
sample is a [frame]
frame is a [note(note_name, function)]
function is one of chord(root, quality, function?) or decorator(note, type)
*/
:- [chords].
%
% short_samp([
%   [[c, F0], [g_sharp, F1], [g_sharp, F2]],
%   [[c, F0], [g_sharp, F1], [d_sharp, F3]]
% ]).
%
% sample_prog([
% %   [[c, F0], [g_sharp, F1], [g_sharp, F2]]
% % , [[c, F0], [g_sharp, F1], [d_sharp, F3]]
% % , [[c, F0], [g_sharp, F1], [g_sharp, F4]]
% % , [[c, F0], [g_sharp, F1], [d_sharp, F5]]
% % , [[a_sharp, F6], [c_sharp, F7], [g, F8]]
% % , [[a_sharp, F6], [c_sharp, F7], [d_sharp, F9]]
% % , [[a_sharp, F6], [c_sharp, F7], [g, F10]]
% % , [[a_sharp, F6], [c_sharp, F7], [d_sharp, F11]]
% % , [[d_sharp, F12], [c, F13], [g_sharp, F14]]
% % , [[d_sharp, F12], [c, F13], [d_sharp, F15]]
% % , [[d_sharp, F12], [c, F13], [g_sharp, F16]]
% % , [[d_sharp, F12], [c, F13], [d_sharp, F17]]
% % , [[d_sharp, F12], [g, F18], [a_sharp, F19]]
% % , [[d_sharp, F12], [g, F18], [d_sharp, F20]]
%  [[g, F18], [c_sharp, F21], [a_sharp, F22]]
% , [[g, F18], [c_sharp, F21], [d_sharp, F23]]
% , [[c, F24], [g_sharp, F25], [g_sharp, F26]]
% , [[c, F24], [g_sharp, F25], [d_sharp, F27]]
% , [[d_sharp, F28], [g, F29], [a_sharp, F30]]
% , [[d_sharp, F28], [g, F29], [d_sharp, F31]]
% ]).
%
% sample_prog_2([
% %   [[d_sharp, F12], [c, F13], [g_sharp, F16]]
% % , [[d_sharp, F12], [c, F13], [d_sharp, F17]]
% % , [[d_sharp, F12], [g, F18], [a_sharp, F19]]
% % , [[d_sharp, F12], [g, F18], [d_sharp, F20]]
%  [[g, F18], [c_sharp, F21], [a_sharp, F22]]
% , [[g, F18], [c_sharp, F21], [d_sharp, F23]]
% , [[c, F24], [g_sharp, F25], [g_sharp, F26]]
% , [[c, F24], [g_sharp, F25], [d_sharp, F27]]
% , [[d_sharp, F28], [g, F29], [a_sharp, F30]]
% , [[d_sharp, F28], [g, F29], [d_sharp, F31]]
% , [[g_sharp, F32], [f, F33], [c, F34]]
% , [[g_sharp, F32], [f, F33], [g_sharp, F35]]
% , [[a_sharp, F36], [f, F37], [d, F38]]
% , [[a_sharp, F36], [f, F37], [g_sharp, F39]]
% , [[d_sharp, F40], [d_sharp, F41], [g, F42]]
% , [[d_sharp, F40], [d_sharp, F41], [a_sharp, F43]]
% , [[d_sharp, F40], [d_sharp, F41], [g, F44]]
% , [[d_sharp, F40], [d_sharp, F41], [a_sharp, F45]]
% , [[d_sharp, F40], [d_sharp, F46], [g, F47]]
% , [[d_sharp, F40], [d_sharp, F46], [a_sharp, F48]]
% ]).

merge([], [], []).
merge([L1|L1R], [L2|L2R], [[L1, L2]|CR]) :-
  merge(L1R, L2R, CR).

analysis([], _, _).
analysis([Frame|Rest], Scale, Analysis) :-
  identify_chords([Frame|Rest], [], Chords),
  chord_progression(Scale, Chords, Functions),
  merge(Chords, Functions, Analysis).

identify_chords([], Chords, ChordsOut) :- reverse(ChordsOut, Chords).

identify_chords([[Frame, Chord]|Rest], [], ChordsOut) :-
  frame(Frame, Chord),
  identify_chords(Rest, [Chord], ChordsOut).

identify_chords([[Frame, ChordIn]|Rest], [ChordIn|ChordsIn], ChordsOut) :-
  frame(Frame, ChordIn),
  identify_chords(Rest, [ChordIn|ChordsIn], ChordsOut).

identify_chords([[Frame, NewChord]|Rest], [ChordIn|ChordsIn], ChordsOut) :-
  \+ frame(Frame, ChordIn),
  frame(Frame, NewChord),
  identify_chords(Rest, [NewChord|[ChordIn|ChordsIn]], ChordsOut).

frame([], _).
frame([[N, [chord|Chord]]|Rest], Chord) :-
  note_function(N, [chord|Chord]),
  frame(Rest, Chord).

frame([[N, [chord|PrevChord]]|Rest], Chord) :-
  note_function(N, [chord|Chord]),
  \+ Chord = PrevChord,
  frame(Rest, Chord).

note_function(N, [chord|C]) :- note_chord(N, C).

note_chord(Note, [Root, Quality]) :-
  chord([Root|Rest], Quality),
  member(Note, [Root|Rest]).

% TODO: support non-harmonic tones

sanitize_func_list([], List, ListOut) :-
  reverse(List, ListOut).

sanitize_func_list([F|Rest], [], ListOut) :-
  sanitize_func_list(Rest, [F], ListOut).

sanitize_func_list([F|Rest], [F|Others], ListOut) :-
  sanitize_func_list(Rest, [F|Others], ListOut).

sanitize_func_list([F|Rest], [G|Others], ListOut) :-
  not(F = G),
  sanitize_func_list(Rest, [F|[G|Others]], ListOut).

chord_progression([S,Q], Chords, Functions) :-
  chord_prog_get_fs(S, Q, Chords, Functions),
  sanitize_func_list(Functions, [], CleanFuncs),
  progression_list(CleanFuncs).

chord_prog_get_fs(_, _, [], []).
chord_prog_get_fs(S, Q, [[CR,CQ]|Cs], [Func|Funcs]) :-
  chord_function(S, Q, CR, CQ, Func),
  chord_prog_get_fs(S, Q, Cs, Funcs).
