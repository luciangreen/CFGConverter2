%% test_dcg.pl — Tests for DCG generation.
:- use_module(library(plunit)).
:- use_module('../prolog/ideacfg_dcg').
:- use_module('../prolog/ideacfg_ir').
:- use_module('../prolog/ideacfg_input').

:- begin_tests(dcg_generation).

test(dcg_clauses_from_sequence) :-
    idea_from_terms(dcg_seq, [sequence(essay, [intro, body, conclusion], [], src)], IR),
    generate_dcg(dcg_seq, IR, Clauses),
    member(dcg_clause(essay, _, []), Clauses).

test(dcg_to_prolog_text_nonempty) :-
    generate_dcg(dcg_text_test, idea(dcg_text_test, [],
        [sequence(s, [a, b], [], src)]), Clauses),
    dcg_to_prolog_text(Clauses, Text),
    atom_length(Text, L), L > 0.

test(compile_dcg_module_produces_header) :-
    Clauses = [dcg_clause(sonata, [nonterminal(exposition)], [])],
    compile_dcg_module(sonata, Clauses, ModText),
    sub_atom(ModText, _, _, _, ':- module(').

test(dcg_clause_constructor) :-
    dcg_clause(test_head, [nonterminal(a)], []).

:- end_tests(dcg_generation).
