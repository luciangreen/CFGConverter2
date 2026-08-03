%% cfg2_intuition.pl
%% Structured intuitional input handling for CFG Converter 2.
%%
%% An intuition is an evidence-bearing expert judgement that shall
%% never be compiled to an unconditional fact.
%%
%% Canonical form:
%%   intuition(IntuitionId, Observer, Subject, ProposedConclusion,
%%             Indicators, Confidence, Alternatives, Context, Provenance).

:- module(cfg2_intuition,
    [
        make_intuition/10,
        intuition_id/2,
        intuition_observer/2,
        intuition_subject/2,
        intuition_conclusion/2,
        intuition_indicators/2,
        intuition_confidence/2,
        intuition_alternatives/2,
        intuition_context/2,
        intuition_provenance/2,
        validate_intuition/3,
        apply_intuition_policy/4,
        intuition_to_interpretation/3,
        intuitional_output/5
    ]).

:- use_module(library(lists)).
:- use_module(cfg2_indicators).
:- use_module(cfg2_uncertainty).

%% make_intuition(+Id,+Observer,+Subject,+Conclusion,+Indicators,
%%               +Confidence,+Alternatives,+Context,+Provenance,-Intuition) is det.
make_intuition(Id, Observer, Subject, Conclusion, Indicators,
               Confidence, Alternatives, Context, Provenance,
               intuition(Id, Observer, Subject, Conclusion,
                         Indicators, Confidence, Alternatives,
                         Context, Provenance)).

%% Accessors
intuition_id(intuition(Id,_,_,_,_,_,_,_,_), Id).
intuition_observer(intuition(_,Obs,_,_,_,_,_,_,_), Obs).
intuition_subject(intuition(_,_,Sub,_,_,_,_,_,_), Sub).
intuition_conclusion(intuition(_,_,_,C,_,_,_,_,_), C).
intuition_indicators(intuition(_,_,_,_,Inds,_,_,_,_), Inds).
intuition_confidence(intuition(_,_,_,_,_,Conf,_,_,_), Conf).
intuition_alternatives(intuition(_,_,_,_,_,_,Alts,_,_), Alts).
intuition_context(intuition(_,_,_,_,_,_,_,Ctx,_), Ctx).
intuition_provenance(intuition(_,_,_,_,_,_,_,_,Prov), Prov).

%% validate_intuition(+Intuition, +Options, -Errors) is det.
validate_intuition(Int, _Opts, Errors) :-
    (   Int = intuition(Id, _Observer, _Subject, _Conclusion,
                        Indicators, Confidence, _Alts, _Ctx, _Prov)
    ->  Errs0 = [],
        ( (atom(Id) ; integer(Id)) -> Errs1 = Errs0
        ; Errs1 = [error(intuition_id, atom_or_integer, Id)|Errs0] ),
        ( is_list(Indicators) -> Errs2 = Errs1
        ; Errs2 = [error(indicators, list, Indicators)|Errs1] ),
        ( valid_confidence(Confidence) -> Errors = Errs2
        ; Errors = [error(confidence, valid_confidence_value, Confidence)|Errs2] )
    ;   Errors = [error(structure, intuition_9_args, Int)]
    ).

%% apply_intuition_policy(+Policy, +Intuition, +IndicatorList, -Result) is det.
%
%  Policies:
%    strict            - all mandatory indicators must be present
%    balanced          - supporting > contradicting evidence
%    expert_weighted   - reliability depends on declared expertise
%    plural            - return all sufficiently supported interpretations
%    cautious          - return undecided when evidence is weak
%    custom(PredName)  - allowed only for pre-registered safe predicates

apply_intuition_policy(strict, Int, Inds, Result) :-
    intuition_conclusion(Int, Conc),
    intuition_confidence(Int, Conf),
    supporting_indicators(Inds, Conc, Supp),
    (   Supp \= []
    ->  Result = interpretation(Conc, confidence(Conf), status(supported),
                                evidence(Supp))
    ;   Result = interpretation(Conc, confidence(0.0), status(unsupported),
                                evidence([]))
    ).

apply_intuition_policy(balanced, Int, Inds, Result) :-
    intuition_conclusion(Int, Conc),
    intuition_confidence(Int, Conf),
    supporting_indicators(Inds, Conc, Supp),
    contradicting_indicators(Inds, Conc, Contra),
    length(Supp, NS),
    length(Contra, NC),
    (   NS > NC
    ->  Result = interpretation(Conc, confidence(Conf),
                                status(supported_not_proven),
                                evidence(Supp), alternatives(Contra))
    ;   NS =:= NC
    ->  Result = interpretation(Conc, confidence(unknown),
                                status(undecided), evidence(Supp),
                                alternatives(Contra))
    ;   Result = interpretation(Conc, confidence(0.0),
                                status(unsupported),
                                evidence(Supp), alternatives(Contra))
    ).

apply_intuition_policy(cautious, Int, Inds, Result) :-
    intuition_conclusion(Int, Conc),
    intuition_confidence(Int, Conf),
    (   number(Conf), Conf > 0.6
    ->  supporting_indicators(Inds, Conc, Supp),
        (   Supp \= []
        ->  Result = interpretation(Conc, confidence(Conf),
                                    status(supported_not_proven),
                                    evidence(Supp))
        ;   Result = interpretation(Conc, confidence(unknown),
                                    status(undecided), evidence([]))
        )
    ;   Result = interpretation(Conc, confidence(unknown),
                                status(undecided), evidence([]))
    ).

apply_intuition_policy(expert_weighted, Int, Inds, Result) :-
    intuition_observer(Int, Observer),
    intuition_conclusion(Int, Conc),
    observer_expertise_weight(Observer, ExpertW),
    intuition_confidence(Int, RawConf),
    (   number(RawConf)
    ->  AdjConf is RawConf * ExpertW
    ;   AdjConf = unknown
    ),
    supporting_indicators(Inds, Conc, Supp),
    Result = interpretation(Conc, confidence(AdjConf),
                            status(expert_weighted), evidence(Supp)).

apply_intuition_policy(plural, Int, Inds, Results) :-
    intuition_conclusion(Int, MainConc),
    intuition_alternatives(Int, Alts),
    maplist([C, R]>>(
        supporting_indicators(Inds, C, Supp),
        intuition_confidence(Int, Conf),
        R = interpretation(C, confidence(Conf),
                           status(candidate), evidence(Supp))
    ), [MainConc|Alts], Results).

apply_intuition_policy(custom(PredName), Int, Inds, Result) :-
    (   registered_safe_intuition_predicate(PredName)
    ->  Goal =.. [PredName, Int, Inds, Result],
        call(Goal)
    ;   Result = error(unsafe_custom_predicate(PredName))
    ).

observer_expertise_weight(expert(_), 0.9).
observer_expertise_weight(specialist(_), 0.75).
observer_expertise_weight(trained(_), 0.65).
observer_expertise_weight(novice(_), 0.4).
observer_expertise_weight(_, 0.5).

:- dynamic registered_safe_intuition_predicate/1.

%% intuition_to_interpretation(+Intuition, +Policy, -Interpretation) is det.
%  Converts an intuition to a structured interpretation using the given policy.
intuition_to_interpretation(Int, Policy, Interpretation) :-
    intuition_indicators(Int, Inds),
    apply_intuition_policy(Policy, Int, Inds, Interpretation).

%% intuitional_output(+Conclusion, +EvidenceDB, +IndicatorDB, +Policy, -Output) is det.
%  Full intuitional output predicate as specified in requirements section 14.
intuitional_output(Conclusion, EvidenceDB, IndicatorDB, Policy, Output) :-
    (   member(Int, EvidenceDB),
        intuition_conclusion(Int, Conclusion)
    ->  supporting_indicators(IndicatorDB, Conclusion, SuppInds),
        apply_intuition_policy(Policy, Int, SuppInds, Output)
    ;   Output = interpretation(Conclusion, confidence(unknown),
                                status(undecided), evidence([]))
    ).
