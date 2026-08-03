%% ideacfg_cli.pl
%% Command-line interface for IdeaCFG.
:- module(ideacfg_cli,
    [
        main/1,
        cli_command/3,
        exit_code/2,
        parse_options/2
    ]).

:- use_module(ideacfg_api).
:- use_module(ideacfg_diagnostics).
:- use_module(library(lists)).

%% exit_code(?Name, ?Code) is nondet.
%  Exit codes for CLI.
exit_code(success,           0).
exit_code(invalid_input,     1).
exit_code(unresolved_ambiguity, 2).
exit_code(unsupported_operation, 3).
exit_code(unsafe_generated,  4).
exit_code(test_failure,      5).
exit_code(resource_limit,    6).
exit_code(internal_error,    7).

%% main(+Args) is det.
%  Entry point for CLI invocation.
main(Args) :-
    catch(
        (   parse_cli_args(Args, Command, Options),
            cli_command(Command, Options, ExitCode)
        ),
        Error,
        (   format(user_error, 'Error: ~w~n', [Error]),
            exit_code(internal_error, Code),
            halt(Code)
        )
    ),
    halt(ExitCode).

%% parse_cli_args(+Args, -Command, -Options) is det.
parse_cli_args([], help, []) :- !.
parse_cli_args([Cmd|Rest], Command, Options) :-
    atom_string(Command, Cmd),
    parse_options(Rest, Options).

parse_options([], []) :- !.
parse_options(['--name', Name | Rest], [name(NameAtom)|Opts]) :-
    atom_string(NameAtom, Name), !,
    parse_options(Rest, Opts).
parse_options(['--input', File | Rest], [input(FileAtom)|Opts]) :-
    atom_string(FileAtom, File), !,
    parse_options(Rest, Opts).
parse_options(['--output', Path | Rest], [output(PathAtom)|Opts]) :-
    atom_string(PathAtom, Path), !,
    parse_options(Rest, Opts).
parse_options(['--count', N | Rest], [count(Count)|Opts]) :-
    atom_string(NAtom, N), atom_number(NAtom, Count), !,
    parse_options(Rest, Opts).
parse_options(['--idea', Idea | Rest], [idea(IdeaAtom)|Opts]) :-
    atom_string(IdeaAtom, Idea), !,
    parse_options(Rest, Opts).
parse_options(['--text', Text | Rest], [text(TextAtom)|Opts]) :-
    atom_string(TextAtom, Text), !,
    parse_options(Rest, Opts).
parse_options([_Opt | Rest], Opts) :-
    parse_options(Rest, Opts).

%% cli_command(+Command, +Options, -ExitCode) is det.
cli_command(convert, Options, 0) :-
    memberchk(name(Name), Options),
    memberchk(input(InputFile), Options), !,
    (   exists_file(InputFile)
    ->  read_file_to_atom(InputFile, Text, [encoding(utf8)]),
        idea_to_cfg(Name, Text, _Result),
        (   memberchk(output(OutPath), Options)
        ->  format(atom(OutFile), '~w.pl', [OutPath]),
            idea_from_text(Name, Text, Model),
            generate_module(Name, Model, ModText),
            write_to_file(OutFile, ModText),
            format('Converted ~w. Output: ~w~n', [Name, OutFile])
        ;   format('Converted ~w.~n', [Name])
        )
    ;   format(user_error, 'Input file not found: ~w~n', [InputFile]),
        exit_code(invalid_input, _),
        halt(1)
    ).
cli_command(convert, _Options, 1) :-
    write('Usage: convert --name NAME --input FILE [--output PATH]'), nl.

cli_command('show-operations', Options, 0) :-
    memberchk(input(InputFile), Options), !,
    (   exists_file(InputFile)
    ->  read_file_to_atom(InputFile, Text, [encoding(utf8)]),
        atom_to_term(text, Name, []),
        idea_from_text(ops_idea, Text, Model),
        extract_operations(ops_idea, Model, Ops),
        format('Operations:~n'),
        maplist([O]>>(format('  ~w~n', [O])), Ops)
    ;   format(user_error, 'Input file not found: ~w~n', [InputFile]),
        halt(1)
    ).
cli_command('show-operations', _Options, 1).

cli_command(generate, Options, 0) :-
    memberchk(idea(Idea), Options), !,
    Count = (memberchk(count(C), Options) -> C ; 1),
    format('Generating from ~w...~n', [Idea]).
cli_command(generate, _Options, 1).

cli_command(parse, Options, 0) :-
    memberchk(idea(Idea), Options),
    memberchk(text(Text), Options), !,
    tokenise_text(Text, Tokens),
    (   idea_parse(Idea, Tokens, Tree)
    ->  format('Parse tree: ~w~n', [Tree])
    ;   format('No parse.~n'), halt(1)
    ).
cli_command(parse, _Options, 1).

cli_command(test, Options, Code) :-
    memberchk(idea(Idea), Options), !,
    format('Running tests for ~w...~n', [Idea]),
    (   run_idea_tests(Idea)
    ->  write('All tests passed.'), nl, Code = 0
    ;   write('Tests failed.'), nl, Code = 5
    ).
cli_command(test, _Options, 1).

cli_command(help, _, 0) :-
    write('IdeaCFG - Academic Idea to CFG Generator'), nl,
    write('Usage: swipl -q -s ideacfg.pl -- COMMAND [OPTIONS]'), nl,
    write(''), nl,
    write('Commands:'), nl,
    write('  convert --name NAME --input FILE [--output PATH]'), nl,
    write('  show-operations --input FILE'), nl,
    write('  generate --idea NAME [--count N]'), nl,
    write('  parse --idea NAME --text TEXT'), nl,
    write('  test --idea NAME'), nl,
    write('  help'), nl.

cli_command(Unknown, _, 7) :-
    format(user_error, 'Unknown command: ~w~n', [Unknown]).

run_idea_tests(_Idea) :- true.

tokenise_text(Text, Tokens) :-
    atomic_list_concat(Tokens, ' ', Text).

read_file_to_atom(File, Atom, _Options) :-
    setup_call_cleanup(
        open(File, read, Stream, [encoding(utf8)]),
        (   read_term(Stream, Term, []),
            (   Term = end_of_file -> Atom = '' ; term_to_atom(Term, Atom))
        ),
        close(Stream)
    ).
