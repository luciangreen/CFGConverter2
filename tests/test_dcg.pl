%% tests/test_dcg.pl
%% DCG generation tests for CFG Converter 2.

:- use_module(library(plunit)).
:- use_module('../prolog/cfg2_dcg').
:- use_module('../prolog/cfg2_evidence').

:- begin_tests(dcg_generation).

test(dcg_clause_accessors, [true]) :-
    C = dcg_clause(head(sym, [a, b]), body([], [], sources([s1]))),
    dcg_clause_head(C, head(sym, [a, b])),
    dcg_clause_body(C, body([], [], sources([s1]))).

test(evidence_guarded_branch, [true(nonvar(Clause))]) :-
    evidence_guarded_branch(olfactory_response, e1,
                            [requires(e1)], Clause).

test(dcg_to_prolog_empty, [true(Text = '')]) :-
    dcg_to_prolog([], Text).

test(dcg_to_prolog_nonempty, [true(Text \= '')]) :-
    Clause = dcg_clause(
        head(test_sym, [tree(test_sym, []), sem([]), evstate([])]),
        body([], [cfg2_evidence_valid(e1)], sources([e1]))
    ),
    dcg_to_prolog([Clause], Text).

test(generate_dcg2_basic, [true(DCGClauses \= [])]) :-
    E = evidence(e1, neuroolfaction, qualitative_measurement, subject,
                 strong, neuroolfactory_unit, context([]), 0.8,
                 provenance([]), unknown, unknown, []),
    IR = cfg2_ir(test_dcg, metadata([]), [],
                 [], [], [E], [], [], [], []),
    generate_dcg2(test_dcg, IR, [E], DCGClauses).

:- end_tests(dcg_generation).
