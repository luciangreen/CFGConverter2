%% test_codegen.pl — Tests for code generation.
:- use_module(library(plunit)).
:- use_module('../prolog/ideacfg_codegen').
:- use_module('../prolog/ideacfg_ir').
:- use_module('../prolog/ideacfg_input').

:- begin_tests(operation_codegen).

test(generate_module_produces_text) :-
    idea_from_terms(cg_test, [sequence(sonata, [exposition, development], [], src)], IR),
    generate_module(cg_test, IR, ModText),
    atom_length(ModText, L),
    L > 0.

% The generated module parses and generates: it has a top rule, and a rule
% for each word its grammar uses.
test(generated_module_parses_and_generates) :-
    idea_from_terms(cg_sonata, [sequence(sonata, [exposition, development], [], src)], IR),
    generate_module(cg_sonata, IR, ModText),
    tmp_file_stream(text, File, S), write(S, ModText), close(S),
    load_files(File, [if(true)]),
    findall(T, idea_cg_sonata:idea_generate(cg_sonata, T), Ts),
    Ts = [Tokens|_],
    idea_cg_sonata:idea_parse(cg_sonata, Tokens, Tree),
    Tree = tree(_, [_|_]).

test(generate_module_contains_module_decl) :-
    idea_from_terms(cg_test2, [], IR),
    generate_module(cg_test2, IR, ModText),
    sub_atom(ModText, _, _, _, ':- module(').

test(generate_test_suite) :-
    idea_from_terms(ts_test, [], IR),
    generate_test_suite(ts_test, IR, TestText),
    sub_atom(TestText, _, _, _, ':- begin_tests(').

test(generated_rule_term) :-
    generated_rule(r1, sonata, [exposition], [source(s1)], Term),
    Term = generated_rule(r1, sonata, [exposition], [source(s1)]).

test(generated_operation_term) :-
    generated_operation(op1, transpose_pitch, transformation, Term),
    Term = generated_operation(op1, transpose_pitch, transformation, []).

:- end_tests(operation_codegen).
