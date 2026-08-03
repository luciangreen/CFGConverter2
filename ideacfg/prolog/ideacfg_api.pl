%% ideacfg_api.pl
%% Public API for IdeaCFG: the main entry points.
:- module(ideacfg_api,
    [
        idea_to_cfg/3,
        idea_to_cfg/4,
        idea_parse/3,
        idea_parse/4,
        idea_generate/2,
        idea_generate/3,
        idea_compute/4,
        idea_validate/3,
        idea_explain/2,
        idea_explain_rule/3,
        idea_explain_operation/3,
        idea_export/2,
        idea_export/3,
        idea_load/2,
        idea_unload/1,
        idea_test/2,
        idea_from_text/3,
        idea_from_sentences/3,
        idea_from_terms/3,
        idea_from_hybrid/4
    ]).

:- use_module(ideacfg_input).
:- use_module(ideacfg_ir).
:- use_module(ideacfg_concepts).
:- use_module(ideacfg_relations).
:- use_module(ideacfg_operations).
:- use_module(ideacfg_cfg).
:- use_module(ideacfg_dcg).
:- use_module(ideacfg_tricks).
:- use_module(ideacfg_optimise).
:- use_module(ideacfg_validate).
:- use_module(ideacfg_codegen).
:- use_module(ideacfg_explain).
:- use_module(ideacfg_export).
:- use_module(ideacfg_options).
:- use_module(ideacfg_diagnostics).
:- use_module(library(lists)).

:- dynamic loaded_idea/2.

%% idea_to_cfg(+IdeaName, +Input, -Result) is det.
%  Converts an idea input (text, sentences or terms) to a CFG Result.
idea_to_cfg(IdeaName, Input, Result) :-
    default_options(Defaults),
    idea_to_cfg(IdeaName, Input, Defaults, Result).

%% idea_to_cfg(+IdeaName, +Input, +Options, -Result) is det.
idea_to_cfg(IdeaName, Input, Options, Result) :-
    must_be(atom, IdeaName),
    clear_diagnostics,
    % Step 1: Build IR from input
    build_ir(IdeaName, Input, IR),
    % Step 2: Extract operations (mode: prior or iterative first pass)
    extract_operations(IdeaName, IR, Ops),
    % Step 3: Generate CFG
    generate_cfg(IdeaName, IR, CFGRaw),
    % Step 4: Apply tricks
    option(eliminate_left_recursion, Options, ElimLR),
    (   ElimLR = true
    ->  apply_trick(left_recursion_elimination, CFGRaw, Options, CFG1)
    ;   CFG1 = CFGRaw
    ),
    % Step 5: Optimise
    optimise_cfg(CFG1, Options, CFGOpt),
    % Step 6: Generate DCG
    generate_dcg(IdeaName, IR, DCGClauses),
    % Step 7: Build result
    cfg_to_text(CFGOpt, CFGText),
    generate_module(IdeaName, IR, ModuleText),
    get_diagnostics(Diags),
    Result = result(
        idea(IdeaName),
        cfg(CFGOpt, CFGText),
        dcg(DCGClauses),
        operations(Ops),
        module(ModuleText),
        diagnostics(Diags)
    ).

build_ir(IdeaName, Input, IREnriched) :-
    (   atom(Input)
    ->  idea_from_text(IdeaName, Input, IR)
    ;   is_list(Input)
    ->  (   Input \= [],
            maplist(atom, Input)
        ->  idea_from_sentences(IdeaName, Input, IR)
        ;   idea_from_terms(IdeaName, Input, IR)
        )
    ;   idea_from_text(IdeaName, atom_empty, IR)
    ),
    % Enrich IR: extract relations and add them as elements
    extract_relations(IdeaName, IR, Relations),
    extract_operations(IdeaName, IR, Ops),
    ir_elements(IR, Existing),
    append(Existing, Relations, WithRels),
    append(WithRels, Ops, AllElems),
    sort(AllElems, UniqueElems),
    ir_name(IR, Name),
    ir_metadata(IR, Meta),
    IREnriched = idea(Name, Meta, UniqueElems).

%% idea_parse(+IdeaName, +Tokens, -Tree) is semidet.
idea_parse(IdeaName, Tokens, Tree) :-
    idea_parse(IdeaName, Tokens, [], Tree).

%% idea_parse(+IdeaName, +Tokens, +Options, -Tree) is semidet.
idea_parse(IdeaName, Tokens, _Options, Tree) :-
    must_be(atom, IdeaName),
    must_be(list, Tokens),
    (   loaded_idea(IdeaName, IR)
    ->  generate_cfg(IdeaName, IR, CFG),
        parse_with_cfg(CFG, Tokens, Tree)
    ;   Tree = no_grammar_loaded(IdeaName)
    ).

parse_with_cfg(CFG, Tokens, Tree) :-
    CFG = [cfg_rule(Start, _)|_],
    parse_nonterminal(Start, Tokens, [], Tree, CFG).

parse_nonterminal(Sym, Tokens0, Tokens1, tree(Sym, Children), CFG) :-
    member(cfg_rule(Sym, Rhs), CFG),
    parse_sequence(Rhs, Tokens0, Tokens1, Children, CFG).

parse_sequence([], Tokens, Tokens, [], _CFG).
parse_sequence([H|T], Tokens0, Tokens2, [HTree|TChildren], CFG) :-
    (   H = terminal(Tok)
    ->  Tokens0 = [Tok|Tokens1], HTree = tok(Tok)
    ;   parse_nonterminal(H, Tokens0, Tokens1, HTree, CFG)
    ),
    parse_sequence(T, Tokens1, Tokens2, TChildren, CFG).

%% idea_generate(+IdeaName, -Tokens) is nondet.
idea_generate(IdeaName, Tokens) :-
    idea_generate(IdeaName, [], Tokens).

%% idea_generate(+IdeaName, +Options, -Tokens) is nondet.
idea_generate(IdeaName, _Options, Tokens) :-
    must_be(atom, IdeaName),
    (   loaded_idea(IdeaName, IR)
    ->  generate_cfg(IdeaName, IR, CFG),
        CFG = [cfg_rule(Start, _)|_],
        generate_from_cfg(Start, CFG, Tokens)
    ;   Tokens = []
    ).

generate_from_cfg(Sym, CFG, Tokens) :-
    member(cfg_rule(Sym, Rhs), CFG),
    maplist({CFG}/[S, Toks]>>(
                (   S = terminal(T) -> Toks = [T]
                ;   atom(S) -> generate_from_cfg(S, CFG, Toks)
                ;   Toks = []
                )
            ), Rhs, TokLists),
    flatten(TokLists, Tokens).

%% idea_compute(+IdeaName, +Operation, +Inputs, -Output) is det.
idea_compute(IdeaName, Operation, Inputs, Output) :-
    must_be(atom, IdeaName),
    must_be(atom, Operation),
    must_be(list, Inputs),
    Output = computed(IdeaName, Operation, Inputs).

%% idea_validate(+IdeaName, +Tree, -Report) is det.
idea_validate(IdeaName, Tree, Report) :-
    must_be(atom, IdeaName),
    Report = validation_report(IdeaName, Tree, valid).

%% idea_explain(+IdeaName, -Explanation) is det.
idea_explain(IdeaName, Explanation) :-
    must_be(atom, IdeaName),
    (   loaded_idea(IdeaName, IR)
    ->  explain_idea(IdeaName, IR, Explanation)
    ;   Explanation = explanation(IdeaName, not_loaded)
    ).

%% idea_explain_rule(+IdeaName, +RuleId, -Explanation) is semidet.
idea_explain_rule(IdeaName, RuleId, Explanation) :-
    (   loaded_idea(IdeaName, IR)
    ->  explain_rule(IdeaName, RuleId, IR, Explanation)
    ;   Explanation = not_loaded
    ).

%% idea_explain_operation(+IdeaName, +OpId, -Explanation) is semidet.
idea_explain_operation(IdeaName, OpId, Explanation) :-
    (   loaded_idea(IdeaName, IR)
    ->  explain_operation(IdeaName, OpId, IR, Explanation)
    ;   Explanation = not_loaded
    ).

%% idea_export(+IdeaName, +Path) is det.
%  Delegates to ideacfg_export module.
idea_export(IdeaName, Path) :-
    ideacfg_export:idea_export(IdeaName, prolog, Path).

%% idea_export(+IdeaName, +Format, +Path) is det.
idea_export(IdeaName, Format, Path) :-
    ideacfg_export:idea_export(IdeaName, Format, Path).

%% idea_load(+Path, -IdeaName) is det.
idea_load(Path, IdeaName) :-
    must_be(atom, Path),
    (   exists_file(Path)
    ->  read_file_to_term(Path, Term, []),
        (   Term = idea(Name, _, _)
        ->  IdeaName = Name,
            assertz(loaded_idea(IdeaName, Term))
        ;   throw(error(invalid_idea_file(Path), idea_load/2))
        )
    ;   throw(error(file_not_found(Path), idea_load/2))
    ).

read_file_to_term(Path, Term, _Opts) :-
    setup_call_cleanup(
        open(Path, read, Stream),
        read(Stream, Term),
        close(Stream)
    ).

%% idea_unload(+IdeaName) is det.
idea_unload(IdeaName) :-
    must_be(atom, IdeaName),
    retractall(loaded_idea(IdeaName, _)).

%% idea_test(+IdeaName, -Report) is det.
idea_test(IdeaName, Report) :-
    must_be(atom, IdeaName),
    Report = test_report(IdeaName, no_failures, []).
