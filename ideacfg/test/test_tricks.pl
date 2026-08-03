%% test_tricks.pl — Tests for grammar tricks.
:- use_module(library(plunit)).
:- use_module('../prolog/ideacfg_tricks').
:- use_module('../prolog/ideacfg_factoring').
:- use_module('../prolog/ideacfg_optimise').

:- begin_tests(grammar_factoring).

test(list_tricks_nonempty) :-
    list_tricks(Tricks),
    Tricks \= [].

test(trick_category_abstraction_exists) :-
    trick(category_abstraction, _, _, _).

test(trick_sequence_extraction_exists) :-
    trick(sequence_extraction, _, _, _).

test(trick_left_recursion_elimination_exists) :-
    trick(left_recursion_elimination, _, _, _).

test(trick_bounded_repetition_exists) :-
    trick(bounded_repetition, _, _, _).

test(applicable_tricks_with_defaults) :-
    applicable_tricks(_, [factor_common_prefixes(true),
                           factor_common_suffixes(true),
                           eliminate_left_recursion(true)], Tricks),
    Tricks \= [].

test(apply_trick_no_left_rec) :-
    CFG = [cfg_rule(a, [b, c]), cfg_rule(b, [terminal(x)])],
    apply_trick(left_recursion_elimination, CFG, [], CFG1),
    length(CFG1, N), N >= 2.

test(apply_trick_with_left_rec) :-
    CFG = [cfg_rule(expr, [expr, +, term]), cfg_rule(expr, [term])],
    apply_trick(left_recursion_elimination, CFG, [], CFG1),
    \+ member(cfg_rule(expr, [expr|_]), CFG1).

test(remove_duplicates) :-
    remove_duplicates(
        [cfg_rule(a, [b]), cfg_rule(a, [b]), cfg_rule(c, [d])],
        Clean),
    length(Clean, 2).

:- end_tests(grammar_factoring).

:- begin_tests(left_recursion).

test(factor_prefixes_two_rules) :-
    CFG = [cfg_rule(a, [x, b]), cfg_rule(a, [x, c])],
    factor_prefixes(CFG, CFG1),
    length(CFG1, N), N >= 2.

:- end_tests(left_recursion).
