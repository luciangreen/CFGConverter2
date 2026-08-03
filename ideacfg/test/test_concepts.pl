%% test_concepts.pl — Tests for concept extraction.
:- use_module(library(plunit)).
:- use_module('../prolog/ideacfg_concepts').
:- use_module('../prolog/ideacfg_ir').
:- use_module('../prolog/ideacfg_input').

:- begin_tests(concept_extraction).

test(is_concept_word_positive) :-
    is_concept_word(sonata).

test(is_concept_word_negative_stopword) :-
    \+ is_concept_word(is).

test(is_concept_word_negative_short) :-
    \+ is_concept_word(a).

test(concept_type_category) :-
    concept_type(category).

test(concept_type_process) :-
    concept_type(process).

test(extract_concepts_from_simple_ir) :-
    idea_from_terms(concepts_test, [concept(sonata), concept(exposition)], IR),
    extract_concepts(concepts_test, IR, Concepts),
    maplist([C]>>(C = concept(_, _, _, _, _)), Concepts).

test(build_concept_term) :-
    build_concept(c1, sonata, category, [], Concept),
    Concept = concept(c1, sonata, category, [], _).

:- end_tests(concept_extraction).
