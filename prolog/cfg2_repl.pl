%% cfg2_repl.pl
%% Interactive REPL for CFG Converter 2.
%%
%% Commands:
%%   load <source>
%%   schema <schema-name>
%%   department <department-name>
%%   convert
%%   show evidence | cfg | dcg | interpretations
%%   explain <item-id>
%%   validate
%%   export <format> <path>
%%   clear
%%   help
%%   quit

:- module(cfg2_repl,
    [
        cfg2_repl/0,
        cfg2_repl_step/3
    ]).

:- use_module(library(lists)).
:- use_module(cfg2_api).
:- use_module(cfg2_evidence).
:- use_module(cfg2_explain).
:- use_module(cfg2_validate).

%% REPL state: state(Sources, Schema, Department, Evidence, Result)
:- meta_predicate cfg2_repl_step(+, +, -).

%% cfg2_repl/0: Starts the interactive REPL.
cfg2_repl :-
    format('CFG Converter 2 REPL~n'),
    format('Type "help" for available commands, "quit" to exit.~n~n'),
    empty_state(State),
    repl_loop(State).

repl_loop(State) :-
    format('cfg2> '),
    (   read_line_to_string(user_input, Line),
        Line \= end_of_file
    ->  atom_string(LineAtom, Line),
        (   catch(
                cfg2_repl_step(LineAtom, State, NewState),
                Error,
                (format('Error: ~w~n', [Error]), NewState = State)
            )
        ->  true
        ;   NewState = State
        ),
        repl_loop(NewState)
    ;   format('~nGoodbye.~n')
    ).

%% cfg2_repl_step(+Command, +State, -NewState) is det.
cfg2_repl_step('', State, State) :- !.
cfg2_repl_step(quit, _, _)  :- !, format('Goodbye.~n'), halt.
cfg2_repl_step(help, State, State) :- !, repl_help.
cfg2_repl_step(clear, _, NewState) :- !, empty_state(NewState), format('State cleared.~n').
cfg2_repl_step(convert, State, NewState) :- !,
    state_evidence(State, Evidence),
    state_department(State, Dept),
    (   Evidence = []
    ->  format('No evidence loaded. Use: load <source>~n'),
        NewState = State
    ;   evidence_to_cfg(repl_result, Dept, Evidence, [], Result),
        state_set_result(State, Result, NewState),
        format('Conversion complete.~n')
    ).
cfg2_repl_step(validate, State, State) :- !,
    state_evidence(State, Evidence),
    validate_evidence_list(Evidence, [], Errors),
    (   Errors = []
    ->  format('Validation passed.~n')
    ;   maplist([E]>>(format('  ~w~n', [E])), Errors)
    ).
cfg2_repl_step(Cmd, State, State) :-
    atom_string(Cmd, CmdStr),
    split_string(CmdStr, " ", "", Parts),
    Parts = [Head|Tail],
    atom_string(HeadAtom, Head),
    repl_command(HeadAtom, Tail, State, NewState), !,
    (   NewState \= State
    ->  true
    ;   true
    ).
cfg2_repl_step(Cmd, State, State) :-
    format('Unknown command: ~w. Type "help" for help.~n', [Cmd]).

repl_command(load, [SourceStr|_], State, NewState) :-
    atom_string(Source, SourceStr),
    (   exists_file(Source)
    ->  source_adapter(prolog_terms, file(Source), [], Evidence),
        state_add_evidence(State, Evidence, NewState),
        length(Evidence, N),
        format('Loaded ~w evidence records.~n', [N])
    ;   format('File not found: ~w~n', [Source]),
        NewState = State
    ).
repl_command(schema, [SchemaStr|_], State, NewState) :-
    atom_string(Schema, SchemaStr),
    state_set_schema(State, Schema, NewState),
    format('Schema set to: ~w~n', [Schema]).
repl_command(department, [DeptStr|_], State, NewState) :-
    atom_string(Dept, DeptStr),
    state_set_department(State, Dept, NewState),
    format('Department set to: ~w~n', [Dept]).
repl_command(show, ["evidence"|_], State, State) :-
    state_evidence(State, Evidence),
    length(Evidence, N),
    format('Evidence records: ~w~n', [N]),
    maplist([E]>>(
        evidence_id(E, Id), evidence_type(E, T),
        format('  ~w: ~w~n', [Id, T])
    ), Evidence).
repl_command(show, ["cfg"|_], State, State) :-
    state_result(State, Result),
    (   Result = result(_, _, _, _, _, _, cfg(_, CFGText), _, _, _, _, _, _, _)
    ->  format('~w~n', [CFGText])
    ;   format('No CFG generated yet. Use: convert~n')
    ).
repl_command(show, ["dcg"|_], State, State) :-
    state_result(State, Result),
    (   Result = result(_, _, _, _, _, _, _, dcg(DCGClauses), _, _, _, _, _, _)
    ->  maplist([C]>>(format('~w~n', [C])), DCGClauses)
    ;   format('No DCG generated yet. Use: convert~n')
    ).
repl_command(show, ["interpretations"|_], State, State) :-
    state_result(State, Result),
    (   Result = result(_, _, _, _, _, _, _, _, _, _, interpretations(Interps), _, _, _)
    ->  (   Interps = []
        ->  format('No interpretations.~n')
        ;   maplist([I]>>(format('  ~w~n', [I])), Interps)
        )
    ;   format('No result available. Use: convert~n')
    ).
repl_command(explain, [ItemStr|_], State, State) :-
    atom_string(Item, ItemStr),
    state_result(State, Result),
    (   Result \= none
    ->  explain_derivation(Item, Result, Expl),
        format('~w~n', [Expl])
    ;   format('No result available. Use: convert~n')
    ).
repl_command(export, [FormatStr, PathStr|_], State, State) :-
    atom_string(Format, FormatStr),
    atom_string(Path, PathStr),
    state_result(State, Result),
    (   Result \= none
    ->  export_cfg2(Result, Format, Path, []),
        format('Exported to: ~w~n', [Path])
    ;   format('No result available. Use: convert~n')
    ).
repl_command(_, _, State, State).

%% State accessors / constructors
empty_state(state([], none, unknown, [], none)).

state_evidence(state(_, _, _, Evidence, _), Evidence).
state_department(state(_, _, Dept, _, _), Dept).
state_result(state(_, _, _, _, Result), Result).

state_add_evidence(state(Srcs, Sch, Dept, OldEv, Res), NewEv, state(Srcs, Sch, Dept, AllEv, Res)) :-
    append(OldEv, NewEv, AllEv).

state_set_schema(state(Srcs, _, Dept, Ev, Res), Sch, state(Srcs, Sch, Dept, Ev, Res)).
state_set_department(state(Srcs, Sch, _, Ev, Res), Dept, state(Srcs, Sch, Dept, Ev, Res)).
state_set_result(state(Srcs, Sch, Dept, Ev, _), Res, state(Srcs, Sch, Dept, Ev, Res)).

repl_help :-
    format('Available commands:~n'),
    format('  load <source>           Load evidence from file~n'),
    format('  schema <name>           Set active schema~n'),
    format('  department <name>       Set active department~n'),
    format('  convert                 Generate CFG/DCG from loaded evidence~n'),
    format('  show evidence           Show loaded evidence~n'),
    format('  show cfg                Show generated CFG~n'),
    format('  show dcg                Show generated DCG~n'),
    format('  show interpretations    Show interpretations~n'),
    format('  explain <item-id>       Explain a generated item~n'),
    format('  validate                Validate loaded evidence~n'),
    format('  export <format> <path>  Export result (prolog/cfg/json)~n'),
    format('  clear                   Clear all state~n'),
    format('  help                    Show this help~n'),
    format('  quit                    Exit the REPL~n').
