%% tests/test_departments.pl
%% Department profile tests for CFG Converter 2.

:- use_module(library(plunit)).
:- use_module('../prolog/cfg2_departments').

:- begin_tests(departments).

test(mathematics_registered, [true]) :-
    department_registered(mathematics).

test(neuroolfaction_registered, [true]) :-
    department_registered(neuroolfaction).

test(history_registered, [true]) :-
    department_registered(history).

test(literature_registered, [true]) :-
    department_registered(literature).

test(philosophy_registered, [true]) :-
    department_registered(philosophy).

test(interdisciplinary_registered, [true]) :-
    department_registered(interdisciplinary).

test(all_required_departments, [true]) :-
    RequiredDepts = [mathematics, formal_logic, physics, chemistry, biology,
                     neuroscience, neuroolfaction, psychology, social_science,
                     history, philosophy, literature, visual_arts, music,
                     general_humanities, interdisciplinary],
    maplist(department_registered, RequiredDepts).

test(list_departments_nonempty, [true(Depts \= [])]) :-
    list_departments(Depts).

test(neuroolfaction_accepts_qualitative, [true]) :-
    department_accepts(neuroolfaction, qualitative_measurement).

test(mathematics_accepts_formula, [true]) :-
    department_accepts(mathematics, formula).

test(history_outputs, [true(Outputs \= [])]) :-
    department_outputs(history, Outputs).

test(department_policy_neuroolfaction, [true(Policy \= [])]) :-
    department_policy(neuroolfaction, confidence_policy, Policy).

test(register_custom_department, [true]) :-
    register_department(test_custom_dept,
                        [observation, annotation],
                        [cfg_rule, dcg_clause],
                        [confidence_policy=numeric]),
    department_registered(test_custom_dept).

:- end_tests(departments).
