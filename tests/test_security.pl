%% tests/test_security.pl
%% Security and safety tests for CFG Converter 2.
%%
%% Acceptance Test F: Malicious text remains data, never executed.

:- use_module(library(plunit)).
:- use_module('../prolog/cfg2_validate').
:- use_module('../prolog/cfg2_sources').
:- use_module('../prolog/cfg2_evidence').
:- use_module('../prolog/cfg2_codegen').

:- begin_tests(security).

%% Acceptance Test F: Embedded Prolog goal stays as data.
test(prolog_injection_stays_data, [true(Evidence \= [])]) :-
    % A value that looks like a Prolog call should stay as a data value.
    E = evidence(evil, test, observation, subject,
                 'call(halt)', text, context([]), unknown,
                 provenance([]), unknown, unknown, []),
    source_adapter(prolog_terms, [E], [], Evidence),
    Evidence = [E2|_],
    evidence_value(E2, V),
    V = 'call(halt)'.  % value is data, not executed

test(unsafe_call_detected, [true(Errors \= [])]) :-
    check_safety([call(write(hello))], [], Errors).

test(safe_term_passes, [true(Errors = [])]) :-
    check_safety([evidence(e1, dept, type, subj, val, unit,
                            context([]), 0.5, provenance([]),
                            unknown, unknown, [])], [], Errors).

test(path_traversal_rejected, [throws(error(unsafe_path(_), _))]) :-
    export_cfg2(result(project(test), department(test), schemas([]),
                       sources([]), evidence([]), ir(none),
                       cfg([], ''), dcg([]), operations([]),
                       constraints([]), interpretations([]),
                       module(''), explanations([]), diagnostics([])),
                prolog, '../../../etc/passwd', []).

test(unsafe_predicate_not_in_allowlist, [true(Goal \= call(_))]) :-
    Constraint = ir_constraint(c1, rule_candidate(r1),
                               requires(evidence_valid(e1)), [e1], test),
    constraint_form(Constraint, Form),
    safe_constraint_goal(Form, Goal).

test(confidence_out_of_range_rejected, [true(Errors \= [])]) :-
    E = evidence(e1, test_dept, qualitative_measurement, subj, val, unit,
                 context([]), 99.0, provenance([]), unknown, unknown, []),
    validate_evidence([E], [], Errors).

:- end_tests(security).

:- use_module('../prolog/cfg2_constraints').
