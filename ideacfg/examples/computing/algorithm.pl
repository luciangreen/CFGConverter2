%% computing/algorithm.pl — Algorithm structure example.
:- use_module('../../prolog/ideacfg_api').

%% Idea: Algorithm structure.
%
% An algorithm contains input, initialisation, repeated steps, conditions and output.

computing_example(Result) :-
    idea_to_cfg(algorithm,
        [sequence(algorithm, [input, initialisation, loop_body, output], [], src),
         repetition(loop_body, step, 1, 100, [bounded], src),
         alternative(condition, [less_than, equal_to, greater_than], [], src)],
        Result).

%% linear_search(+List, +Target, -Index) is semidet.
linear_search([H|_], H, 0) :- !.
linear_search([_|T], Target, Index) :-
    linear_search(T, Target, I0),
    Index is I0 + 1.
