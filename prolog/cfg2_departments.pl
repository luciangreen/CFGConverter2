%% cfg2_departments.pl
%% Department profile registry for CFG Converter 2.
%%
%% Each department profile declares:
%%   - Accepted evidence types
%%   - Output types
%%   - Default policies

:- module(cfg2_departments,
    [
        department_profile/4,
        list_departments/1,
        department_registered/1,
        department_accepts/2,
        department_outputs/2,
        department_policy/3,
        register_department/4
    ]).

:- use_module(library(lists)).

:- dynamic department_definition/4.

%% department_profile(+Department, -AcceptedEvidenceTypes, -OutputTypes, -DefaultPolicies) is semidet.
department_profile(Dept, AcceptedTypes, OutputTypes, Policies) :-
    department_definition(Dept, AcceptedTypes, OutputTypes, Policies).

%% list_departments(-Departments) is det.
list_departments(Depts) :-
    findall(D, department_definition(D, _, _, _), Depts).

%% department_registered(+Department) is semidet.
department_registered(Dept) :- department_definition(Dept, _, _, _).

%% department_accepts(+Department, +EvidenceType) is semidet.
department_accepts(Dept, Type) :-
    department_definition(Dept, AcceptedTypes, _, _),
    member(Type, AcceptedTypes).

%% department_outputs(+Department, -OutputTypes) is semidet.
department_outputs(Dept, OutputTypes) :-
    department_definition(Dept, _, OutputTypes, _).

%% department_policy(+Department, +PolicyKey, -PolicyValue) is semidet.
department_policy(Dept, Key, Value) :-
    department_definition(Dept, _, _, Policies),
    member(Key=Value, Policies).

%% register_department(+Dept, +AcceptedTypes, +OutputTypes, +Policies) is det.
register_department(Dept, AcceptedTypes, OutputTypes, Policies) :-
    must_be(atom, Dept),
    retractall(department_definition(Dept, _, _, _)),
    assertz(department_definition(Dept, AcceptedTypes, OutputTypes, Policies)).

%% ── Built-in department profiles ────────────────────────────────────────

register_builtin_departments :-
    register_department(mathematics,
        [formula, quantitative_measurement, observation, assumption, judgement],
        [cfg_rule, dcg_clause, proof_structure, computation_predicate],
        [confidence_policy=numeric,
         conflict_policy=retain_all,
         missing_value_policy=not_applicable,
         intuition_policy=strict]),

    register_department(formal_logic,
        [formula, assumption, judgement, observation],
        [cfg_rule, dcg_clause, proof_structure],
        [confidence_policy=boolean,
         conflict_policy=retain_all,
         intuition_policy=strict]),

    register_department(physics,
        [quantitative_measurement, instrument_reading, observation,
         formula, classification, judgement],
        [cfg_rule, dcg_clause, scientific_interpretation],
        [confidence_policy=numeric,
         conflict_policy=prefer_highest_reliability,
         missing_value_policy=below_detection_limit,
         intuition_policy=cautious]),

    register_department(chemistry,
        [quantitative_measurement, qualitative_measurement, instrument_reading,
         observation, formula, classification],
        [cfg_rule, dcg_clause, scientific_interpretation],
        [confidence_policy=numeric,
         conflict_policy=prefer_highest_reliability,
         intuition_policy=cautious]),

    register_department(biology,
        [quantitative_measurement, qualitative_measurement, observation,
         classification, expert_assessment, formula],
        [cfg_rule, dcg_clause, scientific_interpretation, classification],
        [confidence_policy=numeric,
         conflict_policy=prefer_highest_reliability,
         intuition_policy=balanced]),

    register_department(neuroscience,
        [quantitative_measurement, qualitative_measurement, instrument_reading,
         observation, classification, expert_assessment],
        [cfg_rule, dcg_clause, scientific_interpretation, classification],
        [confidence_policy=numeric,
         conflict_policy=prefer_highest_reliability,
         intuition_policy=cautious]),

    register_department(neuroolfaction,
        [qualitative_measurement, quantitative_measurement, observation,
         instrument_reading, expert_assessment, tacit_observation],
        [cfg_rule, dcg_clause, olfactory_classification, interpretation],
        [confidence_policy=weighted_indicators,
         conflict_policy=retain_all,
         missing_value_policy=not_recorded,
         intuition_policy=cautious,
         default_scale=neuroolfactory]),

    register_department(psychology,
        [qualitative_measurement, quantitative_measurement, observation,
         judgement, expert_assessment, annotation],
        [cfg_rule, dcg_clause, psychological_interpretation],
        [confidence_policy=ordinal_confidence,
         conflict_policy=retain_all,
         intuition_policy=balanced]),

    register_department(social_science,
        [observation, qualitative_measurement, quantitative_measurement,
         annotation, expert_assessment, temporal_observation],
        [cfg_rule, dcg_clause, social_interpretation],
        [confidence_policy=ordinal_confidence,
         conflict_policy=retain_all,
         intuition_policy=plural]),

    register_department(history,
        [archival_record, annotation, observation, provenance_record,
         expert_assessment, temporal_observation, spatial_observation],
        [cfg_rule, dcg_clause, historical_interpretation, conflict_report],
        [confidence_policy=ordinal_confidence,
         conflict_policy=retain_all,
         missing_value_policy=not_recorded,
         intuition_policy=cautious]),

    register_department(philosophy,
        [formula, judgement, annotation, assumption, expert_assessment],
        [cfg_rule, dcg_clause, philosophical_argument],
        [confidence_policy=three_valued,
         conflict_policy=retain_all,
         intuition_policy=balanced]),

    register_department(literature,
        [annotation, expert_assessment, qualitative_measurement,
         observation, indicator, archival_record],
        [cfg_rule, dcg_clause, literary_interpretation, indicator_report],
        [confidence_policy=ordinal_confidence,
         conflict_policy=retain_all,
         intuition_policy=plural]),

    register_department(visual_arts,
        [annotation, observation, expert_assessment, qualitative_measurement,
         image_metadata, provenance_record],
        [cfg_rule, dcg_clause, art_interpretation],
        [confidence_policy=ordinal_confidence,
         conflict_policy=retain_all,
         intuition_policy=balanced]),

    register_department(music,
        [observation, annotation, expert_assessment, qualitative_measurement,
         audio_metadata],
        [cfg_rule, dcg_clause, musical_interpretation],
        [confidence_policy=ordinal_confidence,
         conflict_policy=retain_all,
         intuition_policy=plural]),

    register_department(general_humanities,
        [annotation, observation, expert_assessment, archival_record,
         qualitative_measurement, provenance_record, indicator, intuition],
        [cfg_rule, dcg_clause, interpretation, indicator_report],
        [confidence_policy=ordinal_confidence,
         conflict_policy=retain_all,
         intuition_policy=cautious]),

    register_department(interdisciplinary,
        [qualitative_measurement, quantitative_measurement, formula,
         observation, annotation, expert_assessment, archival_record,
         indicator, intuition, classification, provenance_record,
         temporal_observation, spatial_observation],
        [cfg_rule, dcg_clause, interpretation, multi_department_report],
        [confidence_policy=weighted_indicators,
         conflict_policy=retain_all,
         missing_value_policy=not_recorded,
         intuition_policy=plural]).

:- use_module(library(error)).
:- initialization(register_builtin_departments, now).
