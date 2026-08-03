%% tests/test_evidence.pl
%% Evidence model tests for CFG Converter 2.

:- use_module(library(plunit)).
:- use_module('../prolog/cfg2_evidence').
:- use_module('../prolog/cfg2_uncertainty').
:- use_module('../prolog/cfg2_measurements').
:- use_module('../prolog/cfg2_indicators').
:- use_module('../prolog/cfg2_intuition').

:- begin_tests(evidence_model).

test(make_evidence, [true(nonvar(E))]) :-
    make_evidence(e1, neuroolfaction, qualitative_measurement,
                  odour_response, strong, neuroolfactory_unit,
                  context(participant(p1)), 0.82,
                  provenance(observer(dr_smith)), time('2026-08-03'),
                  location(lab_2), [scale(ordinal)], E).

test(evidence_accessors, [true]) :-
    E = evidence(e17, neuroscience, qualitative_measurement,
                 odour_response, strong, neuroolfactory_unit,
                 context(participant(p1), stimulus(rose)),
                 0.82, provenance(observer(dr_smith), instrument(panel_v2)),
                 time('2026-08-03T14:00:00+10:00'), location(laboratory_2),
                 [scale(ordinal), consent_recorded(true)]),
    evidence_id(E, e17),
    evidence_department(E, neuroscience),
    evidence_type(E, qualitative_measurement),
    evidence_subject(E, odour_response),
    evidence_value(E, strong),
    evidence_confidence(E, 0.82).

test(valid_evidence_type, [true]) :-
    valid_evidence_type(qualitative_measurement),
    valid_evidence_type(formula),
    valid_evidence_type(archival_record).

test(valid_confidence_numeric, [true]) :-
    valid_confidence(0.0),
    valid_confidence(0.5),
    valid_confidence(1.0).

test(valid_confidence_ordinal, [true]) :-
    valid_confidence(ordinal(moderate)).

test(valid_confidence_interval, [true]) :-
    valid_confidence(interval(0.3, 0.7)).

test(invalid_confidence_rejected, [true]) :-
    \+ valid_confidence(99.0),
    \+ valid_confidence(-0.1).

test(validate_evidence_valid, [true(Errors = [])]) :-
    E = evidence(e1, neuroolfaction, qualitative_measurement,
                 odour_response, strong, neuroolfactory_unit,
                 context([]), 0.82, provenance([]), unknown, unknown, []),
    validate_evidence_term(E, [], Errors).

test(validate_evidence_bad_confidence, [true(Errors \= [])]) :-
    E = evidence(e1, neuroolfaction, qualitative_measurement,
                 odour_response, strong, neuroolfactory_unit,
                 context([]), 1.5, provenance([]), unknown, unknown, []),
    validate_evidence_term(E, [], Errors).

test(validate_evidence_bad_type, [true(Errors \= [])]) :-
    E = evidence(e1, neuroolfaction, completely_unknown_type,
                 odour_response, strong, neuroolfactory_unit,
                 context([]), 0.8, provenance([]), unknown, unknown, []),
    validate_evidence_term(E, [], Errors).

test(normalise_evidence_12_args, [true(nonvar(N))]) :-
    E = evidence(e1, dept, type, subj, val, unit, ctx, 0.5, prov, time, loc, []),
    normalise_evidence_term(E, N).

test(normalise_evidence_11_args, [true(nonvar(N))]) :-
    E = evidence(e1, dept, type, subj, val, unit, ctx, 0.5, prov, time, loc),
    normalise_evidence_term(E, N).

test(evidence_index_by_id, [true(Sub = [E])]) :-
    E = evidence(e1, dept, type, subj, val, unit, ctx, 0.5, prov, t, l, []),
    evidence_index([E], id(e1), Sub).

test(evidence_index_by_department, [true(N =:= 2)]) :-
    E1 = evidence(e1, neuroolfaction, t, s, v, u, c, 0.5, p, t, l, []),
    E2 = evidence(e2, neuroolfaction, t, s, v, u, c, 0.5, p, t, l, []),
    E3 = evidence(e3, mathematics, t, s, v, u, c, 0.5, p, t, l, []),
    evidence_index([E1, E2, E3], department(neuroolfaction), Sub),
    length(Sub, N).

test(evidence_list_ids, [true(Ids = [e1, e2])]) :-
    E1 = evidence(e1, d, t, s, v, u, c, 0.5, p, t, l, []),
    E2 = evidence(e2, d, t, s, v, u, c, 0.5, p, t, l, []),
    evidence_list_ids([E1, E2], Ids).

:- end_tests(evidence_model).

:- begin_tests(uncertainty).

test(ordinal_to_numeric, [true(N =:= 0.5)]) :-
    ordinal_to_numeric(moderate, N).

test(numeric_to_ordinal, [true(O = moderate)]) :-
    numeric_to_ordinal(0.5, O).

test(combine_confidence_mean, [true(abs(R - 0.7) < 0.001)]) :-
    combine_confidence(mean, [0.6, 0.8], [], R).

test(uncertainty_three_value_high, [true(TV = supported)]) :-
    uncertainty_three_value(0.7, TV).

test(uncertainty_three_value_low, [true(TV = unsupported)]) :-
    uncertainty_three_value(0.3, TV).

test(apply_policy_cautious_high_conf, [true(nonvar(R))]) :-
    Int = intuition(i1, expert(e1), subject, conclusion,
                    [], 0.8, [], context([]), provenance([])),
    apply_intuition_policy(cautious, Int, [], R).

:- end_tests(uncertainty).

:- begin_tests(measurements).

test(neuroolfactory_scale, [true]) :-
    ordinal_scale(neuroolfactory, Levels),
    member(strong, Levels).

test(unit_alias_kg, [true(C = kilogram)]) :-
    unit_alias(kg, C).

test(qualitative_at_least_strong_moderate, [true]) :-
    ordinal_scale(neuroolfactory, Levels),
    nth0(IS, Levels, strong),
    nth0(IM, Levels, moderate),
    IS >= IM.

test(missing_value, [true]) :-
    missing_value(missing),
    missing_value(unknown),
    missing_value(not_recorded).

test(aggregate_mean, [true(nonvar(R))]) :-
    aggregate_measurements(mean, [1.0, 2.0, 3.0], R).

test(aggregate_retain_all, [true(R = retain_all([a, b]))]) :-
    aggregate_measurements(retain_all, [a, b], R).

:- end_tests(measurements).

:- begin_tests(indicators).

test(make_indicator, [true(nonvar(Ind))]) :-
    make_indicator(i4, literary_analysis, narrator, repeated_evasion,
                   supports(unreliable_narrator), moderate, 0.70,
                   chapter(3), provenance(reader_annotation(a12)), Ind).

test(indicator_accessors, [true]) :-
    Ind = indicator(i4, literary_analysis, narrator, repeated_evasion,
                    supports(unreliable_narrator), moderate, 0.70,
                    chapter(3), provenance(reader_annotation(a12))),
    indicator_id(Ind, i4),
    indicator_domain(Ind, literary_analysis),
    indicator_direction(Ind, supports(unreliable_narrator)).

test(indicator_status_supports, [true(S = supports(unreliable_narrator))]) :-
    Ind = indicator(i1, lit, narrator, evasion, supports(unreliable_narrator),
                    moderate, 0.7, ctx, prov),
    indicator_status(Ind, S).

test(supporting_indicators, [true(Supporting \= [])]) :-
    Ind1 = indicator(i1, lit, narrator, evasion, supports(my_conclusion),
                     moderate, 0.7, ctx, prov),
    Ind2 = indicator(i2, lit, narrator, engagement, contradicts(my_conclusion),
                     moderate, 0.6, ctx, prov),
    supporting_indicators([Ind1, Ind2], my_conclusion, Supporting).

test(contradicting_indicators, [true(Contra \= [])]) :-
    Ind = indicator(i1, lit, narrator, engagement, contradicts(my_conclusion),
                    moderate, 0.6, ctx, prov),
    contradicting_indicators([Ind], my_conclusion, Contra).

test(validate_indicator_valid, [true(Errors = [])]) :-
    Ind = indicator(i1, literary_analysis, narrator, evasion,
                    supports(unreliable_narrator), moderate, 0.70,
                    chapter(3), provenance([])),
    validate_indicator(Ind, [], Errors).

:- end_tests(indicators).

:- begin_tests(intuition).

test(make_intuition, [true(nonvar(Int))]) :-
    make_intuition(in1, expert(reader_1), poem(p1), theme(displacement),
                   [indicator(departure_images)], 0.68,
                   [theme(memory)], stanza_range(1,5),
                   provenance(annotation_set(a1)), Int).

test(intuition_cautious_weak_returns_undecided,
     [true(Status = undecided)]) :-
    Int = intuition(in1, expert(reader_1), poem(p1), theme(displacement),
                    [], 0.4, [theme(memory), theme(exile)],
                    stanza_range(1,5), provenance(annotation_set(a1))),
    apply_intuition_policy(cautious, Int, [], Result),
    (   Result = interpretation(_, _, status(Status), _)
    ->  true
    ;   Result = interpretation(_, _, status(Status), _, _)
    ).

test(intuition_not_unconditional_fact, [true]) :-
    %% The system must never convert an intuition to an unconditional fact.
    Int = intuition(in1, expert(reader_1), poem(p1), theme(displacement),
                    [], 0.68, [], stanza_range(1,5), provenance([])),
    apply_intuition_policy(cautious, Int, [], Result),
    \+ Result = theme(displacement).  % never just the bare conclusion

test(intuition_to_interpretation, [true(nonvar(Interp))]) :-
    Int = intuition(in1, expert(reader_1), poem(p1), theme(displacement),
                    [], 0.8, [theme(memory)], stanza_range(1,5),
                    provenance(annotation_set(a1))),
    intuition_to_interpretation(Int, balanced, Interp).

:- end_tests(intuition).
