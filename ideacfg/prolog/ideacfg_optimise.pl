%% ideacfg_optimise.pl
%% Grammar and operation optimisation for IdeaCFG.
:- module(ideacfg_optimise,
    [
        optimise_cfg/3,
        remove_unreachable/2,
        remove_unproductive/2,
        remove_duplicates/2,
        apply_all_optimisations/3
    ]).

:- use_module(ideacfg_cfg).
:- use_module(ideacfg_factoring).
:- use_module(ideacfg_recursion).
:- use_module(ideacfg_diagnostics).
:- use_module(library(lists)).

%% optimise_cfg(+CFG0, +Options, -CFG1) is det.
%  Applies all applicable optimisations.
optimise_cfg(CFG0, Options, CFG1) :-
    apply_all_optimisations(CFG0, Options, CFG1).

%% apply_all_optimisations(+CFG0, +Options, -CFG1) is det.
apply_all_optimisations(CFG0, Options, CFG4) :-
    remove_duplicates(CFG0, CFG1),
    remove_unproductive(CFG1, CFG2),
    remove_unreachable(CFG2, CFG3),
    (   memberchk(eliminate_left_recursion(true), Options)
    ->  remove_left_recursion(CFG3, CFG4)
    ;   CFG4 = CFG3
    ).

%% remove_duplicates(+CFG0, -CFG1) is det.
remove_duplicates(CFG0, CFG1) :-
    sort(CFG0, CFG1).

%% remove_unreachable(+CFG0, -CFG1) is det.
%  Removes unreachable productions (those whose Lhs never appears in any Rhs,
%  except for the first production which is assumed to be the start symbol).
remove_unreachable([], []) :- !.
remove_unreachable(CFG0, CFG1) :-
    CFG0 = [cfg_rule(Start, _)|_],
    reachable_from(Start, CFG0, Reachable),
    include([cfg_rule(Lhs, _)]>>(memberchk(Lhs, Reachable)), CFG0, CFG1).

reachable_from(Start, CFG, Reachable) :-
    reachable_set([Start], CFG, Reachable).

reachable_set(Frontier, CFG, All) :-
    findall(Sym,
            (   member(F, Frontier),
                member(cfg_rule(F, Rhs), CFG),
                member(Sym, Rhs),
                atom(Sym),
                Sym \= epsilon
            ),
            NewSyms),
    sort(NewSyms, NewSorted),
    subtract(NewSorted, Frontier, NewFrontier),
    (   NewFrontier = []
    ->  append(Frontier, [], All)
    ;   reachable_set(NewFrontier, CFG, RestAll),
        append(Frontier, RestAll, All)
    ).

%% remove_unproductive(+CFG0, -CFG1) is det.
%  Removes rules that can never produce a terminal string.
remove_unproductive(CFG0, CFG1) :-
    productive_set(CFG0, Productive),
    include([cfg_rule(Lhs, Rhs)]>>(
                memberchk(Lhs, Productive),
                maplist([S]>>(
                            atom(S)
                        ->  (   memberchk(S, Productive)
                            ;   \+ member(cfg_rule(S, _), CFG0)  % atom with no rule = terminal
                            )
                        ;   true
                        ), Rhs)
            ), CFG0, CFG1).

productive_set(CFG, Productive) :-
    findall(Lhs, (member(cfg_rule(Lhs, Rhs), CFG), base_productive(Rhs, CFG)), BaseProd),
    sort(BaseProd, Productive0),
    expand_productive(Productive0, CFG, Productive).

base_productive([], _).
base_productive([terminal(_)|_], _).
base_productive(Rhs, CFG) :-
    Rhs \= [],
    % A rule is base-productive if all RHS symbols are terminals or atoms with no production
    maplist([S]>>(\+ member(cfg_rule(S, _), CFG)), Rhs).

expand_productive(Prod0, CFG, Prod1) :-
    findall(Lhs,
            (   member(cfg_rule(Lhs, Rhs), CFG),
                \+ memberchk(Lhs, Prod0),
                maplist([S]>>(
                            atom(S)
                        ->  (   memberchk(S, Prod0)
                            ;   \+ member(cfg_rule(S, _), CFG)
                            )
                        ;   true
                        ), Rhs)
            ),
            NewProd),
    sort(NewProd, NewProdSorted),
    (   NewProdSorted = []
    ->  Prod1 = Prod0
    ;   append(Prod0, NewProdSorted, Prod0b),
        sort(Prod0b, Prod0bSorted),
        expand_productive(Prod0bSorted, CFG, Prod1)
    ).
