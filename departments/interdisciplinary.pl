%% departments/interdisciplinary.pl
%% Interdisciplinary department plugin for CFG Converter 2.

:- module(dept_interdisciplinary,
    [
        cross_department_evidence/3,
        reconcile_department_policies/3,
        interdisciplinary_interpretation/3
    ]).

:- use_module(library(lists)).
:- use_module('../prolog/cfg2_evidence').
:- use_module('../prolog/cfg2_departments').
:- use_module('../prolog/cfg2_uncertainty').

%% cross_department_evidence(+EvidenceList, +Departments, -ByDept) is det.
cross_department_evidence(EvidenceList, Departments, ByDept) :-
    maplist([Dept, Dept-Subset]>>(
        include([E]>>(evidence_department(E, Dept)), EvidenceList, Subset)
    ), Departments, ByDept).

%% reconcile_department_policies(+Departments, +Key, -Policy) is det.
%  Returns the most conservative policy across departments for a given key.
reconcile_department_policies(Departments, confidence_policy, Policy) :-
    maplist([Dept, P]>>(
        (department_policy(Dept, confidence_policy, P) -> true ; P = unknown)
    ), Departments, Policies),
    (   member(weighted_indicators, Policies) -> Policy = weighted_indicators
    ;   member(numeric, Policies) -> Policy = numeric
    ;   member(ordinal_confidence, Policies) -> Policy = ordinal_confidence
    ;   Policy = cautious
    ).
reconcile_department_policies(_, _, unknown).

%% interdisciplinary_interpretation(+Evidence, +Departments, -Interp) is det.
interdisciplinary_interpretation(Evidence, Departments, Interp) :-
    maplist([E, Conf]>>(evidence_confidence(E, Conf)), Evidence, Confs),
    combine_confidence(mean, Confs, [], MeanConf),
    length(Evidence, N),
    Interp = interdisciplinary_interpretation(
        evidence_count(N),
        departments(Departments),
        combined_confidence(MeanConf),
        status(synthesised)
    ).

:- initialization(format('Interdisciplinary department plugin loaded.~n'), now).
