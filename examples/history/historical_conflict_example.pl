%% examples/history/historical_conflict_example.pl
%% Acceptance Test D: Conflicting historical indicators.

:- module(example_history, [run_example/0]).

:- use_module('../../prolog/cfg2_api').
:- use_module('../../prolog/cfg2_evidence').
:- use_module('../../prolog/cfg2_indicators').
:- use_module('../../departments/humanities').

run_example :-
    Indicator1 = indicator(i1, history, document(letter_42),
                           dated_1812, supports(authored_in_1812),
                           strong, 0.7, archive_3,
                           provenance(expert(e1))),
    Indicator2 = indicator(i2, history, document(letter_42),
                           watermark_analysis, supports(authored_after_1815),
                           moderate, 0.65, archive_3,
                           provenance(expert(e2))),
    Evidence1 = evidence(hist_e1, history, archival_record, letter_42,
                         dated_1812, year, context(archive_3),
                         0.7, provenance(archivist(a1)), time(unknown),
                         location(archive_3), [indicator_ref(i1)]),
    Evidence2 = evidence(hist_e2, history, archival_record, letter_42,
                         post_1815, year, context(archive_3),
                         0.65, provenance(analyst(a2)), time(unknown),
                         location(archive_3), [indicator_ref(i2)]),
    evidence_to_cfg(letter_conflict, history, [Evidence1, Evidence2], [
        conflict_policy(retain_all),
        intuition_policy(cautious)
    ], Result),
    Result = result(_, _, _, _, evidence(Evids), _, cfg(_, CFGText), _, _, _,
                    _, _, _, diagnostics(Diags)),
    format('=== Historical Conflict Example ===~n'),
    format('Evidence: ~w records~n', [Evids]),
    format('CFG:~n~w~n~n', [CFGText]),
    format('Diagnostics: ~w~n', [Diags]),
    conflicting_humanities_evidence([Evidence1, Evidence2], letter_42, Conflicts),
    format('Conflicts retained: ~w~n', [Conflicts]),
    format('=== End ===~n').
