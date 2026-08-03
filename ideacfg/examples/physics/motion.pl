%% physics/motion.pl — Motion problem example.
:- use_module('../../prolog/ideacfg_api').

%% Idea: Motion problem.
%
% A motion problem contains initial velocity, acceleration and time.
% Final velocity equals initial velocity plus acceleration multiplied by time.

:- idea_to_cfg(motion,
    ['A motion problem contains initial velocity, acceleration and time.',
     'Final velocity equals initial velocity plus acceleration multiplied by time.'],
    _Result).

%% final_velocity(+InitV, +Accel, +Time, -FinalV) is det.
%  Computes final velocity: v = u + at
final_velocity(U, A, T, V) :-
    must_be(number, U),
    must_be(number, A),
    must_be(number, T),
    V is U + A * T.

%% displacement(+InitV, +Time, +Accel, -S) is det.
%  Computes displacement: s = ut + 0.5at^2
displacement(U, T, A, S) :-
    must_be(number, U),
    must_be(number, T),
    must_be(number, A),
    S is U * T + 0.5 * A * T * T.
