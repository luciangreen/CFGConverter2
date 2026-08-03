%% cfg2_uncertainty.pl
%% Explicit uncertainty representations for CFG Converter 2.
%%
%% Supported policies:
%%   boolean, three_valued, confidence_interval, ordinal_confidence,
%%   numeric, ranked_alternatives, evidence_count, weighted_indicators.

:- module(cfg2_uncertainty,
    [
        uncertainty_policy/2,
        apply_uncertainty_policy/4,
        combine_confidence/4,
        ordinal_to_numeric/2,
        numeric_to_ordinal/2,
        confidence_above/2,
        confidence_below/2,
        uncertainty_unknown/1,
        uncertainty_three_value/2,
        merge_uncertainty/3
    ]).

:- use_module(library(lists)).

%% uncertainty_policy(+PolicyName, -PolicySpec) is semidet.
uncertainty_policy(boolean,             boolean).
uncertainty_policy(three_valued,        three_valued).
uncertainty_policy(confidence_interval, confidence_interval).
uncertainty_policy(ordinal_confidence,  ordinal_confidence).
uncertainty_policy(numeric,             numeric).
uncertainty_policy(ranked_alternatives, ranked_alternatives).
uncertainty_policy(evidence_count,      evidence_count).
uncertainty_policy(weighted_indicators, weighted_indicators).

%% apply_uncertainty_policy(+Policy, +ConfidenceList, +Options, -Result) is det.
%  Applies the named uncertainty policy to a list of confidence values.
apply_uncertainty_policy(boolean, Confs, _Opts, Result) :-
    (   maplist(==(true), Confs)
    ->  Result = true
    ;   maplist(==(false), Confs)
    ->  Result = false
    ;   Result = unknown
    ).
apply_uncertainty_policy(three_valued, Confs, _Opts, Result) :-
    (   member(false, Confs)
    ->  Result = unsupported
    ;   member(unknown, Confs)
    ->  Result = unknown
    ;   Result = supported
    ).
apply_uncertainty_policy(numeric, Confs, Opts, Result) :-
    (   option(combine(mean), Opts)
    ->  combine_confidence(mean, Confs, _Opts, Result)
    ;   combine_confidence(mean, Confs, Opts, Result)
    ).
apply_uncertainty_policy(ordinal_confidence, Confs, _Opts, Result) :-
    maplist(ordinal_to_numeric, Confs, Nums),
    include(number, Nums, ValidNums),
    (   ValidNums = []
    ->  Result = unknown
    ;   sumlist(ValidNums, Sum),
        length(ValidNums, N),
        Avg is Sum / N,
        numeric_to_ordinal(Avg, Result)
    ).
apply_uncertainty_policy(confidence_interval, Confs, _Opts, Result) :-
    include(number, Confs, Nums),
    (   Nums = []
    ->  Result = interval(0.0, 1.0)
    ;   min_list(Nums, Lo),
        max_list(Nums, Hi),
        Result = interval(Lo, Hi)
    ).
apply_uncertainty_policy(evidence_count, Confs, _Opts, Result) :-
    length(Confs, N),
    include([C]>>(number(C), C > 0.5), Confs, Supporting),
    length(Supporting, S),
    Result = count(S, N).
apply_uncertainty_policy(weighted_indicators, Pairs, _Opts, Result) :-
    (   is_list(Pairs), Pairs = [_=_|_]
    ->  maplist([W=C, WC]>>(number(W), number(C), WC is W * C), Pairs, WCs),
        maplist([W=_, W]>>true, Pairs, Weights),
        sumlist(WCs, SumWC),
        sumlist(Weights, SumW),
        (SumW > 0 -> Result is SumWC / SumW ; Result = 0.0)
    ;   Result = unknown
    ).
apply_uncertainty_policy(ranked_alternatives, Pairs, _Opts, ranked(Sorted)) :-
    (   is_list(Pairs)
    ->  msort(Pairs, Sorted)
    ;   Sorted = [Pairs]
    ).

%% combine_confidence(+Method, +ConfList, +Options, -Result) is det.
combine_confidence(mean, Confs, _Opts, Result) :-
    include(number, Confs, Nums),
    (   Nums = []
    ->  Result = unknown
    ;   sumlist(Nums, Sum),
        length(Nums, N),
        Result is Sum / N
    ).
combine_confidence(min, Confs, _Opts, Result) :-
    include(number, Confs, Nums),
    (   Nums = [] -> Result = unknown ; min_list(Nums, Result) ).
combine_confidence(max, Confs, _Opts, Result) :-
    include(number, Confs, Nums),
    (   Nums = [] -> Result = unknown ; max_list(Nums, Result) ).
combine_confidence(product, Confs, _Opts, Result) :-
    include(number, Confs, Nums),
    (   Nums = [] -> Result = unknown
    ;   foldl([X, Acc0, Acc1]>>(Acc1 is Acc0 * X), Nums, 1.0, Result)
    ).

%% ordinal_to_numeric(+Ordinal, -Numeric) is semidet.
ordinal_to_numeric(none,      0.0).
ordinal_to_numeric(very_low,  0.1).
ordinal_to_numeric(low,       0.3).
ordinal_to_numeric(moderate,  0.5).
ordinal_to_numeric(high,      0.7).
ordinal_to_numeric(very_high, 0.9).
ordinal_to_numeric(certain,   1.0).
ordinal_to_numeric(unknown,   unknown).
ordinal_to_numeric(N, N) :- number(N).

%% numeric_to_ordinal(+Numeric, -Ordinal) is det.
numeric_to_ordinal(N, none)      :- number(N), N < 0.05, !.
numeric_to_ordinal(N, very_low)  :- number(N), N < 0.2,  !.
numeric_to_ordinal(N, low)       :- number(N), N < 0.4,  !.
numeric_to_ordinal(N, moderate)  :- number(N), N < 0.6,  !.
numeric_to_ordinal(N, high)      :- number(N), N < 0.8,  !.
numeric_to_ordinal(N, very_high) :- number(N), N < 0.95, !.
numeric_to_ordinal(_, certain).

%% confidence_above(+Conf, +Threshold) is semidet.
confidence_above(C, T) :- number(C), number(T), C >= T.
confidence_above(ordinal(V), ordinal(T)) :- ordinal_to_numeric(V, N), ordinal_to_numeric(T, NT), number(N), number(NT), N >= NT.

%% confidence_below(+Conf, +Threshold) is semidet.
confidence_below(C, T) :- number(C), number(T), C < T.

%% uncertainty_unknown(+Conf) is semidet.
uncertainty_unknown(unknown).
uncertainty_unknown(not_applicable).
uncertainty_unknown(not_recorded).

%% uncertainty_three_value(+Conf, -ThreeValue) is det.
uncertainty_three_value(true,          supported).
uncertainty_three_value(false,         unsupported).
uncertainty_three_value(unknown,       unknown).
uncertainty_three_value(not_recorded,  unknown).
uncertainty_three_value(C, supported)   :- number(C), C > 0.5, !.
uncertainty_three_value(C, unsupported) :- number(C), C < 0.5, !.
uncertainty_three_value(_, unknown).

%% merge_uncertainty(+Policy, +Conf1, -MergedConf) is det.
merge_uncertainty(mean, Confs, Result) :-
    is_list(Confs),
    combine_confidence(mean, Confs, [], Result).
merge_uncertainty(min, Confs, Result) :-
    is_list(Confs),
    combine_confidence(min, Confs, [], Result).
merge_uncertainty(max, Confs, Result) :-
    is_list(Confs),
    combine_confidence(max, Confs, [], Result).
merge_uncertainty(_, _, unknown).

:- use_module(library(option)).

option(Key, Opts, Default) :-
    (   option(Key, Opts)
    ->  true
    ;   _{} = Default  % not really - use proper call
    ),
    (   memberchk(Key, Opts) -> true ; true ).

% Proper option/3 helper
option(Key=_, Opts, _Default) :-
    member(Key=_, Opts), !.
option(_Key=Default, _Opts, Default).
