%% cfg2_dcg.pl
%% Attributed DCG generation for CFG Converter 2.
%%
%% Generated DCGs carry semantic arguments:
%%   nonterminal(ParseTree, Semantics, EvidenceState) --> ...

:- module(cfg2_dcg,
    [
        generate_dcg2/4,
        dcg_clause_head/2,
        dcg_clause_body/2,
        dcg_to_prolog/2,
        evidence_guarded_branch/4
    ]).

:- use_module(library(lists)).
:- use_module(cfg2_evidence).
:- use_module(cfg2_constraints).
:- use_module(cfg2_cfg).

%% generate_dcg2(+Name, +IR, +EvidenceDB, -DCGClauses) is det.
generate_dcg2(Name, IR, EvidenceDB, DCGClauses) :-
    IR = cfg2_ir(_, _, Concepts, Relations, Ops, Evidences, Indicators,
                 Constraints, _, _),
    concept_dcg_clauses(Name, Concepts, EvidenceDB, Constraints, CClauses),
    relation_dcg_clauses(Name, Relations, EvidenceDB, RClauses),
    evidence_dcg_clauses(Name, Evidences, Constraints, EClauses),
    append([CClauses, RClauses, EClauses], DCGClauses).

concept_dcg_clauses(Name, Concepts, EvidenceDB, Constraints, Clauses) :-
    maplist(concept_to_dcg(Name, EvidenceDB, Constraints), Concepts, Clauses).

concept_to_dcg(Name, _EvidenceDB, Constraints,
               concept(Id, Category, Subconcepts, _, _),
               DCGClause) :-
    HeadFunctor = Category,
    % Collect relevant constraints
    constraints_for_rule(Id, Constraints, Constrs),
    maplist([C, Goal]>>(
        constraint_form(C, Form),
        safe_constraint_goal(Form, Goal)
    ), Constrs, ConstrGoals),
    length(Subconcepts, NAry),
    (   NAry =:= 0
    ->  DCGClause = dcg_clause(
            head(HeadFunctor, [tree(Category, []), sem([]), evstate([])]),
            body([], ConstrGoals, sources([Id]))
        )
    ;   maplist(subconcept_body_goal, Subconcepts, BodyGoals),
        DCGClause = dcg_clause(
            head(HeadFunctor, [tree(Category, Subconcepts), sem(Subconcepts), evstate([])]),
            body(BodyGoals, ConstrGoals, sources([Id]))
        )
    ).

subconcept_body_goal(terminal(T), terminal_goal(T)) :- !.
subconcept_body_goal(S, nonterminal_goal(S, [tree(S,[]),sem([]),evstate([])])).

relation_dcg_clauses(Name, Relations, EvidenceDB, Clauses) :-
    maplist(relation_to_dcg(Name, EvidenceDB), Relations, Clauses).

relation_to_dcg(Name, _EvidenceDB,
                relation(Id, sequence, Parts, _, _),
                dcg_clause(
                    head(sequence_rule, [tree(seq, Parts), sem(Parts), evstate([])]),
                    body(PartGoals, [], sources([Id]))
                )) :-
    maplist([P, nonterminal_goal(P,[tree(P,[]),sem([]),evstate([])])]>>true,
            Parts, PartGoals).
relation_to_dcg(Name, _EvidenceDB,
                relation(Id, Rel, Parts, _, _),
                dcg_clause(
                    head(Rel, [tree(Rel, Parts), sem(Parts), evstate([])]),
                    body(PartGoals, [], sources([Id]))
                )) :-
    maplist([P, nonterminal_goal(P,[tree(P,[]),sem([]),evstate([])])]>>true,
            Parts, PartGoals).

evidence_dcg_clauses(Name, Evidences, Constraints, Clauses) :-
    maplist(evidence_to_dcg(Name, Constraints), Evidences, Clauses).

evidence_to_dcg(Name, Constraints,
                evidence(EId, Dept, _Type, Subject, Value, _Unit, _Ctx,
                         Conf, _Prov, _Time, _Loc, _Meta),
                dcg_clause(
                    head(Subject, [tree(Subject, [Value]),
                                   sem(interpretation(Value, Conf)),
                                   evstate(evids([EId]))]),
                    body([],
                         [cfg2_evidence_valid(EId),
                          cfg2_evidence_measurement(EId, Subject, Value)],
                         sources([EId]))
                )).

%% dcg_clause_head(+Clause, -Head) is det.
dcg_clause_head(dcg_clause(head(F, Args), _), head(F, Args)).

%% dcg_clause_body(+Clause, -Body) is det.
dcg_clause_body(dcg_clause(_, body(Goals, Constrs, Srcs)),
                body(Goals, Constrs, Srcs)).

%% evidence_guarded_branch(+NTSymbol, +EvidenceId, +Constraints, -DCGClause) is det.
%  Generates an evidence-guarded DCG branch.
evidence_guarded_branch(Symbol, EvidenceId, Constraints, DCGClause) :-
    maplist([C, G]>>(safe_constraint_goal(C, G)), Constraints, Guards),
    DCGClause = dcg_clause(
        head(Symbol, [tree(Symbol, [EvidenceId]),
                      sem(evidence_ref(EvidenceId)),
                      evstate(evids([EvidenceId]))]),
        body([],
             [cfg2_evidence_valid(EvidenceId) | Guards],
             sources([EvidenceId]))
    ).

%% dcg_to_prolog(+DCGClauses, -PrologText) is det.
dcg_to_prolog([], '').
dcg_to_prolog(Clauses, Text) :-
    maplist(dcg_clause_to_text, Clauses, Lines),
    atomic_list_concat(Lines, '\n\n', Text).

dcg_clause_to_text(dcg_clause(head(F, Args), body(Goals, Constrs, _)), Text) :-
    args_to_text(Args, ArgsText),
    body_to_text(Goals, Constrs, BodyText),
    format(atom(Text), '~w(~w) -->\n    ~w.', [F, ArgsText, BodyText]).

args_to_text([], '').
args_to_text(Args, Text) :-
    maplist(term_to_atom, Args, AtomArgs),
    atomic_list_concat(AtomArgs, ', ', Text).

body_to_text([], [], 'true').
body_to_text(Goals, Constrs, Text) :-
    maplist(term_to_atom, Goals, GTexts),
    maplist(term_to_atom, Constrs, CTexts),
    (   GTexts = []
    ->  atomic_list_concat(CTexts, ',\n    ', CText),
        format(atom(Text), '{ ~w }', [CText])
    ;   CTexts = []
    ->  atomic_list_concat(GTexts, ',\n    ', Text)
    ;   atomic_list_concat(GTexts, ',\n    ', GText),
        atomic_list_concat(CTexts, ',\n    ', CText),
        format(atom(Text), '~w,\n    { ~w }', [GText, CText])
    ).
