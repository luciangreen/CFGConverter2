%% examples/literature/humanities_intuition_example.pl
%% Example 3 from pr1.txt: Humanities intuition.

:- module(example_literature, [run_example/0]).

:- use_module('../../prolog/cfg2_api').
:- use_module('../../prolog/cfg2_intuition').
:- use_module('../../prolog/cfg2_indicators').

%% Input matching requirements section 31.
example_intuition(
    intuition(
        in1,
        expert(reader_1),
        poem(p1),
        theme(displacement),
        [
            indicator(repeated_departure_images),
            indicator(fragmented_geography)
        ],
        0.68,
        [theme(memory), theme(exile)],
        stanza_range(1, 5),
        provenance(annotation_set(a1))
    )
).

%% Expected output (section 31).
expected_output(
    interpretation(
        theme(displacement),
        confidence(0.68),
        evidence([in1]),
        alternatives([theme(memory), theme(exile)]),
        status(supported_not_proven)
    )
).

run_example :-
    example_intuition(Int),
    intuition_to_interpretation(Int, cautious, Result),
    expected_output(Expected),
    format('=== Literature Intuition Example ===~n'),
    format('Input intuition: ~w~n', [Int]),
    format('Result: ~w~n', [Result]),
    format('Expected: ~w~n', [Expected]),
    format('=== End ===~n').
