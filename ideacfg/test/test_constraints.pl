%% test_constraints.pl — Tests for constraint handling.
:- use_module(library(plunit)).
:- use_module('../prolog/ideacfg_constraints').
:- use_module('../prolog/ideacfg_units').
:- use_module('../prolog/ideacfg_ir').
:- use_module('../prolog/ideacfg_input').

:- begin_tests(unit_validation).

test(known_unit_metre) :- known_unit(metre).
test(known_unit_second) :- known_unit(second).
test(known_unit_kelvin) :- known_unit(kelvin).

test(compatible_units_same) :- compatible_units(metre, metre).
test(compatible_units_different_compatible) :- compatible_units(metre, km).
test(incompatible_units_raises_error, [throws(error(incompatible_units(metre, second), _))]) :-
    add_quantities(quantity(1, metre), quantity(2, second), _).

test(add_quantities_same_unit) :-
    add_quantities(quantity(3, metre), quantity(4, metre), quantity(7, metre)).

test(add_quantities_convert) :-
    add_quantities(quantity(1000, metre), quantity(1, km), quantity(R, metre)),
    R =:= 2000.

test(convert_km_to_metre) :-
    convert_unit(5, km, metre, 5000).

test(convert_celsius_to_kelvin) :-
    convert_unit(0, celsius, kelvin, 273.15).

test(multiply_quantities) :-
    multiply_quantities(quantity(3, metre), quantity(2, metre), quantity(6, _)).

:- end_tests(unit_validation).

:- begin_tests(constraints_module).

test(constraint_type_ordering) :- constraint_type(ordering).
test(constraint_type_semantic) :- constraint_type(semantic).

test(validate_known_constraint) :-
    validate_constraint(constraint(c1, ordering, [a, b], [], src), []).

test(validate_unknown_constraint_type) :-
    validate_constraint(constraint(c2, made_up_type, [], [], src), Diags),
    Diags \= [].

test(extract_constraints_from_ir) :-
    idea_from_terms(ct, [constraint(c1, ordering, [a,b], [], src)], IR),
    extract_constraints(IR, Cs),
    Cs = [constraint(c1, ordering, [a,b], [], src)].

:- end_tests(constraints_module).
