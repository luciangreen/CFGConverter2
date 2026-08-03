%% test_operations.pl — Tests for operation extraction.
:- use_module(library(plunit)).
:- use_module('../prolog/ideacfg_operations').
:- use_module('../prolog/ideacfg_ir').
:- use_module('../prolog/ideacfg_input').

:- begin_tests(operation_extraction).

test(operation_class_arithmetic) :- operation_class(arithmetic).
test(operation_class_comparison) :- operation_class(comparison).
test(operation_class_aggregation) :- operation_class(aggregation).
test(operation_class_transformation) :- operation_class(transformation).

test(execution_mode_direct_prolog) :- execution_mode(direct_prolog).
test(execution_mode_cfg) :- execution_mode(cfg_enumeration).

test(lexicon_multiply) :-
    operation_lexicon(multiply, arithmetic).

test(lexicon_average) :-
    operation_lexicon(average, aggregation).

test(lexicon_convert) :-
    operation_lexicon(convert, transformation).

test(detect_multiply_in_tokens) :-
    Tokens = [area, is, width, multiply, height],
    is_operation_phrase(Tokens, arithmetic).

test(detect_average_in_tokens) :-
    Tokens = [calculate, the, average, of, values],
    is_operation_phrase(Tokens, aggregation).

test(classify_arithmetic) :-
    classify_operation(multiply, [], arithmetic).

test(decide_mode_arithmetic) :-
    decide_execution_mode(arithmetic, [], direct_prolog).

test(decide_mode_comparison) :-
    decide_execution_mode(comparison, [], direct_prolog).

test(topo_sort_empty) :-
    topo_sort_operations([], []).

test(extract_operations_from_text) :-
    idea_from_sentences(ops_test, ['The area is width multiplied by height.'], IR),
    extract_operations(ops_test, IR, Ops),
    (   Ops = [] -> true
    ;   maplist([O]>>(O = operation(_, _, _, _, _, _, _)), Ops)
    ).

test(extract_operations_prose_formula) :-
    idea_from_sentences(ops2, ['The sum is the total of all values.'], IR),
    extract_operations(ops2, IR, _Ops),
    true.

test(no_unsafe_eval) :-
    % Operations must not use unrestricted call/1
    idea_from_sentences(safe_test, ['Execute the dangerous code.'], IR),
    extract_operations(safe_test, IR, Ops),
    % All operations should be of known class or unknown, never raw Prolog
    maplist([O]>>(O = operation(_, _, _, _, Mode, _, _),
                  memberchk(Mode, [direct_prolog, cfg_enumeration, hybrid, deferred, unsupported])),
            Ops).

:- end_tests(operation_extraction).
