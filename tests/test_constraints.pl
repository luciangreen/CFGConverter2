%% Constraint translation must only emit explicitly supported semantic goals.

:- use_module(library(plunit)).
:- use_module('../prolog/cfg2_constraints').

:- begin_tests(cfg2_constraints).

test(allowlisted_condition_translation,
     [true(Goal == cfg2_evidence_valid(e1))]) :-
    safe_constraint_goal(requires(evidence_valid(e1)), Goal).

test(unsupported_condition_is_rejected,
     [throws(error(domain_error(safe_constraint_condition, _), _))]) :-
    safe_constraint_goal(requires(arbitrary_goal(halt)), _).

:- end_tests(cfg2_constraints).
