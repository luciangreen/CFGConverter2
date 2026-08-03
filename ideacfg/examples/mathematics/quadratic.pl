%% mathematics/quadratic.pl — Quadratic expression example.
:- use_module('../../prolog/ideacfg_api').

%% Idea: Quadratic expression.
%
% A quadratic expression contains coefficients and a variable.
% The discriminant is b squared minus four times a times c.

quadratic_example :-
    idea_to_cfg(quadratic,
        'A quadratic expression contains coefficients and a variable. The discriminant is b squared minus four times a times c.',
        Result),
    writeln(Result).

%% discriminant(+A, +B, +C, -D) is det.
%  Computes the discriminant b^2 - 4ac.
discriminant(A, B, C, D) :-
    must_be(number, A),
    must_be(number, B),
    must_be(number, C),
    D is B * B - 4 * A * C.

%% quadratic_roots(+A, +B, +C, -Roots) is det.
%  Computes the roots of ax^2 + bx + c = 0.
quadratic_roots(A, B, C, Roots) :-
    must_be(number, A),
    A =\= 0,
    discriminant(A, B, C, D),
    (   D > 0
    ->  R1 is (-B + sqrt(D)) / (2 * A),
        R2 is (-B - sqrt(D)) / (2 * A),
        Roots = two_roots(R1, R2)
    ;   D =:= 0
    ->  R is -B / (2 * A),
        Roots = one_root(R)
    ;   Roots = no_real_roots
    ).
