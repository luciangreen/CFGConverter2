%% test_repl.pl — Tests for REPL command processing.
:- use_module(library(plunit)).
:- use_module('../prolog/ideacfg_repl').

:- begin_tests(repl).

test(process_help) :-
    process_command(help, state(none, []), state(none, [])).

test(process_new_idea) :-
    process_command(new(sonata), state(none, []), state(sonata, [])).

test(process_add_text) :-
    process_command(add('A sonata has parts.'), state(sonata, []), state(sonata, ['A sonata has parts.'])).

test(process_reset) :-
    process_command(reset, state(sonata, ['text']), state(none, [])).

test(process_unknown_command) :-
    process_command(unknown_cmd_xyz, state(none, []), state(none, [])).

test(process_analyse) :-
    process_command(analyse, state(test_idea, ['A is B.']), state(test_idea, ['A is B.'])).

:- end_tests(repl).
