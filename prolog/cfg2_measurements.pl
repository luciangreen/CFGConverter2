%% cfg2_measurements.pl
%% Handles quantitative and qualitative measurements for CFG Converter 2.

:- module(cfg2_measurements,
    [
        validate_unit/2,
        unit_alias/2,
        ordinal_scale/2,
        nominal_scale/2,
        interval_scale/2,
        ratio_scale/2,
        qualitative_unit/1,
        check_range/3,
        missing_value/1,
        below_detection_limit/1,
        approximate_measurement/2,
        aggregate_measurements/3,
        conflict_measurements/3,
        measurement_comparison/3,
        normalise_measurement/3
    ]).

:- use_module(library(lists)).

%% missing_value(+Value) is semidet.
%  True when Value represents a missing or unavailable measurement.
missing_value(missing).
missing_value(unknown).
missing_value(not_recorded).
missing_value(not_applicable).
missing_value(below_detection_limit).

%% below_detection_limit(+Value) is semidet.
below_detection_limit(below_detection_limit).
below_detection_limit(bdl).
below_detection_limit('<LOD').

%% approximate_measurement(+Value, -Approx) is semidet.
approximate_measurement(approx(V), approx(V)).
approximate_measurement(circa(V), approx(V)).
approximate_measurement(V, exact(V)) :- number(V).

%% qualitative_unit(+Unit) is semidet.
qualitative_unit(neuroolfactory_unit).
qualitative_unit(ordinal_unit).
qualitative_unit(nominal_unit).
qualitative_unit(likert_unit).
qualitative_unit(rank_unit).

%% unit_alias(+Alias, -CanonicalUnit) is semidet.
unit_alias(kg, kilogram).
unit_alias(g,  gram).
unit_alias(m,  metre).
unit_alias(cm, centimetre).
unit_alias(mm, millimetre).
unit_alias(l,  litre).
unit_alias(ml, millilitre).
unit_alias(s,  second).
unit_alias(ms, millisecond).
unit_alias(hz, hertz).
unit_alias(n,  newton).
unit_alias(pa, pascal).
unit_alias(k,  kelvin).
unit_alias(c,  celsius).
unit_alias(neuroolfactory, neuroolfactory_unit).
unit_alias(ordinal, ordinal_unit).
unit_alias(none_unit, dimensionless).

%% validate_unit(+Unit, -Canonical) is semidet.
%  Resolves unit aliases and validates that unit is declared.
validate_unit(Unit, Canonical) :-
    (   unit_alias(Unit, Canonical)
    ->  true
    ;   Canonical = Unit
    ).

%% ordinal_scale(+Scale, -Levels) is semidet.
%  Known ordinal scales and their ordered levels.
ordinal_scale(neuroolfactory, [none, trace, weak, moderate, strong, intense]).
ordinal_scale(likert_5,       [strongly_disagree, disagree, neutral, agree, strongly_agree]).
ordinal_scale(likert_7,       [strongly_disagree, disagree, slightly_disagree, neutral,
                                slightly_agree, agree, strongly_agree]).
ordinal_scale(low_high_3,     [low, moderate, high]).
ordinal_scale(none_strong_4,  [none, weak, moderate, strong]).
ordinal_scale(pleasantness,   [very_unpleasant, unpleasant, neutral, pleasant, very_pleasant]).

%% nominal_scale(+Scale, -Categories) is semidet.
nominal_scale(stimulus_category, [floral, fruity, woody, musky, spicy, earthy, sweet, pungent]).
nominal_scale(response_category, [approach, avoidance, neutral, ambivalent]).

%% interval_scale(+Scale, -Range) is semidet.
interval_scale(celsius, range(-273.15, 10000)).
interval_scale(iq,      range(0, 300)).
interval_scale(year,    range(-10000, 3000)).

%% ratio_scale(+Scale, -Range) is semidet.
ratio_scale(mass_kg,    range(0, 1.0e12)).
ratio_scale(length_m,   range(0, 1.0e12)).
ratio_scale(duration_s, range(0, 1.0e15)).

%% check_range(+Value, +Scale, -Status) is det.
%  Checks whether a value is within the declared range for a scale.
check_range(V, Scale, in_range) :-
    number(V),
    (   ratio_scale(Scale, range(Lo, Hi))
    ;   interval_scale(Scale, range(Lo, Hi))
    ),
    V >= Lo, V =< Hi, !.
check_range(V, Scale, out_of_range(V, Scale)) :-
    number(V), !.
check_range(V, Scale, not_checked(V, Scale)) :-
    missing_value(V), !.
check_range(V, Scale, ordinal_checked(V)) :-
    ordinal_scale(Scale, Levels),
    member(V, Levels), !.
check_range(V, Scale, unknown_range(V, Scale)).

%% aggregate_measurements(+Policy, +Values, -Aggregate) is det.
aggregate_measurements(mean, Values, mean(Result)) :-
    include(number, Values, Nums),
    (   Nums = []
    ->  Result = missing
    ;   sumlist(Nums, Sum), length(Nums, N), Result is Sum / N
    ).
aggregate_measurements(median, Values, median(Result)) :-
    include(number, Values, Nums),
    msort(Nums, Sorted),
    (   Sorted = []
    ->  Result = missing
    ;   length(Sorted, N),
        Mid is N // 2,
        nth0(Mid, Sorted, Result)
    ).
aggregate_measurements(retain_all, Values, retain_all(Values)).
aggregate_measurements(majority, Values, majority(Mode)) :-
    most_frequent(Values, Mode).
aggregate_measurements(_, Values, unknown(Values)).

most_frequent(List, Mode) :-
    msort(List, Sorted),
    group_by_run(Sorted, Groups),
    maplist([G-N]>>(length(G, N)), Groups, _Pairs),
    predsort([O, G1-N1, G2-N2]>>(compare(O, N2, N1)), Groups, [Mode-_|_]).

group_by_run([], []).
group_by_run([H|T], [[H|Hs]-N|Groups]) :-
    partition(==(H), T, Hs, Rest),
    length([H|Hs], N),
    group_by_run(Rest, Groups).

%% conflict_measurements(+V1, +V2, -Conflict) is det.
conflict_measurements(V1, V2, conflict(V1, V2)) :-
    V1 \== V2.
conflict_measurements(V, V, no_conflict(V)).

%% measurement_comparison(+V1, +V2, -Order) is semidet.
%  Compares two measurements on the same scale (numeric or ordinal).
measurement_comparison(V1, V2, less)    :- number(V1), number(V2), V1 < V2.
measurement_comparison(V1, V2, equal)   :- number(V1), number(V2), V1 =:= V2.
measurement_comparison(V1, V2, greater) :- number(V1), number(V2), V1 > V2.
measurement_comparison(V1, V2, Ord) :-
    atom(V1), atom(V2),
    ordinal_scale(_, Levels),
    nth0(I1, Levels, V1),
    nth0(I2, Levels, V2), !,
    compare(Ord0, I1, I2),
    ( Ord0 = (<) -> Ord = less ; Ord0 = (>) -> Ord = greater ; Ord = equal ).

%% normalise_measurement(+Value, +Unit, -Normalised) is det.
normalise_measurement(V, Unit, normalised(V, CanonUnit)) :-
    validate_unit(Unit, CanonUnit).
