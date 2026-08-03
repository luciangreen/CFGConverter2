%% test_input.pl — Tests for input handling and tokenisation.
:- use_module(library(plunit)).
:- use_module('../prolog/ideacfg_input').
:- use_module('../prolog/ideacfg_tokenise').
:- use_module('../prolog/ideacfg_ir').

:- begin_tests(tokenisation).

test(tokenise_simple_text) :-
    tokenise_text('a sonata has parts', Tokens),
    Tokens = [a, sonata, has, parts].

test(tokenise_empty_text) :-
    tokenise_text('', Tokens),
    Tokens = [].

test(tokenise_with_punctuation) :-
    tokenise_text('width, height and area.', Tokens),
    Tokens = [width, height, and, area].

test(split_sentences_basic) :-
    split_sentences('A is B. C is D.', Sents),
    length(Sents, N),
    N >= 1.

:- end_tests(tokenisation).

:- begin_tests(input_handling).

test(from_text_produces_ir) :-
    idea_from_text(test_idea, 'A sonata has an exposition.', IR),
    ir_name(IR, test_idea).

test(from_sentences_produces_ir) :-
    idea_from_sentences(test2, ['A sonata has an exposition.', 'An exposition has themes.'], IR),
    ir_name(IR, test2).

test(from_terms_produces_ir) :-
    idea_from_terms(test3, [concept(sonata), stage(exposition)], IR),
    ir_name(IR, test3).

test(source_location_term) :-
    source_location(5, source_line(5)).

:- end_tests(input_handling).
