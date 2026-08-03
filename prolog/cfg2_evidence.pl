%% cfg2_evidence.pl
%% Canonical evidence representation for CFG Converter 2.
%%
%% An evidence term encodes a single typed, attributed observation,
%% measurement, judgement, indicator, or record produced outside a
%% conversational interface.
%%
%% Canonical form:
%%   evidence(EvidenceId, Department, Type, Subject, Value, Unit,
%%            Context, Confidence, Provenance, Time, Location, Metadata).

:- module(cfg2_evidence,
    [
        %% Constructors / accessors
        make_evidence/13,
        evidence_id/2,
        evidence_department/2,
        evidence_type/2,
        evidence_subject/2,
        evidence_value/2,
        evidence_unit/2,
        evidence_context/2,
        evidence_confidence/2,
        evidence_provenance/2,
        evidence_time/2,
        evidence_location/2,
        evidence_metadata/2,

        %% Validation
        validate_evidence_term/3,
        valid_evidence_type/1,
        valid_confidence/1,

        %% Utilities
        evidence_index/3,
        evidence_matches/3,
        evidence_list_ids/2,
        normalise_evidence_term/2
    ]).

:- use_module(library(lists)).
:- use_module(library(error)).

%% make_evidence(+Id,+Dept,+Type,+Subject,+Value,+Unit,+Context,
%%               +Confidence,+Provenance,+Time,+Location,+Metadata,
%%               -Evidence) is det.
make_evidence(Id, Dept, Type, Subject, Value, Unit,
              Context, Confidence, Provenance, Time, Location, Metadata,
              evidence(Id, Dept, Type, Subject, Value, Unit,
                       Context, Confidence, Provenance, Time, Location, Metadata)).

%% Accessors
evidence_id(evidence(Id,_,_,_,_,_,_,_,_,_,_,_), Id).
evidence_department(evidence(_,D,_,_,_,_,_,_,_,_,_,_), D).
evidence_type(evidence(_,_,T,_,_,_,_,_,_,_,_,_), T).
evidence_subject(evidence(_,_,_,S,_,_,_,_,_,_,_,_), S).
evidence_value(evidence(_,_,_,_,V,_,_,_,_,_,_,_), V).
evidence_unit(evidence(_,_,_,_,_,U,_,_,_,_,_,_), U).
evidence_context(evidence(_,_,_,_,_,_,C,_,_,_,_,_), C).
evidence_confidence(evidence(_,_,_,_,_,_,_,Conf,_,_,_,_), Conf).
evidence_provenance(evidence(_,_,_,_,_,_,_,_,P,_,_,_), P).
evidence_time(evidence(_,_,_,_,_,_,_,_,_,T,_,_), T).
evidence_location(evidence(_,_,_,_,_,_,_,_,_,_,L,_), L).
evidence_metadata(evidence(_,_,_,_,_,_,_,_,_,_,_,M), M).

%% valid_evidence_type(+Type) is semidet.
valid_evidence_type(qualitative_measurement).
valid_evidence_type(quantitative_measurement).
valid_evidence_type(observation).
valid_evidence_type(formula).
valid_evidence_type(indicator).
valid_evidence_type(intuition).
valid_evidence_type(annotation).
valid_evidence_type(classification).
valid_evidence_type(judgement).
valid_evidence_type(provenance_record).
valid_evidence_type(instrument_reading).
valid_evidence_type(expert_assessment).
valid_evidence_type(tacit_observation).
valid_evidence_type(temporal_observation).
valid_evidence_type(spatial_observation).
valid_evidence_type(trust_judgement).
valid_evidence_type(confidence_weighted).
valid_evidence_type(archival_record).
valid_evidence_type(sensor_data).
valid_evidence_type(image_metadata).
valid_evidence_type(audio_metadata).
valid_evidence_type(unknown_type).

%% valid_confidence(+Conf) is semidet.
%  Confidence may be numeric 0.0..1.0, an ordinal atom, or a special value.
valid_confidence(unknown).
valid_confidence(not_applicable).
valid_confidence(C) :-
    number(C), C >= 0.0, C =< 1.0.
valid_confidence(ordinal(V)) :-
    member(V, [none, very_low, low, moderate, high, very_high, certain]).
valid_confidence(interval(Lo, Hi)) :-
    number(Lo), number(Hi), Lo >= 0.0, Hi =< 1.0, Lo =< Hi.
valid_confidence(count(N, Total)) :-
    integer(N), integer(Total), N >= 0, Total >= N.

%% validate_evidence_term(+Evidence, +Options, -Errors) is det.
%  Validates a single evidence term.  Errors is a (possibly empty) list
%  of error(Field, Expected, Actual) terms.
validate_evidence_term(E, _Options, Errors) :-
    (   E = evidence(Id,Dept,Type,_Subject,_Value,_Unit,
                     _Context,Conf,_Provenance,_Time,_Loc,_Meta)
    ->  Errs0 = [],
        % Id must be atom or integer
        (   (atom(Id) ; integer(Id))
        ->  Errs1 = Errs0
        ;   Errs1 = [error(evidence_id, atom_or_integer, Id)|Errs0]
        ),
        % Department must be atom
        (   atom(Dept)
        ->  Errs2 = Errs1
        ;   Errs2 = [error(department, atom, Dept)|Errs1]
        ),
        % Type must be known
        (   valid_evidence_type(Type)
        ->  Errs3 = Errs2
        ;   Errs3 = [error(type, known_evidence_type, Type)|Errs2]
        ),
        % Confidence must be valid
        (   valid_confidence(Conf)
        ->  Errors = Errs3
        ;   Errors = [error(confidence, valid_confidence_value, Conf)|Errs3]
        )
    ;   Errors = [error(structure, evidence_12_args, E)]
    ).

%% normalise_evidence_term(+Raw, -Normalised) is det.
%  Fills missing optional fields with documented defaults.
normalise_evidence_term(Raw, Normalised) :-
    (   Raw = evidence(Id,Dept,Type,Subject,Value,Unit,
                       Context,Conf,Provenance,Time,Location,Meta)
    ->  NConf = (Conf = [] -> unknown ; Conf),
        (   NConf = unknown -> Conf2 = unknown ; Conf2 = Conf ),
        Normalised = evidence(Id,Dept,Type,Subject,Value,Unit,
                              Context,Conf2,Provenance,Time,Location,Meta)
    ;   Raw = evidence(Id,Dept,Type,Subject,Value,Unit,
                       Context,Conf,Provenance,Time,Location)
    ->  Normalised = evidence(Id,Dept,Type,Subject,Value,Unit,
                              Context,Conf,Provenance,Time,Location,[])
    ;   Raw = evidence(Id,Dept,Type,Subject,Value,Unit,
                       Context,Conf,Provenance)
    ->  Normalised = evidence(Id,Dept,Type,Subject,Value,Unit,
                              Context,Conf,Provenance,unknown,unknown,[])
    ;   throw(error(invalid_evidence_term(Raw), normalise_evidence_term/2))
    ).

%% evidence_index(+EvidenceList, +Key, -SubList) is det.
%  Filter evidence list by Key = id(Id), department(D), type(T), subject(S).
evidence_index(EList, id(Id), Sub) :-
    include([E]>>(evidence_id(E,EId), EId == Id), EList, Sub).
evidence_index(EList, department(D), Sub) :-
    include([E]>>(evidence_department(E,ED), ED == D), EList, Sub).
evidence_index(EList, type(T), Sub) :-
    include([E]>>(evidence_type(E,ET), ET == T), EList, Sub).
evidence_index(EList, subject(S), Sub) :-
    include([E]>>(evidence_subject(E,ES), ES == S), EList, Sub).

%% evidence_matches(+Evidence, +Pattern, -Bool) is det.
%  Pattern is a list of Key=Value pairs.
evidence_matches(E, Pattern, true) :-
    maplist(evidence_field_matches(E), Pattern), !.
evidence_matches(_, _, false).

evidence_field_matches(E, id=V)         :- evidence_id(E, V).
evidence_field_matches(E, department=V) :- evidence_department(E, V).
evidence_field_matches(E, type=V)       :- evidence_type(E, V).
evidence_field_matches(E, subject=V)    :- evidence_subject(E, V).

%% evidence_list_ids(+EvidenceList, -Ids) is det.
evidence_list_ids(EList, Ids) :-
    maplist([E,Id]>>(evidence_id(E,Id)), EList, Ids).
