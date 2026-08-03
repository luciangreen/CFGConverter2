%% biology/pathway.pl — Biological pathway example.
:- use_module('../../prolog/ideacfg_api').

%% Idea: Biological pathway.
%
% A biological pathway contains stages and regulatory alternatives.

pathway_example(Result) :-
    idea_to_cfg(photosynthesis,
        [concept(photosynthesis),
         stage(light_dependent_reactions),
         stage(calvin_cycle),
         precedes(light_dependent_reactions, calvin_cycle),
         requires(calvin_cycle, carbon_dioxide),
         sequence(photosynthesis, [light_dependent_reactions, calvin_cycle], [], src)],
        Result).
