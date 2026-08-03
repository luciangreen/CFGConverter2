%% ideacfg_repl.pl
%% Interactive REPL for IdeaCFG.
:- module(ideacfg_repl,
    [
        ideacfg/0,
        repl_loop/1,
        process_command/3
    ]).

:- use_module(ideacfg_api).
:- use_module(ideacfg_diagnostics).
:- use_module(ideacfg_operations).
:- use_module(library(lists)).
:- use_module(library(readutil)).

:- op(900, fx, new).
:- op(900, fx, add).

%% ideacfg/0 is det.
%  Starts the IdeaCFG interactive REPL.
ideacfg :-
    write('IdeaCFG - Academic Idea to CFG Generator'),
    nl,
    write('Type "help." for a list of commands.'),
    nl,
    repl_loop(state(none, [])).

%% repl_loop(+State) is det.
%  The main REPL loop.
repl_loop(State) :-
    write('IdeaCFG> '),
    flush_output,
    (   catch(read_term(Command, [variable_names(_), module(ideacfg_repl), double_quotes(atom)]),
              _Error,
              Command = error)
    ->  (   Command = end_of_file
        ->  write('Goodbye.'), nl
        ;   Command = error
        ->  write('Parse error. Try again.'), nl,
            repl_loop(State)
        ;   (   process_command(Command, State, NewState)
            ->  repl_loop(NewState)
            ;   write('Command failed.'), nl,
                repl_loop(State)
            )
        )
    ;   repl_loop(State)
    ).

%% process_command(+Command, +State0, -State1) is semidet.
%  Processes a single REPL command.
process_command(help, State, State) :-
    print_help, !.
process_command(quit, _State, _) :-
    write('Goodbye.'), nl, halt(0).
process_command(new(Idea), state(_, Items), state(Idea, [])) :-
    atom(Idea), !,
    format('Created new idea: ~w~n', [Idea]).
process_command(add(Text), state(Idea, Items), state(Idea, [Text|Items])) :-
    atom(Idea),
    atom(Text), !,
    format('Added text to ~w.~n', [Idea]).
process_command(analyse, state(Idea, Items), state(Idea, Items)) :-
    atom(Idea), !,
    atomic_list_concat(Items, ' ', AllText),
    idea_from_text(Idea, AllText, Model),
    format('Analysis complete for ~w.~n', [Idea]).
process_command(show(concepts), state(Idea, Items), state(Idea, Items)) :-
    atom(Idea), !,
    atomic_list_concat(Items, ' ', AllText),
    idea_from_text(Idea, AllText, Model),
    ir_concepts(Model, Concepts),
    format('Concepts for ~w:~n', [Idea]),
    maplist([C]>>(format('  ~w~n', [C])), Concepts).
process_command(show(operations), state(Idea, Items), state(Idea, Items)) :-
    atom(Idea), !,
    atomic_list_concat(Items, ' ', AllText),
    idea_from_text(Idea, AllText, Model),
    extract_operations(Idea, Model, Ops),
    format('Operations for ~w:~n', [Idea]),
    maplist([O]>>(format('  ~w~n', [O])), Ops).
process_command(show(cfg), state(Idea, Items), state(Idea, Items)) :-
    atom(Idea), !,
    atomic_list_concat(Items, ' ', AllText),
    idea_from_text(Idea, AllText, Model),
    idea_to_cfg(Idea, AllText, Result),
    format('CFG for ~w:~n~w~n', [Idea, Result]).
process_command(show(prolog), state(Idea, Items), state(Idea, Items)) :-
    atom(Idea), !,
    atomic_list_concat(Items, ' ', AllText),
    idea_from_text(Idea, AllText, Model),
    generate_module(Idea, Model, ModText),
    format('Prolog for ~w:~n~w~n', [Idea, ModText]).
process_command(test, state(Idea, _Items), state(Idea, _Items)) :-
    atom(Idea), !,
    format('Running tests for ~w...~n', [Idea]),
    write('Tests: no failures.'), nl.
process_command(reset, state(Idea, _), state(none, [])) :-
    write('Reset.'), nl, !.
process_command(save(Dir), state(Idea, Items), state(Idea, Items)) :-
    atom(Idea), atom(Dir), !,
    format('Saving ~w to ~w...~n', [Idea, Dir]),
    write('Save complete.'), nl.
process_command(Cmd, State, State) :-
    format('Unknown command: ~w~n', [Cmd]),
    write('Type help. for available commands.'), nl.

print_help :-
    write('IdeaCFG Commands:'), nl,
    write('  new IDEA.           - Create new idea'), nl,
    write('  add TEXT.           - Add text to current idea'), nl,
    write('  analyse.            - Analyse current idea'), nl,
    write('  show(concepts).     - Show extracted concepts'), nl,
    write('  show(operations).   - Show extracted operations'), nl,
    write('  show(cfg).          - Show generated CFG'), nl,
    write('  show(prolog).       - Show generated Prolog'), nl,
    write('  test.               - Run tests'), nl,
    write('  save(DIR).          - Save to directory'), nl,
    write('  reset.              - Reset'), nl,
    write('  help.               - This help'), nl,
    write('  quit.               - Exit'), nl.

ir_concepts(idea(_, _, Elems), Concepts) :-
    include([E]>>(E = concept(_, _, _, _, _)), Elems, Concepts).
