%% tests/test_api.pl
%% API compatibility and basic operation tests for CFG Converter 2.

:- use_module(library(plunit)).
:- use_module('../prolog/cfg2_api').
:- use_module('../prolog/cfg2_evidence').
:- use_module('../prolog/cfg2_departments').

:- begin_tests(api_compatibility).

%% Acceptance Test A: Original text-to-CFG interface still works.
test(idea_to_cfg_basic, [true(Result = result(_, cfg(_, _), _, _, _, _))]) :-
    idea_to_cfg(test_idea, 'A cat sits on a mat.', Result).

test(idea_to_cfg_with_options, [true(nonvar(Result))]) :-
    idea_to_cfg(test_idea2, 'A dog runs fast.', Result).

test(idea_to_cfg_list_input, [true(nonvar(Result))]) :-
    idea_to_cfg(test_idea3, ['An animal moves.', 'A plant grows.'], Result).

:- end_tests(api_compatibility).

:- begin_tests(evidence_api).

test(evidence_to_cfg_basic, [true(nonvar(Result))]) :-
    E = evidence(e1, neuroolfaction, qualitative_measurement,
                 response_intensity, strong, neuroolfactory_unit,
                 context([]), 0.82, provenance([]), unknown, unknown, []),
    evidence_to_cfg(test_olf, neuroolfaction, [E], Result).

test(data_to_cfg_empty, [true(nonvar(Result))]) :-
    data_to_cfg(empty_test, [], [], Result).

test(hybrid_to_cfg, [true(nonvar(Result))]) :-
    E = evidence(e2, mathematics, formula, axiom, forall(x, integer(x)),
                 formula_unit, context([]), 0.9, provenance([]),
                 unknown, unknown, []),
    hybrid_to_cfg(hybrid_test, mathematics, 'Mathematical proof structure.',
                  [prolog([E])], [], Result).

test(validate_evidence_passes, [true(Errors = [])]) :-
    E = evidence(e3, history, archival_record, document, value1,
                 text, context([]), 0.7, provenance([]), unknown, unknown, []),
    validate_evidence([E], [], Errors).

test(validate_evidence_fails, [true(Errors \= [])]) :-
    E = evidence(not_valid, bad_dept, bad_type, subj, val, unit,
                 ctx, 99.0, prov, time, loc, meta),
    validate_evidence([E], [], Errors).

test(load_evidence_prolog, [true(Evidence \= [])]) :-
    E = evidence(le1, physics, observation, temperature, 273.15,
                 kelvin, context([]), 0.9, provenance([]),
                 unknown, unknown, []),
    load_evidence(prolog_terms, [E], [], Evidence).

test(explain_derivation_no_context, [true(nonvar(Expl))]) :-
    explain_derivation(r1, no_result, Expl).

:- end_tests(evidence_api).

:- begin_tests(department_api).

test(compile_department_mathematics, [true(nonvar(R))]) :-
    compile_department(mathematics, cfg2_ir(test,[],[],[],[],[],[],[],[],[]), [], R).

test(compile_department_unknown, [true(R = error(department_not_registered(nonexistent)))]) :-
    compile_department(nonexistent, [], [], R).

:- end_tests(department_api).
