%% departments/neuroolfaction.pl
%% Neuroolfaction department plugin for CFG Converter 2.
%%
%% This plugin provides a software representation format for
%% qualitative neuroolfactory unit measurements.
%% It is NOT a claim that this unit system is scientifically established.

:- module(dept_neuroolfaction,
    [
        neuroolfactory_level/2,
        classify_olfactory_level/2,
        valid_stimulus/1,
        valid_olfactory_dimension/1,
        olfactory_response_cfg/1,
        olfactory_response_dcg/1,
        qualitative_at_least/2
    ]).

:- use_module(library(lists)).
:- use_module('../prolog/cfg2_measurements').

%% Qualitative neuroolfactory ordinal scale.
%  The scale is configurable by overriding these facts.
neuroolfactory_level(none,     0).
neuroolfactory_level(trace,    1).
neuroolfactory_level(weak,     2).
neuroolfactory_level(moderate, 3).
neuroolfactory_level(strong,   4).
neuroolfactory_level(intense,  5).

%% classify_olfactory_level(+Level, -Category) is semidet.
classify_olfactory_level(none,     no_response).
classify_olfactory_level(trace,    minimal_response).
classify_olfactory_level(weak,     weak_response).
classify_olfactory_level(moderate, moderate_response).
classify_olfactory_level(strong,   strong_response).
classify_olfactory_level(intense,  intense_response).
classify_olfactory_level(N, Category) :-
    number(N),
    neuroolfactory_level(Level, Threshold),
    N >= Threshold,
    \+ (neuroolfactory_level(_, Higher), Higher > Threshold, N >= Higher),
    classify_olfactory_level(Level, Category).

%% valid_stimulus(+Stimulus) is semidet.
valid_stimulus(S) :- ordinal_scale(stimulus_category, Cats), member(S, Cats), !.
valid_stimulus(S) :- atom(S).  % Any atom is a valid stimulus; refine as needed.

%% valid_olfactory_dimension(+Dimension) is semidet.
valid_olfactory_dimension(perceived_intensity).
valid_olfactory_dimension(recognition_confidence).
valid_olfactory_dimension(pleasantness).
valid_olfactory_dimension(familiarity).
valid_olfactory_dimension(emotional_association).
valid_olfactory_dimension(memory_activation).
valid_olfactory_dimension(adaptation).
valid_olfactory_dimension(response_latency).
valid_olfactory_dimension(cross_modal_association).
valid_olfactory_dimension(observer_reliability).

%% qualitative_at_least(+Value, +Threshold) is semidet.
%  True when Value is at least Threshold on the neuroolfactory scale.
qualitative_at_least(Value, Threshold) :-
    neuroolfactory_level(Value, VN),
    neuroolfactory_level(Threshold, TN),
    VN >= TN.
qualitative_at_least(Value, Threshold) :-
    number(Value),
    neuroolfactory_level(Threshold, TN),
    Value >= TN.

%% olfactory_response_cfg(-CFGRules) is det.
%  Returns example CFG rules for the neuroolfaction department.
olfactory_response_cfg([
    cfg_rule(r_olf1, olfactory_response,
             [no_response], [department(neuroolfaction)]),
    cfg_rule(r_olf2, olfactory_response,
             [weak_response], [department(neuroolfaction)]),
    cfg_rule(r_olf3, olfactory_response,
             [moderate_response], [department(neuroolfaction)]),
    cfg_rule(r_olf4, olfactory_response,
             [strong_response], [department(neuroolfaction)])
]).

%% olfactory_response_dcg(-DCGText) is det.
%  Returns example DCG text for olfactory response classification.
olfactory_response_dcg(Text) :-
    Text = "olfactory_response(Response, EvidenceIds) -->\n\
    olfactory_observation(Stimulus, Level, EvidenceId),\n\
    {\n\
        classify_olfactory_level(Level, Response),\n\
        EvidenceIds = [EvidenceId],\n\
        valid_stimulus(Stimulus)\n\
    }.".

:- initialization(
    format('Neuroolfaction department plugin loaded.~n'),
    now
).
