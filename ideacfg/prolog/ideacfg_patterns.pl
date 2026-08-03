%% ideacfg_patterns.pl
%% Domain-general idea patterns for IdeaCFG.
:- module(ideacfg_patterns,
    [
        pattern/2,
        apply_pattern/3,
        known_patterns/1
    ]).

%% pattern(?Name, ?Structure) is nondet.
%  Defines known academic patterns as IR structures.
pattern(classification, [
    alternative(category, subcategories, [], source_pattern)
]).
pattern(composition, [
    sequence(whole, parts, [], source_pattern)
]).
pattern(process, [
    sequence(process, stages, [], source_pattern)
]).
pattern(causation, [
    sequence(causal_model, [cause, mechanism, effect], [], source_pattern)
]).
pattern(argument, [
    sequence(argument, [claim, support, qualification], [], source_pattern)
]).
pattern(comparison, [
    sequence(comparison, [subject_a, dimension, subject_b, conclusion], [], source_pattern)
]).
pattern(experiment, [
    sequence(experiment, [hypothesis, method, observation, analysis, conclusion], [], source_pattern)
]).
pattern(transformation, [
    sequence(transformation, [input, operator, output], [], source_pattern)
]).
pattern(feedback_loop, [
    sequence(feedback_system, [state, action, observation, update], [], source_pattern)
]).
pattern(creative_composition, [
    sequence(artwork, [theme, form, material, technique, development, resolution], [], source_pattern)
]).
pattern(historical_explanation, [
    sequence(historical_account, [context, actors, events, consequences, interpretation], [], source_pattern)
]).
pattern(proof, [
    sequence(proof, [premises, method, steps, conclusion], [], source_pattern)
]).

%% apply_pattern(+PatternName, +IdeaName, -Elements) is semidet.
%  Returns IR elements for a named pattern.
apply_pattern(PatternName, IdeaName, Elements) :-
    must_be(atom, PatternName),
    must_be(atom, IdeaName),
    pattern(PatternName, Elements).

%% known_patterns(-Patterns) is det.
%  Returns all known pattern names.
known_patterns(Patterns) :-
    findall(N, pattern(N, _), Patterns).
