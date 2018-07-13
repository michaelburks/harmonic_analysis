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
function(S, Q, S, [Q], [tonic, 1]).

function(S, _, N, [major], [dominant, 5]) :-
  interval(S, N, 7).

function(S, _, N, [dominant, 7], [dominant, 5]) :-
  interval(S, N, 7).

function(S, major, N, [minor], [predominant, 6]) :-
  interval(S, N, 9).

function(S, minor, N, [major], [predominant, 6]) :-
  interval(S, N, 8).

function(S, Q, N, [Q], [predominant, 4]) :-
  interval(S, N, 5).

function(S, minor, N, [diminished], [predominant, 2]) :-
  interval(S, N, 2).

function(S, major, N, [minor], [predominant, 2]) :-
  interval(S, N, 2).

% progressions
progression([tonic, 1], [predominant, _]).
progression([tonic, 1], [dominant, 5]).

progression([predominant, X], [predominant, Y]) :-
  X > Y.

progression([predominant, _], [dominant, 5]).

progression([dominant, 5], [tonic, 1]).

progression(X, X).

% analysis
% Example:
% ?- analyze([[g,d,b], [c,e,g], [c,e,a], [c,d,f_sharp,a], [b,d,g]], A).
analyze([], _, []).
analyze([Notes|Rest], [S,Q], A) :-
  permutation(Notes, [CR|CRest]),
  chord([CR|CRest], CQ),
  function(S, Q, CR, CQ, CF),
  analyze_h(S, Q, Rest, [CF], A).

analyze_h(_, _, [], Fs, A) :- reverse(Fs, A).

analyze_h(S, Q, [Notes|Rest], [PrevF|Fs], A) :-
  permutation(Notes, [CR|CRest]),
  chord([CR|CRest], CQ),
  function(S, Q, CR, CQ, CF),
  progression(PrevF, CF),
  analyze_h(S, Q, Rest, [CF|[PrevF|Fs]], A).
