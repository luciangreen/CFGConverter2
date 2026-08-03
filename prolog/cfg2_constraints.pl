%% cfg2_constraints.pl
%% Converts evidence into grammar constraints for CFG Converter 2.
%%
%% Required constraint forms:
%%   requires(EvidenceCondition)
%%   supports(EvidenceCondition)
%%   contradicts(EvidenceCondition)
%%   excludes(EvidenceCondition)
%%   prefers(EvidenceCondition)
%%   scores(ScoreExpression)
%%   bounded_by(Lower, Upper)
%%   observed_at(TimeCondition)
%%   located_at(LocationCondition)
%%   derived_from(SourceIds)

:- module(cfg2_constraints,
    [
        make_constraint/6,
        constraint_id/2,
        constraint_rule/2,
        constraint_form/2,
        constraint_sources/2,
        constraint_department/2,
        validate_constraint/3,
        constraint_to_dcg_goal/3,
        constraints_for_rule/3,
        safe_constraint_goal/2
    ]).

:- use_module(library(lists)).

%% make_constraint(+Id, +RuleCandidate, +Form, +Sources, +Dept) is det.
make_constraint(Id, RuleCandidate, Form, Sources, Dept,
                ir_constraint(Id, RuleCandidate, Form, Sources, Dept)).

%% Accessors
constraint_id(ir_constraint(Id,_,_,_,_), Id).
constraint_rule(ir_constraint(_,Rule,_,_,_), Rule).
constraint_form(ir_constraint(_,_,Form,_,_), Form).
constraint_sources(ir_constraint(_,_,_,Srcs,_), Srcs).
constraint_department(ir_constraint(_,_,_,_,Dept), Dept).

%% valid_constraint_form(+Form) is semidet.
valid_constraint_form(requires(_)).
valid_constraint_form(supports(_)).
valid_constraint_form(contradicts(_)).
valid_constraint_form(excludes(_)).
valid_constraint_form(prefers(_)).
valid_constraint_form(scores(_)).
valid_constraint_form(bounded_by(_, _)).
valid_constraint_form(observed_at(_)).
valid_constraint_form(located_at(_)).
valid_constraint_form(derived_from(_)).

%% validate_constraint(+Constraint, +Options, -Errors) is det.
validate_constraint(C, _Opts, Errors) :-
    (   C = ir_constraint(Id, _Rule, Form, Sources, _Dept)
    ->  Errs0 = [],
        ( (atom(Id) ; integer(Id)) -> Errs1 = Errs0
        ; Errs1 = [error(constraint_id, atom_or_integer, Id)|Errs0] ),
        ( valid_constraint_form(Form) -> Errs2 = Errs1
        ; Errs2 = [error(form, valid_constraint_form, Form)|Errs1] ),
        ( is_list(Sources) -> Errors = Errs2
        ; Errors = [error(sources, list, Sources)|Errs2] )
    ;   Errors = [error(structure, ir_constraint_5_args, C)]
    ).

%% safe_constraint_goal(+Form, -SafeGoal) is det.
%  Maps a constraint form to a safe DCG semantic goal term.
%  Only known approved predicates are emitted.
safe_constraint_goal(requires(Cond), Goal) :-
    safe_condition_goal(Cond, Goal).
safe_constraint_goal(supports(Cond), Goal) :-
    safe_condition_goal(Cond, Goal).
safe_constraint_goal(contradicts(Cond), not(Goal)) :-
    safe_condition_goal(Cond, Goal).
safe_constraint_goal(excludes(Cond), \+(Goal)) :-
    safe_condition_goal(Cond, Goal).
safe_constraint_goal(prefers(Cond), Goal) :-
    safe_condition_goal(Cond, Goal).
safe_constraint_goal(scores(Expr), cfg2_score(Expr)).
safe_constraint_goal(bounded_by(Lo, Hi), cfg2_bounded(Lo, Hi)).
safe_constraint_goal(observed_at(T), cfg2_observed_at(T)).
safe_constraint_goal(located_at(L), cfg2_located_at(L)).
safe_constraint_goal(derived_from(Ids), cfg2_derived_from(Ids)).

%% safe_condition_goal(+Condition, -Goal) is det.
safe_condition_goal(evidence_valid(Id),           cfg2_evidence_valid(Id)).
safe_condition_goal(evidence_value(Id, V),         cfg2_evidence_value(Id, V)).
safe_condition_goal(measurement_above(Id, Level),  cfg2_measurement_above(Id, Level)).
safe_condition_goal(measurement_below(Id, Level),  cfg2_measurement_below(Id, Level)).
safe_condition_goal(qualitative_at_least(V, T),    cfg2_qualitative_at_least(V, T)).
safe_condition_goal(evidence_measurement(Id, S, V),cfg2_evidence_measurement(Id, S, V)).
safe_condition_goal(valid_formula(F),              cfg2_valid_formula(F)).
safe_condition_goal(valid_stimulus(S),             cfg2_valid_stimulus(S)).
safe_condition_goal(evidence_in_range(Id),         cfg2_evidence_in_range(Id)).
safe_condition_goal(Cond, cfg2_unknown_condition(Cond)).

%% constraint_to_dcg_goal(+Constraint, +Options, -Goal) is det.
constraint_to_dcg_goal(C, _Opts, Goal) :-
    constraint_form(C, Form),
    safe_constraint_goal(Form, Goal).

%% constraints_for_rule(+RuleId, +AllConstraints, -Relevant) is det.
constraints_for_rule(RuleId, AllConstraints, Relevant) :-
    include([C]>>(constraint_rule(C, rule_candidate(RuleId))), AllConstraints, Relevant).
