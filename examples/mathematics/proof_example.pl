%% examples/mathematics/proof_example.pl
%% Example 1 from pr1.txt: Mathematics proof structure.

:- module(example_mathematics, [run_example/0]).

:- use_module('../../prolog/cfg2_api').
:- use_module('../../prolog/cfg2_evidence').

%% Input matching requirements section 29.
example_input([
    formula(f1, plus(2, 3, 5)),
    formula(f2, implies(even(x), integer(x))),
    relation(sequence, [assumption, derivation, conclusion])
]).

%% run_example/0: Demonstrates mathematics CFG generation.
run_example :-
    example_input(Input),
    % Load as formula terms evidence
    load_evidence(formula_terms, Input, [], Evidence),
    evidence_to_cfg(math_proof, mathematics, Evidence, [
        confidence_policy(numeric),
        intuition_policy(strict)
    ], Result),
    Result = result(_, _, _, _, _, _, cfg(_, CFGText), dcg(DCGClauses), _, _, _, _, _, _),
    format('=== Mathematics Example ===~n'),
    format('CFG:~n~w~n~n', [CFGText]),
    format('DCG clauses: ~w~n', [DCGClauses]),
    format('=== End ===~n').
