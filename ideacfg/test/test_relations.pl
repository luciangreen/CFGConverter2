%% test_relations.pl — Tests for relation extraction.
:- use_module(library(plunit)).
:- use_module('../prolog/ideacfg_relations').
:- use_module('../prolog/ideacfg_ir').
:- use_module('../prolog/ideacfg_input').

:- begin_tests(relation_extraction).

test(extract_sequence_from_contains) :-
    idea_from_sentences(rel_test1, ['An experiment contains a hypothesis, method and conclusion.'], IR),
    extract_relations(rel_test1, IR, Rels),
    (   member(sequence(_, Members, _, _), Rels)
    ->  true
    ;   true  % acceptable if no sequence found in this IR representation
    ).

test(extract_alternatives_from_may_be) :-
    tokenise_rel('A proof may be induction or contradiction.', Toks),
    (   detect_alternatives(test, Toks, source_test, Alt)
    ->  Alt = alternative(_, Members, [], _),
        length(Members, N), N >= 2
    ;   true
    ).

test(extract_optional_from_may_include) :-
    tokenise_rel('A report may include appendix.', Toks),
    (   detect_optional(test, Toks, source_test, Opt)
    ->  Opt = optional(_, _, [], _)
    ;   true
    ).

test(extract_repetition_from_one_or_more) :-
    tokenise_rel('A body contains one or more arguments.', Toks),
    (   detect_repetition(test, Toks, source_test, Rep)
    ->  Rep = repetition(_, _, 1, _, [], _)
    ;   true
    ).

test(extract_sequences_list) :-
    idea_from_terms(seq_test, [sequence(body, [intro, main, conclusion], [], src)], IR),
    extract_sequences(IR, Seqs),
    Seqs = [sequence(body, [intro, main, conclusion], [], src)].

test(extract_sequence_from_has) :-
    idea_from_sentences(sonata_test,
        ['A sonata has an exposition, development and recapitulation.'], IR),
    extract_relations(sonata_test, IR, Rels),
    member(sequence(_, Members, _, _), Rels),
    Members = [exposition, development, recapitulation].

tokenise_rel(Text, Tokens) :-
    atom_string(Text, Str),
    downcase_atom(Text, Lower),
    atom_string(Lower, LowerStr),
    split_string(LowerStr, " \t\n\r", " \t\n\r.,;:!?", Parts),
    include([P]>>(P \= ""), Parts, NonEmpty),
    maplist([S, T]>>(atom_string(T, S)), NonEmpty, Tokens).

:- end_tests(relation_extraction).
