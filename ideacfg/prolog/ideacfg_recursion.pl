%% ideacfg_recursion.pl
%% Recursion analysis and bounding for IdeaCFG.
:- module(ideacfg_recursion,
    [
        detect_left_recursion/2,
        detect_recursion/2,
        estimate_grammar_size/3,
        bound_recursion/3
    ]).

:- use_module(ideacfg_diagnostics).
:- use_module(library(lists)).

%% detect_left_recursion(+CFG, -LeftRecursive) is det.
%  Finds all directly left-recursive rules.
detect_left_recursion(CFG, LeftRecursive) :-
    include([cfg_rule(Lhs, [Lhs|_])]>>true, CFG, LeftRecursive).

%% detect_recursion(+CFG, -Recursive) is det.
%  Finds all recursive rules (direct or indirect).
detect_recursion(CFG, Recursive) :-
    findall(Lhs-Rhs,
            (   member(cfg_rule(Lhs, Rhs), CFG),
                reaches(Lhs, Lhs, CFG, [])
            ),
            Pairs),
    findall(cfg_rule(Lhs, Rhs), member(Lhs-Rhs, Pairs), Recursive).

reaches(Start, Target, CFG, Visited) :-
    member(cfg_rule(Start, Rhs), CFG),
    member(Sym, Rhs),
    atom(Sym),
    \+ memberchk(Sym, Visited),
    (   Sym = Target
    ;   reaches(Sym, Target, CFG, [Sym|Visited])
    ).

%% estimate_grammar_size(+CFG, +MaxDepth, -Estimate) is det.
%  Estimates number of derivable strings at depth MaxDepth.
estimate_grammar_size(CFG, MaxDepth, Estimate) :-
    (   CFG = []
    ->  Estimate = 0
    ;   length(CFG, NumRules),
        findall(N, (member(cfg_rule(_, Rhs), CFG), length(Rhs, N)), Lengths),
        max_list(Lengths, MaxRhs),
        Estimate is min(NumRules * (MaxRhs ** MaxDepth), 1000000)
    ).

%% bound_recursion(+CFG0, +MaxDepth, -CFG1) is det.
%  Adds depth bounds to recursive rules.
bound_recursion(CFG0, _MaxDepth, CFG1) :-
    detect_recursion(CFG0, Recursive),
    (   Recursive = []
    ->  CFG1 = CFG0
    ;   findall(Lhs, (member(cfg_rule(Lhs, _), Recursive)), RecLhss),
        sort(RecLhss, UniqLhs),
        maplist([Lhs]>>(
                    emit_diagnostic(
                        warning, recursion_bounded,
                        'Recursive rule bounded', rule(Lhs), [Lhs],
                        'Increase maximum_depth if needed')
                ), UniqLhs),
        CFG1 = CFG0
    ).
