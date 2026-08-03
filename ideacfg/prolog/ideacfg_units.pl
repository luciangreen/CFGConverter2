%% ideacfg_units.pl
%% Unit-aware value handling for IdeaCFG.
:- module(ideacfg_units,
    [
        quantity/2,
        compatible_units/2,
        convert_unit/4,
        add_quantities/3,
        multiply_quantities/3,
        known_unit/1
    ]).

%% known_unit(?Unit) is nondet.
known_unit(metre).   known_unit(km).     known_unit(cm).    known_unit(mm).
known_unit(second).  known_unit(minute). known_unit(hour).  known_unit(day).
known_unit(gram).    known_unit(kg).     known_unit(mg).
known_unit(litre).   known_unit(ml).
known_unit(kelvin).  known_unit(celsius).
known_unit(joule).   known_unit(newton). known_unit(watt).
known_unit(dollar).  known_unit(euro).   known_unit(pound).
known_unit(radian).  known_unit(degree).
known_unit(unit).    % dimensionless

%% compatible_units(?Unit1, ?Unit2) is semidet.
%  True when two units are in the same dimension (addable).
compatible_units(U, U) :- !.
compatible_units(metre, km). compatible_units(km, metre).
compatible_units(metre, cm). compatible_units(cm, metre).
compatible_units(gram, kg).  compatible_units(kg, gram).
compatible_units(second, minute). compatible_units(minute, second).
compatible_units(second, hour).   compatible_units(hour, second).
compatible_units(litre, ml). compatible_units(ml, litre).
compatible_units(celsius, kelvin). compatible_units(kelvin, celsius).

%% convert_unit(+Value, +FromUnit, +ToUnit, -Result) is semidet.
%  Converts a value between units.
convert_unit(V, U, U, V) :- !.
convert_unit(V, km, metre, R) :- R is V * 1000.
convert_unit(V, metre, km, R) :- R is V / 1000.
convert_unit(V, cm, metre, R) :- R is V / 100.
convert_unit(V, metre, cm, R) :- R is V * 100.
convert_unit(V, mm, metre, R) :- R is V / 1000.
convert_unit(V, metre, mm, R) :- R is V * 1000.
convert_unit(V, kg, gram, R) :- R is V * 1000.
convert_unit(V, gram, kg, R) :- R is V / 1000.
convert_unit(V, hour, second, R) :- R is V * 3600.
convert_unit(V, second, hour, R) :- R is V / 3600.
convert_unit(V, minute, second, R) :- R is V * 60.
convert_unit(V, second, minute, R) :- R is V / 60.
convert_unit(V, litre, ml, R) :- R is V * 1000.
convert_unit(V, ml, litre, R) :- R is V / 1000.
convert_unit(V, celsius, kelvin, R) :- R is V + 273.15.
convert_unit(V, kelvin, celsius, R) :- R is V - 273.15.
convert_unit(V, radian, degree, R) :- R is V * (180 / pi).
convert_unit(V, degree, radian, R) :- R is V * (pi / 180).

%% add_quantities(+Q1, +Q2, -Sum) is semidet.
%  Adds two compatible quantities.
add_quantities(quantity(V1, U1), quantity(V2, U2), quantity(Sum, U1)) :-
    (   U1 = U2
    ->  Sum is V1 + V2
    ;   compatible_units(U1, U2)
    ->  convert_unit(V2, U2, U1, V2c),
        Sum is V1 + V2c
    ;   throw(error(incompatible_units(U1, U2), add_quantities/3))
    ).

%% multiply_quantities(+Q1, +Q2, -Product) is det.
%  Multiplies two quantities (units combined).
multiply_quantities(quantity(V1, U1), quantity(V2, U2), quantity(Product, UProduct)) :-
    Product is V1 * V2,
    (   U1 = unit -> UProduct = U2
    ;   U2 = unit -> UProduct = U1
    ;   format(atom(UProduct), '~w*~w', [U1, U2])
    ).

%% quantity(+Value, +Unit) is det.
%  Constructor check for a quantity.
quantity(V, U) :-
    must_be(number, V),
    must_be(atom, U).
