%% ideacfg_dcg.pl
%% DCG compiler: converts IR productions to Prolog DCG clauses.
:- module(ideacfg_dcg,
    [
        generate_dcg/3,
        dcg_to_prolog_text/2,
        compile_dcg_module/3,
        dcg_clause/3
    ]).

:- use_module(ideacfg_ir).
:- use_module(ideacfg_cfg).
:- use_module(ideacfg_diagnostics).
:- use_module(library(lists)).

%% generate_dcg(+IdeaName, +IR, -DCGClauses) is det.
%  Generates DCG clause terms from the IR.
generate_dcg(IdeaName, IR, DCGClauses) :-
    must_be(atom, IdeaName),
    generate_cfg(IdeaName, IR, CFG),
    maplist(cfg_to_dcg_clause, CFG, DCGClauses).

%% cfg_to_dcg_clause(+CFGRule, -DCGClause) is det.
%  Converts a cfg_rule to a dcg_clause term.
cfg_to_dcg_clause(cfg_rule(Lhs, []), dcg_clause(Lhs, [], [])).
cfg_to_dcg_clause(cfg_rule(Lhs, Rhs), dcg_clause(Lhs, DCGBody, [])) :-
    maplist(sym_to_dcg, Rhs, DCGBody).

sym_to_dcg(terminal(T), terminal(T)) :- !.
sym_to_dcg([], epsilon) :- !.
sym_to_dcg(Sym, nonterminal(Sym)).

%% dcg_to_prolog_text(+DCGClauses, -Text) is det.
%  Renders DCG clauses as Prolog source text.
dcg_to_prolog_text(DCGClauses, Text) :-
    maplist(dcg_clause_to_text, DCGClauses, Lines),
    atomic_list_concat(Lines, '\n', Text).

dcg_clause_to_text(dcg_clause(Lhs, [], []), Text) :-
    format(atom(Text), '~w(epsilon) --> [].', [Lhs]).
dcg_clause_to_text(dcg_clause(Lhs, Body, ExtraGoals), Text) :-
    maplist(dcg_sym_to_text, Body, BodyParts),
    atomic_list_concat(BodyParts, ',\n    ', BodyText),
    (   ExtraGoals = []
    ->  format(atom(Text), '~w(tree(~w, Children)) -->\n    ~w.\n% Children = Body', [Lhs, Lhs, BodyText])
    ;   maplist([G, GT]>>(format(atom(GT), '    { ~w }', [G])), ExtraGoals, GoalTexts),
        atomic_list_concat(GoalTexts, ',\n', GoalsText),
        format(atom(Text), '~w(tree(~w, Children)) -->\n    ~w,\n~w.', [Lhs, Lhs, BodyText, GoalsText])
    ).

dcg_sym_to_text(terminal(T), Text) :- format(atom(Text), '[~w]', [T]).
dcg_sym_to_text(epsilon, Text) :- Text = '[/* epsilon */]'.
dcg_sym_to_text(nonterminal(N), Text) :- format(atom(Text), '~w(_)', [N]).

%% compile_dcg_module(+IdeaName, +DCGClauses, -ModuleText) is det.
%  Generates a complete Prolog module with DCG rules.
compile_dcg_module(IdeaName, DCGClauses, ModuleText) :-
    must_be(atom, IdeaName),
    format(atom(ModuleName), 'idea_~w', [IdeaName]),
    findall(Lhs/2, (member(dcg_clause(Lhs, _, _), DCGClauses),
                    \+ memberchk(Lhs/2, [])), Exports0),
    sort(Exports0, Exports),
    maplist([E, Line]>>(format(atom(Line), '        ~w', [E])), Exports, ExportLines),
    atomic_list_concat(ExportLines, ',\n', ExportText),
    dcg_to_prolog_text(DCGClauses, RulesText),
    format(atom(ModuleText),
        ':- module(~w,\n    [\n~w\n    ]).\n\n~w\n',
        [ModuleName, ExportText, RulesText]).

%% dcg_clause(?Head, ?Body, ?Goals) is det.
%  Constructor type for dcg_clause terms.
dcg_clause(Head, Body, Goals) :-
    atom(Head), is_list(Body), is_list(Goals).
