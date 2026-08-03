%% chemistry/molecule.pl — Molecule molar mass example.
:- use_module('../../prolog/ideacfg_api').
:- use_module(library(lists)).

%% Idea: Molecular formula and molar mass.
%
% A molecule consists of elements with integer atom counts.
% Molar mass is the sum of each atomic mass multiplied by its atom count.

%% atomic_mass(?Element, ?Mass) is nondet.
atomic_mass(h,  1.008).  atomic_mass(c, 12.011).
atomic_mass(n, 14.007).  atomic_mass(o, 15.999).
atomic_mass(na, 22.990). atomic_mass(cl, 35.453).
atomic_mass(ca, 40.078). atomic_mass(fe, 55.845).

%% molar_mass(+Formula, -Mass) is det.
%  Formula is a list of Element-Count pairs.
molar_mass(Formula, Mass) :-
    must_be(list, Formula),
    maplist([Elem-Count, Contrib]>>(
                must_be(integer, Count),
                (   atomic_mass(Elem, AM)
                ->  Contrib is AM * Count
                ;   throw(error(unknown_element(Elem), molar_mass/2))
                )
            ), Formula, Contribs),
    sumlist(Contribs, Mass).

%% water_example/0.
water_example :-
    molar_mass([h-2, o-1], Mass),
    format('Water (H2O) molar mass: ~2f g/mol~n', [Mass]).
