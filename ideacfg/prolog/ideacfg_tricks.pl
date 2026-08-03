%% ideacfg_tricks.pl
%% Library of CFG conversion tricks.
:- module(ideacfg_tricks,
    [
        trick/4,
        apply_trick/4,
        applicable_tricks/3,
        list_tricks/1
    ]).

:- use_module(ideacfg_diagnostics).
:- use_module(library(lists)).

%% trick(?Name, ?Applies, ?Transforms, ?Assumptions) is nondet.
%  Describes a registered CFG trick.
trick(category_abstraction,
    'Related items become a category alternative',
    'A → B | C | D becomes CATEGORY → B | C | D',
    ['Items are genuine alternatives', 'No ordering required']).
trick(sequence_extraction,
    'Ordered parts become a sequence',
    'A contains B C D becomes A → B C D',
    ['Order is fixed', 'All parts required unless marked optional']).
trick(alternative_extraction,
    'Choices become alternatives',
    'A may be B or C becomes A → B | C',
    ['All alternatives are valid', 'No ordering preference']).
trick(optionality,
    'Optional elements use epsilon production',
    'may include X becomes OPTIONAL_X → X | ε',
    ['Absence is valid', 'At most one occurrence unless also repeated']).
trick(bounded_repetition,
    'One or more uses right-recursive rule',
    'one or more X becomes X_LIST → X X_LIST | ε',
    ['Recursion is bounded by maximum_depth', 'At least one occurrence required']).
trick(recursive_hierarchy,
    'Self-similar structures use bounded recursion',
    'may contain subsections becomes SECTION → CONTENT SUBSECTIONS; SUBSECTIONS → SECTION SUBSECTIONS | ε',
    ['Recursion depth is bounded', 'Terminal base case exists']).
trick(feature_splitting,
    'Finite dependencies become feature arguments',
    'statement(Domain, Level) --> subject(Domain, Level), predicate(Domain, Level)',
    ['Feature domain is finite', 'Feature values are enumerable']).
trick(state_threading,
    'Mutable state uses DCG arguments',
    'process(S0, S) --> step(S0, S1), process(S1, S)',
    ['State is explicit', 'No hidden global mutable state']).
trick(common_prefix_factoring,
    'Common prefixes are factored',
    'A → X B | X C becomes A → X A_TAIL; A_TAIL → B | C',
    ['Factoring preserves language', 'Applied only to exact prefix matches']).
trick(common_suffix_factoring,
    'Common suffixes are factored',
    'A → B X | C X becomes A → A_HEAD X; A_HEAD → B | C',
    ['Factoring preserves language']).
trick(left_recursion_elimination,
    'Left recursion is eliminated',
    'A → A x | y becomes A → y A_TAIL; A_TAIL → x A_TAIL | ε',
    ['Language is preserved', 'Semantic actions may require adjustment']).
trick(semantic_filtering,
    'Grammar generates candidates filtered by Prolog',
    'valid_candidate(Tree) :- domain_constraints(Tree)',
    ['Filtering is deterministic', 'Filter does not generate']).
trick(bounded_cross_dependency,
    'Non-context-free dependencies are bounded',
    'Use feature arguments or post-parse validation',
    ['Approximation is documented', 'Depth bound is configurable']).

%% applicable_tricks(+IR, +Options, -Tricks) is det.
%  Returns tricks applicable given the IR and options.
applicable_tricks(_IR, Options, Tricks) :-
    findall(Name,
            (   trick(Name, _, _, _),
                trick_enabled(Name, Options)
            ),
            Tricks).

trick_enabled(common_prefix_factoring, Options) :-
    memberchk(factor_common_prefixes(true), Options), !.
trick_enabled(common_suffix_factoring, Options) :-
    memberchk(factor_common_suffixes(true), Options), !.
trick_enabled(left_recursion_elimination, Options) :-
    memberchk(eliminate_left_recursion(true), Options), !.
trick_enabled(Name, _Options) :-
    trick(Name, _, _, _),
    \+ memberchk(Name, [common_prefix_factoring,
                         common_suffix_factoring,
                         left_recursion_elimination]).

%% apply_trick(+TrickName, +CFG0, +Options, -CFG1) is semidet.
%  Applies a named trick to a CFG.
apply_trick(left_recursion_elimination, CFG0, _Options, CFG1) :-
    eliminate_all_left_recursion(CFG0, CFG1), !.
apply_trick(common_prefix_factoring, CFG0, _Options, CFG1) :-
    factor_all_common_prefixes(CFG0, CFG1), !.
apply_trick(common_suffix_factoring, CFG0, _Options, CFG1) :-
    factor_all_common_suffixes(CFG0, CFG1), !.
apply_trick(_, CFG, _, CFG).

%% list_tricks(-Names) is det.
list_tricks(Names) :-
    findall(N, trick(N, _, _, _), Names).

% Left recursion elimination implementation
eliminate_all_left_recursion(CFG0, CFG1) :-
    foldl([Rule, Acc0, Acc1]>>(
              (   left_recursive(Rule)
              ->  eliminate_left_recursion(Rule, NewRules),
                  append(Acc0, NewRules, Acc1)
              ;   append(Acc0, [Rule], Acc1)
              )
          ), CFG0, [], CFG1).

left_recursive(cfg_rule(Lhs, [Lhs|_])).

eliminate_left_recursion(cfg_rule(Lhs, [Lhs|Alpha]), NewRules) :-
    TailId = Lhs,
    atomic_list_concat([Lhs, '_tail'], TailLhs),
    findall(cfg_rule(Lhs, Body),
            (   member(cfg_rule(Lhs, Rhs), [cfg_rule(Lhs, [Lhs|Alpha])]),
                Rhs \= [Lhs|_],
                append(Rhs, [TailId], Body)
            ),
            BaseRules),
    (   BaseRules = []
    ->  NewRules = [cfg_rule(TailLhs, Alpha), cfg_rule(TailLhs, [])]
    ;   append(BaseRules, [cfg_rule(TailLhs, Alpha), cfg_rule(TailLhs, [])], NewRules)
    ).

% Common prefix factoring
factor_all_common_prefixes(CFG0, CFG1) :-
    findall(Lhs, (member(cfg_rule(Lhs, _), CFG0)), Lhss),
    sort(Lhss, UniqLhs),
    foldl([Lhs, Acc0, Acc1]>>(
              findall(Rhs, member(cfg_rule(Lhs, Rhs), Acc0), Rhss),
              factor_rules(Lhs, Rhss, Acc0, Acc1)
          ), UniqLhs, CFG0, CFG1).

factor_rules(_Lhs, [], CFG, CFG) :- !.
factor_rules(_Lhs, [_], CFG, CFG) :- !.
factor_rules(Lhs, Rhss, CFG0, CFG1) :-
    (   common_prefix(Rhss, Prefix), Prefix \= []
    ->  atomic_list_concat([Lhs, '_tail'], TailLhs),
        findall(Tail, (member(Rhs, Rhss), append(Prefix, Tail, Rhs)), Tails),
        findall(cfg_rule(Lhs, R), (member(Rhs, Rhss), \+ append(Prefix, _, Rhs)), OtherRules),
        TailRules = [cfg_rule(Lhs, [TailLhs|Prefix]) | OtherRules],
        maplist([T, cfg_rule(TailLhs, T)]>>true, Tails, TailProdRules),
        subtract(CFG0, findall(cfg_rule(Lhs, R), member(R, Rhss), _), CFG0b),
        select_all_lhs(Lhs, CFG0, CFG0b),
        append(CFG0b, TailRules, CFG0c),
        append(CFG0c, TailProdRules, CFG1)
    ;   CFG1 = CFG0
    ).

common_prefix([[H|_]|Rest], [H|Prefix]) :-
    maplist([Rhs]>>(Rhs = [H|_]), Rest),
    maplist([Rhs, Tail]>>(Rhs = [H|Tail]), [[H|_]|Rest], Tails),
    common_prefix(Tails, Prefix), !.
common_prefix(_, []).

select_all_lhs(Lhs, CFG, Remaining) :-
    exclude([cfg_rule(L, _)]>>(L = Lhs), CFG, Remaining).

factor_all_common_suffixes(CFG, CFG). % Stub
