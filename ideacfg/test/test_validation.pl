%% test_validation.pl — Tests for grammar and operation validation.
:- use_module(library(plunit)).
:- use_module('../prolog/ideacfg_validate').
:- use_module('../prolog/ideacfg_ir').
:- use_module('../prolog/ideacfg_input').

:- begin_tests(validation_module).

test(validate_grammar_valid_cfg) :-
    validate_grammar([cfg_rule(a, [b]), cfg_rule(b, [terminal(x)])], Diags),
    \+ member(diagnostic(error, _, _, _, _, _), Diags).

test(validate_grammar_undefined_nt) :-
    validate_grammar([cfg_rule(a, [b, undefined_nt])], Diags),
    member(diagnostic(warning, undefined_nonterminal, _, _, _, _), Diags).

test(validate_grammar_left_recursion) :-
    validate_grammar([cfg_rule(a, [a, b])], Diags),
    member(diagnostic(warning, left_recursion, _, _, _, _), Diags).

test(validate_operations_empty) :-
    validate_operations([], []).

test(validate_idea_produces_report) :-
    idea_from_terms(val_test, [sequence(s, [a, b], [], src)], IR),
    validate_idea(val_test, IR, Report),
    Report = validation_report(val_test, _).

test(validate_generated_code_nonempty) :-
    validate_generated_code(':- module(test, []).', Diags),
    Diags = [].

test(validate_generated_code_empty) :-
    validate_generated_code('', Diags),
    member(diagnostic(error, empty_module, _, _, _, _), Diags).

:- end_tests(validation_module).
