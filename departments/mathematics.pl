%% departments/mathematics.pl
%% Mathematics department plugin for CFG Converter 2.
%%
%% Handles mathematical predicate formulae, equations, inequalities,
%% domains, assumptions, definitions, and proof-step relationships.

:- module(dept_mathematics,
    [
        valid_formula/1,
        formula_to_ir_element/3,
        math_safe_predicates/1,
        generate_proof_structure/3
    ]).

:- use_module(library(lists)).
:- use_module('../prolog/cfg2_evidence').
:- use_module('../prolog/cfg2_departments').

%% valid_formula(+Formula) is semidet.
%  True when Formula is a syntactically valid mathematical formula term.
%  IMPORTANT: This checks syntax, not truth.  No formula is executed.
valid_formula(F) :-
    \+ contains_unsafe_formula_call(F),
    formula_syntactically_valid(F).

formula_syntactically_valid(forall(_, Body)) :- formula_syntactically_valid(Body).
formula_syntactically_valid(exists(_, Body)) :- formula_syntactically_valid(Body).
formula_syntactically_valid(implies(A, B)) :-
    formula_syntactically_valid(A),
    formula_syntactically_valid(B).
formula_syntactically_valid(and(A, B)) :-
    formula_syntactically_valid(A),
    formula_syntactically_valid(B).
formula_syntactically_valid(or(A, B)) :-
    formula_syntactically_valid(A),
    formula_syntactically_valid(B).
formula_syntactically_valid(not(A)) :- formula_syntactically_valid(A).
formula_syntactically_valid(equals(_, _)).
formula_syntactically_valid(greater_than(_, _)).
formula_syntactically_valid(less_than(_, _)).
formula_syntactically_valid(plus(_, _, _)).
formula_syntactically_valid(minus(_, _, _)).
formula_syntactically_valid(times(_, _, _)).
formula_syntactically_valid(divides(_, _, _)).
formula_syntactically_valid(member(_, _)).
formula_syntactically_valid(even(_)).
formula_syntactically_valid(odd(_)).
formula_syntactically_valid(integer(_)).
formula_syntactically_valid(real(_)).
formula_syntactically_valid(positive(_)).
formula_syntactically_valid(negative(_)).
formula_syntactically_valid(zero(_)).
formula_syntactically_valid(F) :- atom(F).
formula_syntactically_valid(N) :- number(N).
formula_syntactically_valid(_V) :- var(_V).  % Variables are syntactically valid.

contains_unsafe_formula_call(call(_)) :- !.
contains_unsafe_formula_call(assert(_)) :- !.
contains_unsafe_formula_call(T) :-
    compound(T),
    T =.. [_|Args],
    member(A, Args),
    contains_unsafe_formula_call(A).

%% formula_to_ir_element(+FormulaEvidence, +Options, -IRElement) is det.
formula_to_ir_element(E, Options, IRElement) :-
    evidence_id(E, EId),
    evidence_value(E, Formula),
    evidence_subject(E, Subject),
    (   valid_formula(Formula)
    ->  IRElement = concept(EId, Subject, [formula_structure(Formula)],
                            dept(mathematics), [source(EId)])
    ;   IRElement = concept(EId, Subject, [invalid_formula(Formula)],
                            dept(mathematics), [source(EId), warning(invalid_formula)])
    ).

%% math_safe_predicates(-Predicates) is det.
%  Lists predicates that are safe to call in generated DCG semantic goals.
math_safe_predicates([
    valid_formula/1,
    validate_proof_chain/3,
    math_integer_check/1,
    math_positive_check/1
]).

%% generate_proof_structure(+Assumptions, +Derivations, -ProofCFGRules) is det.
generate_proof_structure(Assumptions, Derivations, Rules) :-
    length(Assumptions, NA),
    length(Derivations, ND),
    (   NA > 0, ND > 0
    ->  Rules = [
            cfg_rule(r_proof, proof, [assumption_block, derivation_block, conclusion_block],
                     [department(mathematics), derived_from(Assumptions)]),
            cfg_rule(r_assumption_block, assumption_block, Assumptions,
                     [department(mathematics)]),
            cfg_rule(r_derivation_block, derivation_block, Derivations,
                     [department(mathematics)])
        ]
    ;   Rules = [
            cfg_rule(r_proof_empty, proof, [statement_block],
                     [department(mathematics)])
        ]
    ).

%% Example:
%%   proof_step(step(modus_ponens, A, B)) -->
%%       premise(A),
%%       premise(implies(A, B)),
%%       { valid_formula(A), valid_formula(B) }.

:- initialization(
    format('Mathematics department plugin loaded.~n'),
    now
).
