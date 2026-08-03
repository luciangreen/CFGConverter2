%% visual_art/composition.pl — Visual composition example.
:- use_module('../../prolog/ideacfg_api').

%% Idea: Visual composition structure.
%
% A composition contains a focal element, supporting elements, colour relationships and spatial balance.

visual_art_example(Result) :-
    idea_to_cfg(visual_composition,
        [sequence(composition, [focal_element, supporting_elements, colour_relationships, spatial_balance], [], src),
         alternative(colour_relationship, [complementary, analogous, triadic, monochromatic], [], src),
         alternative(spatial_balance, [symmetric, asymmetric, radial], [], src)],
        Result).

%% golden_ratio_proportion(+Width, -Height) is det.
%  Computes height for golden ratio proportion.
golden_ratio_proportion(Width, Height) :-
    must_be(number, Width),
    Phi is (1 + sqrt(5)) / 2,
    Height is Width / Phi.
