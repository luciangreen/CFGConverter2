%% ideacfg.pl
%% Main entry point for IdeaCFG.
%% Usage: swipl -q -s ideacfg.pl -- COMMAND [OPTIONS]

:- set_prolog_flag(verbose, silent).

:- use_module(prolog/ideacfg_api).
:- use_module(prolog/ideacfg_repl).
:- use_module(prolog/ideacfg_cli).

%% Initialise: if invoked from command line, dispatch to CLI.
:- initialization(main_or_repl, main).

main_or_repl :-
    current_prolog_flag(argv, Args),
    (   Args = [_Script|CliArgs], CliArgs \= []
    ->  main(CliArgs)
    ;   ideacfg
    ).
