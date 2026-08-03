%% cfg2_indicators.pl
%% Humanities and intuitional indicator representation for CFG Converter 2.
%%
%% Canonical form:
%%   indicator(IndicatorId, Domain, Subject, Signal, Direction,
%%             Strength, Reliability, Context, Provenance).

:- module(cfg2_indicators,
    [
        make_indicator/10,
        indicator_id/2,
        indicator_domain/2,
        indicator_subject/2,
        indicator_signal/2,
        indicator_direction/2,
        indicator_strength/2,
        indicator_reliability/2,
        indicator_context/2,
        indicator_provenance/2,
        validate_indicator/3,
        indicator_status/2,
        indicators_for_conclusion/3,
        supporting_indicators/3,
        contradicting_indicators/3,
        indicator_weight/2
    ]).

:- use_module(library(lists)).
:- use_module(cfg2_uncertainty).

%% make_indicator(+Id,+Domain,+Subject,+Signal,+Direction,+Strength,
%%                +Reliability,+Context,+Provenance,-Indicator) is det.
make_indicator(Id, Domain, Subject, Signal, Direction, Strength,
               Reliability, Context, Provenance,
               indicator(Id, Domain, Subject, Signal, Direction,
                         Strength, Reliability, Context, Provenance)).

%% Accessors
indicator_id(indicator(Id,_,_,_,_,_,_,_,_), Id).
indicator_domain(indicator(_,D,_,_,_,_,_,_,_), D).
indicator_subject(indicator(_,_,S,_,_,_,_,_,_), S).
indicator_signal(indicator(_,_,_,Sig,_,_,_,_,_), Sig).
indicator_direction(indicator(_,_,_,_,Dir,_,_,_,_), Dir).
indicator_strength(indicator(_,_,_,_,_,Str,_,_,_), Str).
indicator_reliability(indicator(_,_,_,_,_,_,Rel,_,_), Rel).
indicator_context(indicator(_,_,_,_,_,_,_,Ctx,_), Ctx).
indicator_provenance(indicator(_,_,_,_,_,_,_,_,Prov), Prov).

%% indicator_status(+Indicator, -Status) is det.
%  Classifies the indicator as: observed, supports, contradicts, undecided.
indicator_status(Ind, supports(Conclusion)) :-
    indicator_direction(Ind, supports(Conclusion)), !.
indicator_status(Ind, contradicts(Conclusion)) :-
    indicator_direction(Ind, contradicts(Conclusion)), !.
indicator_status(Ind, contradicts(Conclusion)) :-
    indicator_direction(Ind, against(Conclusion)), !.
indicator_status(Ind, undecided) :-
    indicator_direction(Ind, neutral), !.
indicator_status(Ind, observed(Signal)) :-
    indicator_signal(Ind, Signal).

%% validate_indicator(+Indicator, +Options, -Errors) is det.
validate_indicator(Ind, _Opts, Errors) :-
    (   Ind = indicator(Id, Domain, _Subject, _Signal, Direction, Strength, Rel, _Ctx, _Prov)
    ->  Errs0 = [],
        ( (atom(Id) ; integer(Id)) -> Errs1 = Errs0
        ; Errs1 = [error(indicator_id, atom_or_integer, Id)|Errs0] ),
        ( atom(Domain) -> Errs2 = Errs1
        ; Errs2 = [error(domain, atom, Domain)|Errs1] ),
        ( valid_direction(Direction) -> Errs3 = Errs2
        ; Errs3 = [error(direction, valid_direction, Direction)|Errs2] ),
        ( valid_strength(Strength) -> Errs4 = Errs3
        ; Errs4 = [error(strength, valid_strength, Strength)|Errs3] ),
        ( valid_confidence(Rel) -> Errors = Errs4
        ; Errors = [error(reliability, valid_confidence, Rel)|Errs4] )
    ;   Errors = [error(structure, indicator_9_args, Ind)]
    ).

valid_direction(supports(_)).
valid_direction(contradicts(_)).
valid_direction(against(_)).
valid_direction(neutral).
valid_direction(observed(_)).
valid_direction(undecided).

valid_strength(none).
valid_strength(weak).
valid_strength(moderate).
valid_strength(strong).
valid_strength(definitive).
valid_strength(N) :- number(N), N >= 0.0, N =< 1.0.

%% indicators_for_conclusion(+Indicators, +Conclusion, -Relevant) is det.
indicators_for_conclusion(Inds, Conclusion, Relevant) :-
    include([Ind]>>(
        indicator_direction(Ind, Dir),
        ( Dir = supports(Conclusion) ; Dir = contradicts(Conclusion)
        ; Dir = against(Conclusion) )
    ), Inds, Relevant).

%% supporting_indicators(+Indicators, +Conclusion, -Supporting) is det.
supporting_indicators(Inds, Conclusion, Supporting) :-
    include([Ind]>>(indicator_direction(Ind, supports(Conclusion))), Inds, Supporting).

%% contradicting_indicators(+Indicators, +Conclusion, -Contradicting) is det.
contradicting_indicators(Inds, Conclusion, Contradicting) :-
    include([Ind]>>(
        indicator_direction(Ind, Dir),
        ( Dir = contradicts(Conclusion) ; Dir = against(Conclusion) )
    ), Inds, Contradicting).

%% indicator_weight(+Indicator, -Weight) is det.
%  Returns a numeric weight based on strength and reliability.
indicator_weight(Ind, Weight) :-
    indicator_strength(Ind, Strength),
    indicator_reliability(Ind, Rel),
    strength_to_numeric(Strength, SN),
    (   number(Rel)
    ->  RelN = Rel
    ;   ordinal_to_numeric(Rel, RelN),
        ( \+ number(RelN) -> RelN2 = 0.5 ; RelN2 = RelN )
    ),
    (   number(SN)
    ->  Weight is SN * RelN2
    ;   Weight = 0.0
    ).

strength_to_numeric(none,        0.0).
strength_to_numeric(weak,        0.25).
strength_to_numeric(moderate,    0.5).
strength_to_numeric(strong,      0.75).
strength_to_numeric(definitive,  1.0).
strength_to_numeric(N, N) :- number(N).

:- use_module(cfg2_uncertainty, [ordinal_to_numeric/2, valid_confidence/1]).
