%% philosophy/argument.pl — Philosophical argument example.
:- use_module('../../prolog/ideacfg_api').

%% Idea: Philosophical argument structure.
%
% An argument contains premises, an inference and a conclusion.
% An objection may challenge a premise or the inference.

philosophy_example(Result) :-
    idea_to_cfg(philosophical_argument,
        [sequence(argument, [premises, inference, conclusion], [], src),
         alternative(objection_target, [premise, inference], [], src),
         optional(objection, objection_target, [], src)],
        Result).

%% Note: Philosophical validity is not automatically computable.
%  This example represents argument structure, not semantic truth.
