%% ideacfg_factoring.pl
%% Grammar factoring utilities for IdeaCFG.
:- module(ideacfg_factoring,
    [
        factor_prefixes/2,
        factor_suffixes/2,
        common_prefix_of/3,
        remove_left_recursion/2
    ]).

:- use_module(library(lists)).

%% factor_prefixes(+CFG0, -CFG1) is det.
%  Applies common-prefix factoring to a CFG.
factor_prefixes(CFG0, CFG1) :-
    findall(Lhs, (member(cfg_rule(Lhs, _), CFG0)), AllLhs),
    sort(AllLhs, UniqLhs),
    foldl([Lhs, Acc0, Acc1]>>(
              findall(Rhs, member(cfg_rule(Lhs, Rhs), Acc0), Rhss),
              (   length(Rhss, N), N > 1,
                  common_prefix_of(Rhss, Prefix, _), Prefix \= []
              ->  factor_lhs(Lhs, Rhss, Prefix, Acc0, Acc1)
              ;   Acc1 = Acc0
              )
          ), UniqLhs, CFG0, CFG1).

factor_lhs(Lhs, Rhss, Prefix, CFG0, CFG1) :-
    atomic_list_concat([Lhs, '_rest'], RestLhs),
    maplist([Rhs, Tail]>>(append(Prefix, Tail, Rhs) -> true ; Tail = Rhs), Rhss, Tails),
    NewBaseRule = cfg_rule(Lhs, [RestLhs|Prefix]),
    maplist([Tail, cfg_rule(RestLhs, Tail)]>>true, Tails, RestRules),
    exclude([cfg_rule(L, R)]>>(L = Lhs, memberchk(R, Rhss)), CFG0, CFG0b),
    append([NewBaseRule | RestRules], CFG0b, CFG1).

%% factor_suffixes(+CFG0, -CFG1) is det.
%  Applies common-suffix factoring to a CFG (stub).
factor_suffixes(CFG, CFG).

%% common_prefix_of(+ListOfLists, -Prefix, -Remainders) is semidet.
%  Finds the longest common prefix of all lists.
common_prefix_of([], [], []) :- !.
common_prefix_of([First|Rest], Prefix, Remainders) :-
    foldl([List, P0, P1]>>(
              common_prefix_two(P0, List, P1)
          ), Rest, First, Prefix),
    maplist([List, Rem]>>(append(Prefix, Rem, List)), [First|Rest], Remainders).

common_prefix_two([H|T1], [H|T2], [H|Prefix]) :-
    common_prefix_two(T1, T2, Prefix), !.
common_prefix_two(_, _, []).

%% remove_left_recursion(+CFG0, -CFG1) is det.
%  Eliminates all direct left recursion.
remove_left_recursion(CFG0, CFG1) :-
    partition([cfg_rule(Lhs, [Lhs|_])]>>true, CFG0, LeftRec, NonLeftRec),
    (   LeftRec = []
    ->  CFG1 = CFG0
    ;   maplist([cfg_rule(Lhs, [Lhs|Alpha])]>>(
                    atomic_list_concat([Lhs, '_tail'], TailLhs),
                    findall(cfg_rule(Lhs, B),
                            (member(cfg_rule(Lhs, R), NonLeftRec),
                             append(R, [TailLhs], B)), BaseRules),
                    maplist(assert_rule, BaseRules),
                    assert_rule(cfg_rule(TailLhs, Alpha)),
                    assert_rule(cfg_rule(TailLhs, []))
                ), LeftRec),
        findall(R, tmp_rule(R), NewRules),
        retractall(tmp_rule(_)),
        subtract(CFG0, LeftRec, Remaining),
        subtract(Remaining, findall(cfg_rule(L,_),(member(cfg_rule(L,_), NewRules)), _), Rem2),
        append(Rem2, NewRules, CFG1)
    ).

:- dynamic tmp_rule/1.
assert_rule(R) :- assertz(tmp_rule(R)).
