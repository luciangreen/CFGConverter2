%% literature/narrative.pl — Narrative structure example.
:- use_module('../../prolog/ideacfg_api').

%% Idea: Narrative structure.
%
% A narrative contains a setting, conflict, development, climax and resolution.

literature_example(Result) :-
    idea_to_cfg(narrative,
        [sequence(narrative, [setting, conflict, development, climax, resolution], [], src),
         repetition(subplot, subplot_element, 0, 3, [bounded], src)],
        Result).
