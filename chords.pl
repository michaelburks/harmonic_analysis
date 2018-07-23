% define notes
value(c,0).
value(c_sharp,1).
%value(d_flat,1).
value(d,2).
value(d_sharp,3).
%value(e_flat,3).
value(e,4).
value(f,5).
value(f_sharp,6).
%value(g_flat,6).
value(g,7).
value(g_sharp,8).
%value(a_flat,8).
value(a,9).
value(a_sharp,10).
%value(b_flat,10).
value(b,11).

interval(Lower, Higher, L) :-
  value(Lower, N_1),
  value(Higher, N_2),
  L is mod(N_2 - N_1, 12).

scale(Tonic, major, Note) :-
  interval(Tonic, Note, L),
  member(L, [0, 2, 4, 5, 7, 9, 11]).

scale(Tonic, minor, Note) :-
  interval(Tonic, Note, L),
  member(L, [0, 2, 3, 5, 7, 8, 10]).

scale(_, _, []).

scale(Tonic, Quality, Notes) :-
  scale_no_dupes(Tonic, Quality, Notes, []).

scale_no_dupes(_, _, [], _).

scale_no_dupes(Tonic, Quality, Notes, Dupes) :-
  not(Notes = []),
  [N|NRest] = Notes,
  scale(Tonic, Quality, N),
  not(member(N, Dupes)),
  scale_no_dupes(Tonic, Quality, NRest, [N|Dupes]).

chord(N, [major]) :-
  [Root|[Third|[Fifth]]] = N,
  interval(Root, Third, 4),
  interval(Root, Fifth, 7).

chord(N, [minor]) :-
  [Root|[Third|[Fifth]]] = N,
  interval(Root, Third, 3),
  interval(Root, Fifth, 7).

chord(N, [diminished]) :-
  [Root|[Third|[Fifth]]] = N,
  interval(Root, Third, 3),
  interval(Root, Fifth, 6).

chord(N, [major, 7]) :-
  [Root|[Third|[Fifth|[Seventh]]]] = N,
  interval(Root, Third, 4),
  interval(Root, Fifth, 7),
  interval(Root, Seventh, 11).

chord(N, [dominant, 7]) :-
  [Root|[Third|[Fifth|[Seventh]]]] = N,
  interval(Root, Third, 4),
  interval(Root, Fifth, 7),
  interval(Root, Seventh, 10).

chord(N, [minor, 7]) :-
  [Root|[Third|[Fifth|[Seventh]]]] = N,
  interval(Root, Third, 3),
  interval(Root, Fifth, 7),
  interval(Root, Seventh, 10).

chord(N, [half_diminished, 7]) :-
  [Root|[Third|[Fifth|[Seventh]]]] = N,
  interval(Root, Third, 3),
  interval(Root, Fifth, 6),
  interval(Root, Seventh, 10).

chord(N, [diminished, 7]) :-
  [Root|[Third|[Fifth|[Seventh]]]] = N,
  interval(Root, Third, 3),
  interval(Root, Fifth, 6),
  interval(Root, Seventh, 9).

% chord(_, [unknown]).

triad(Root, Third, Fifth, Q) :-
  chord([Root, Third, Fifth], Q).

scale_triad(SR, SQ, TR, TQ) :-
  triad(TR, T1, T2, TQ),
  scale(SR, SQ, TR),
  scale(SR, SQ, T1),
  scale(SR, SQ, T2).

scale_triads(SR, SQ, XR, XQ, YR, YQ) :-
  scale_triad(SR, SQ, XR, XQ),
  scale_triad(SR, SQ, YR, YQ).

% tonal relationships
chord_function(S, Q, S, [Q], [tonic, 1]).

chord_function(S, _, N, [major], [dominant, 5]) :-
  interval(S, N, 7).

chord_function(S, _, N, [dominant, 7], [dominant, 5]) :-
  interval(S, N, 7).

chord_function(S, major, N, [minor], [predominant, 6]) :-
  interval(S, N, 9).

chord_function(S, major, N, [minor], [tonic_sub, 6]) :-
  interval(S, N, 9).

chord_function(S, minor, N, [major], [predominant, 6]) :-
  interval(S, N, 8).

chord_function(S, Q, N, [Q], [predominant, 4]) :-
  interval(S, N, 5).

chord_function(S, minor, N, [diminished], [predominant, 2]) :-
  interval(S, N, 2).

chord_function(S, major, N, [minor], [predominant, 2]) :-
  interval(S, N, 2).

chord_function(S, Q, N, CQ, [sec_dom, X]) :-
  \+ tonal_chord_func(S, Q, N, CQ, _),
  chord_function(S, Q, B, _, [_ , X]),
  chord_function(B, _, N, CQ, [dominant, _]).

tonal_chord_func(S, Q, N, CQ, [F, I]) :-
  member(F, [tonic, dominant, predominant, tonic_sub]),
  chord_function(S, Q, N, CQ, [F, I]).

% progressions
prog_2([tonic, 1], [predominant, _]).
prog_2([tonic, 1], [dominant, 5]).

prog_2([predominant, X], [predominant, Y]) :-
  X > Y.

prog_2([predominant, _], [dominant, 5]).

prog_2([dominant, 5], [tonic, 1]).

prog_2([tonic_sub, _], X) :- prog_2([tonic, 1], X).
prog_2(X, [tonic_sub, _]) :- prog_2(X, [tonic, 1]).

prog_3(X, [sec_dom, R], [F, R]) :-
  prog_2(X, [F, R]).


progression_list([]).
progression_list([_]).
progression_list([X|[Y|Rest]]) :-
  prog_2(X, Y),
  progression_list([Y|Rest]).

progression_list([X|[Y|[Z|Rest]]]) :-
  not(prog_2(X, Y)),
  prog_3(X, Y, Z),
  progression_list([Z|Rest]).
