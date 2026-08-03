%% ideacfg_validate.pl
%% Validation for generated grammars and operations.
:- module(ideacfg_validate,
    [
        validate_grammar/2,
        validate_operations/2,
        validate_interfaces/3,
        validate_generated_code/2,
        validate_idea/3
    ]).

:- use_module(ideacfg_cfg).
:- use_module(ideacfg_ir).
:- use_module(ideacfg_diagnostics).
:- use_module(library(lists)).

%% validate_grammar(+CFG, -Diagnostics) is det.
%  Comprehensive grammar validation.
validate_grammar(CFG, Diagnostics) :-
    must_be(list, CFG),
    findall(D,
            (   grammar_check(CFG, D)
            ),
            Diagnostics).

grammar_check(CFG, D) :-
    member(cfg_rule(Lhs, Rhs), CFG),
    member(Sym, Rhs),
    atom(Sym),
    Sym \= epsilon,
    \+ memberchk(terminal(Sym), Rhs),
    \+ member(cfg_rule(Sym, _), CFG),
    format(atom(Msg), 'Undefined nonterminal ~w in rule for ~w', [Sym, Lhs]),
    D = diagnostic(warning, undefined_nonterminal, Msg, rule(Lhs), [Sym],
                   'Add a production or mark as terminal').
grammar_check(CFG, D) :-
    member(cfg_rule(Lhs, Rhs), CFG),
    left_recursive_rule(Lhs, Rhs),
    format(atom(Msg), 'Direct left recursion in rule for ~w', [Lhs]),
    D = diagnostic(warning, left_recursion, Msg, rule(Lhs), [Lhs],
                   'Apply left_recursion_elimination trick').
grammar_check(CFG, D) :-
    findall(Lhs, member(cfg_rule(Lhs, _), CFG), AllLhs),
    sort(AllLhs, UniqLhs),
    member(Sym, UniqLhs),
    \+ reachable(Sym, CFG),
    format(atom(Msg), 'Unreachable nonterminal ~w', [Sym]),
    D = diagnostic(info, unreachable, Msg, rule(Sym), [], 'Remove or reference this rule').
grammar_check(CFG, D) :-
    findall(cfg_rule(L, R), member(cfg_rule(L, R), CFG), Rules),
    msort(Rules, Sorted),
    nth1(I, Sorted, R),
    nth1(J, Sorted, R),
    I < J,
    format(atom(Msg), 'Duplicate production: ~w', [R]),
    D = diagnostic(info, duplicate_rule, Msg, unknown, [], 'Remove duplicate').

left_recursive_rule(Lhs, [Lhs|_]).

reachable(Sym, CFG) :-
    member(cfg_rule(_, Rhs), CFG),
    memberchk(Sym, Rhs), !.

%% validate_operations(+Operations, -Diagnostics) is det.
validate_operations(Ops, Diagnostics) :-
    must_be(list, Ops),
    findall(D, (member(Op, Ops), op_check(Op, D)), Diagnostics).

op_check(operation(_, _, Inputs, _, _, _, Src), D) :-
    member(Input, Inputs),
    var(Input),
    D = diagnostic(error, undefined_input, 'Undefined input variable', Src, [],
                   'Bind all input variables').
op_check(operation(_, arithmetic, _, _, _, _, Src), D) :-
    D = diagnostic(info, arithmetic_direct, 'Arithmetic operation will be compiled to direct Prolog',
                   Src, [], 'Review generated predicate').

%% validate_interfaces(+Operations, +CFG, -Diagnostics) is det.
validate_interfaces(_Ops, _CFG, []).

%% validate_generated_code(+ModuleText, -Diagnostics) is det.
validate_generated_code(ModuleText, Diagnostics) :-
    atom(ModuleText),
    (   atom_length(ModuleText, 0)
    ->  Diagnostics = [diagnostic(error, empty_module, 'Generated module is empty',
                                  unknown, [], 'Check generation pipeline')]
    ;   Diagnostics = []
    ).

%% validate_idea(+IdeaName, +IR, -Report) is det.
validate_idea(IdeaName, IR, Report) :-
    must_be(atom, IdeaName),
    generate_cfg(IdeaName, IR, CFG),
    validate_grammar(CFG, GramDiags),
    ir_operations(IR, Ops),
    validate_operations(Ops, OpDiags),
    append(GramDiags, OpDiags, Diagnostics),
    Report = validation_report(IdeaName, Diagnostics).
