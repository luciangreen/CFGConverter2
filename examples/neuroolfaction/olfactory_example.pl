%% examples/neuroolfaction/olfactory_example.pl
%% Example 2 from pr1.txt: Neuroolfactory measurement.

:- module(example_neuroolfaction, [run_example/0]).

:- use_module('../../prolog/cfg2_api').
:- use_module('../../prolog/cfg2_evidence').

%% Input matching requirements section 30.
example_input(
    evidence(
        e1,
        neuroolfaction,
        qualitative_measurement,
        response_intensity,
        strong,
        neuroolfactory_unit,
        context(stimulus(rose)),
        0.82,
        provenance(observer(o1)),
        time(t1),
        location(lab),
        []
    )
).

%% Expected interpretation (section 30).
expected_interpretation(
    interpretation(
        strong_olfactory_response,
        confidence(0.82),
        evidence([e1]),
        alternatives([])
    )
).

%% run_example/0: Demonstrates neuroolfactory CFG generation.
run_example :-
    example_input(EvidTerm),
    evidence_to_cfg(olfactory_study, neuroolfaction, [EvidTerm], [
        confidence_policy(weighted_indicators),
        intuition_policy(cautious)
    ], Result),
    Result = result(_, _, _, _, evidence(Evids), _, cfg(_, CFGText), _, _, _,
                    interpretations(Interps), _, _, _),
    format('=== Neuroolfaction Example ===~n'),
    format('Evidence loaded: ~w~n', [Evids]),
    format('CFG:~n~w~n~n', [CFGText]),
    format('Interpretations: ~w~n', [Interps]),
    format('=== End ===~n').
