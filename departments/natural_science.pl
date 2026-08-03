%% departments/natural_science.pl
%% Natural science department plugin for CFG Converter 2.

:- module(dept_natural_science,
    [
        valid_observation_type/1,
        valid_measurement_context/1,
        scientific_classification/3,
        observation_to_ir/3
    ]).

:- use_module(library(lists)).
:- use_module('../prolog/cfg2_evidence').
:- use_module('../prolog/cfg2_measurements').

%% valid_observation_type(+Type) is semidet.
valid_observation_type(raw_observation).
valid_observation_type(normalised_observation).
valid_observation_type(derived_measurement).
valid_observation_type(classification).
valid_observation_type(hypothesis).
valid_observation_type(conclusion).
valid_observation_type(control_group).
valid_observation_type(experimental_condition).
valid_observation_type(instrument_reading).

%% valid_measurement_context(+Context) is semidet.
valid_measurement_context(context([])).
valid_measurement_context(context(Attrs)) :- is_list(Attrs).

%% scientific_classification(+Evidence, +Department, -Classification) is det.
scientific_classification(E, Dept, Classification) :-
    evidence_id(E, EId),
    evidence_type(E, Type),
    evidence_value(E, Value),
    evidence_confidence(E, Conf),
    Classification = scientific_classification(
        id(EId),
        observation_type(Type),
        classified_as(Value),
        confidence(Conf),
        department(Dept)
    ).

%% observation_to_ir(+Evidence, +Options, -IRElement) is det.
observation_to_ir(E, _Options, IRElement) :-
    evidence_id(E, EId),
    evidence_subject(E, Subject),
    evidence_value(E, Value),
    evidence_type(E, Type),
    IRElement = concept(EId, Subject, [observation(Type, Value)],
                        dept(natural_science), [source(EId)]).

:- initialization(format('Natural science department plugin loaded.~n'), now).
