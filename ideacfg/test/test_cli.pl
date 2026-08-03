%% test_cli.pl — Tests for CLI parsing and commands.
:- use_module(library(plunit)).
:- use_module('../prolog/ideacfg_cli').

:- begin_tests(cli).

test(exit_code_success) :- exit_code(success, 0).
test(exit_code_invalid) :- exit_code(invalid_input, 1).
test(exit_code_test_fail) :- exit_code(test_failure, 5).
test(exit_code_internal) :- exit_code(internal_error, 7).

test(cli_help_command) :-
    cli_command(help, [], Code),
    Code = 0.

test(cli_unknown_command) :-
    cli_command(unknown_xyz, [], Code),
    Code = 7.

test(cli_convert_no_options) :-
    cli_command(convert, [], Code),
    Code = 1.

test(cli_parse_options_name) :-
    parse_options(['--name', 'sonata', '--input', 'test.txt'], Opts),
    memberchk(name(sonata), Opts),
    memberchk(input('test.txt'), Opts).

test(cli_parse_options_count) :-
    parse_options(['--count', '5'], Opts),
    memberchk(count(5), Opts).

:- end_tests(cli).
