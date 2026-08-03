%% cfg2_cli.pl
%% Command-line interface for CFG Converter 2.
%%
%% Commands:
%%   cfg2 convert INPUT [--department DEPT] [--schema SCHEMA]
%%   cfg2 validate INPUT
%%   cfg2 inspect INPUT
%%   cfg2 explain ITEM_ID
%%   cfg2 export INPUT --format FORMAT
%%   cfg2 test

:- module(cfg2_cli,
    [
        cfg2_main/0,
        cfg2_run/1,
        cfg2_help/0
    ]).

:- use_module(library(lists)).
:- use_module(cfg2_api).
:- use_module(cfg2_validate).
:- use_module(cfg2_explain).

%% cfg2_main/0: Entry point when running as a script.
cfg2_main :-
    current_prolog_flag(argv, Args),
    (   Args = []
    ->  cfg2_help
    ;   cfg2_run(Args)
    ).

%% cfg2_run(+Args) is det.
cfg2_run([Command|Rest]) :-
    (   cli_command(Command, Rest)
    ->  true
    ;   format(user_error, 'Unknown command: ~w~n', [Command]),
        halt(1)
    ).
cfg2_run([]) :-
    cfg2_help.

cli_command(convert, Args) :-
    parse_convert_args(Args, Input, Options),
    (   atom(Input)
    ->  (   member('--department'=Dept, Options)
        ->  evidence_to_cfg(cfg2_result, Dept, [], Options, Result)
        ;   idea_to_cfg(cfg2_result, Input, Options, Result)
        )
    ;   idea_to_cfg(cfg2_result, Input, Options, Result)
    ),
    print_result(Result).

cli_command(validate, [Input|Rest]) :-
    parse_options(Rest, Options),
    (   exists_file(Input)
    ->  source_adapter(prolog_terms, file(Input), Options, Evidence),
        validate_evidence_list(Evidence, Options, Errors)
    ;   Errors = [error(file, not_found, Input)]
    ),
    (   Errors = []
    ->  format('Validation passed.~n')
    ;   maplist([E]>>(format('Error: ~w~n', [E])), Errors),
        halt(1)
    ).

cli_command(inspect, [Input|Rest]) :-
    parse_options(Rest, Options),
    (   exists_file(Input)
    ->  source_adapter(prolog_terms, file(Input), Options, Evidence),
        length(Evidence, N),
        format('Evidence records: ~w~n', [N]),
        maplist([E]>>(
            cfg2_evidence:evidence_id(E, Id),
            cfg2_evidence:evidence_type(E, Type),
            format('  ~w: ~w~n', [Id, Type])
        ), Evidence)
    ;   format(user_error, 'File not found: ~w~n', [Input]),
        halt(1)
    ).

cli_command(explain, [ItemId|Rest]) :-
    parse_options(Rest, _Options),
    format('Explanation for ~w: not available without a loaded result.~n', [ItemId]).

cli_command(export, [Input|Rest]) :-
    parse_options(Rest, Options),
    (   member('--format'=Format, Options)
    ->  true
    ;   Format = prolog
    ),
    (   member('--output'=OutPath, Options)
    ->  true
    ;   atom_concat(Input, '.out', OutPath)
    ),
    idea_to_cfg(cfg2_export, Input, Options, Result),
    export_cfg2(Result, Format, OutPath, Options),
    format('Exported to: ~w~n', [OutPath]).

cli_command(test, _) :-
    format('Running CFG Converter 2 tests...~n'),
    (   catch(
            run_tests,
            Error,
            (format(user_error, 'Test error: ~w~n', [Error]), halt(1))
        )
    ->  format('Tests complete.~n')
    ;   format(user_error, 'Tests failed.~n'),
        halt(1)
    ).

cli_command(help, _) :- cfg2_help.

%% cfg2_help/0: Prints usage.
cfg2_help :-
    format('CFG Converter 2~n~n'),
    format('Usage: cfg2 <command> [options]~n~n'),
    format('Commands:~n'),
    format('  convert INPUT [--department DEPT] [--schema SCHEMA]~n'),
    format('  validate INPUT~n'),
    format('  inspect INPUT~n'),
    format('  explain ITEM_ID~n'),
    format('  export INPUT --format FORMAT [--output PATH]~n'),
    format('  test~n'),
    format('  help~n~n'),
    format('Formats: prolog, cfg, json~n').

parse_convert_args(Args, Input, Options) :-
    (   Args = [Input|Rest]
    ->  parse_options(Rest, Options)
    ;   Input = '', Options = []
    ).

parse_options([], []).
parse_options(['--department', Dept|Rest], ['--department'=Dept|Opts]) :-
    parse_options(Rest, Opts).
parse_options(['--schema', Schema|Rest], ['--schema'=Schema|Opts]) :-
    parse_options(Rest, Opts).
parse_options(['--format', Format|Rest], ['--format'=Format|Opts]) :-
    parse_options(Rest, Opts).
parse_options(['--output', Path|Rest], ['--output'=Path|Opts]) :-
    parse_options(Rest, Opts).
parse_options([_Unknown|Rest], Opts) :-
    parse_options(Rest, Opts).

print_result(Result) :-
    Result = result(project(Name), department(Dept), _, _, evidence(Evids),
                    _, cfg(_, CFGText), _, _, _, _, _, _, diagnostics(Diags)),
    format('Project: ~w~n', [Name]),
    format('Department: ~w~n', [Dept]),
    length(Evids, NE),
    format('Evidence: ~w records~n', [NE]),
    format('~nCFG:~n~w~n', [CFGText]),
    (   Diags \= []
    ->  format('~nDiagnostics:~n'),
        maplist([D]>>(format('  ~w~n', [D])), Diags)
    ;   true
    ).
print_result(Result) :-
    format('Result: ~w~n', [Result]).
