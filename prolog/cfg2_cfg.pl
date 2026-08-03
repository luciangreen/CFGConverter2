%% cfg2_cfg.pl
%% CFG generation with evidence annotations for CFG Converter 2.
%%
%% Canonical rule:
%%   cfg_rule(RuleId, LeftHandSide, RightHandSide, Annotations).

:- module(cfg2_cfg,
    [
        generate_cfg2/4,
        cfg_rule_id/2,
        cfg_rule_lhs/2,
        cfg_rule_rhs/2,
        cfg_rule_annotations/2,
        cfg_to_text/2,
        cfg_rule_compat/2,
        merge_cfg_rules/3,
        annotated_cfg_to_plain/2
    ]).

:- use_module(library(lists)).
:- use_module(cfg2_evidence).
:- use_module(cfg2_constraints).
:- use_module(cfg2_provenance).

%% Accessors
cfg_rule_id(cfg_rule(Id,_,_,_), Id).
cfg_rule_lhs(cfg_rule(_,LHS,_,_), LHS).
cfg_rule_rhs(cfg_rule(_,_,RHS,_), RHS).
cfg_rule_annotations(cfg_rule(_,_,_,Ann), Ann).

%% cfg_rule_compat(+AnnotatedRule, -PlainRule) is det.
%  Produces the backward-compatible cfg_rule(LHS, RHS) form.
cfg_rule_compat(cfg_rule(_Id, LHS, RHS, _Ann), cfg_rule(LHS, RHS)).

%% annotated_cfg_to_plain(+AnnotatedRules, -PlainRules) is det.
annotated_cfg_to_plain(Ann, Plain) :-
    maplist(cfg_rule_compat, Ann, Plain).

%% generate_cfg2(+Name, +IR, +EvidenceDB, -CFGRules) is det.
generate_cfg2(Name, IR, EvidenceDB, CFGRules) :-
    ir_to_cfg_rules(Name, IR, EvidenceDB, RulesRaw),
    remove_duplicate_rules(RulesRaw, Rules),
    index_rules(Rules, 1, CFGRules).

ir_to_cfg_rules(Name, IR, EvidenceDB, Rules) :-
    IR = cfg2_ir(_, _, Concepts, Relations, _Ops, Evidence, Indicators,
                 Constraints, _Interps, _Sources),
    concept_rules(Name, Concepts, EvidenceDB, ConceptRules),
    relation_rules(Name, Relations, EvidenceDB, RelRules),
    evidence_rules(Name, Evidence, Constraints, EvidenceDB, EvRules),
    append([ConceptRules, RelRules, EvRules], Rules).

concept_rules(Name, Concepts, EvidenceDB, Rules) :-
    maplist(concept_to_cfg_rule(Name, EvidenceDB), Concepts, Rules).

concept_to_cfg_rule(Name, _EvidenceDB,
                    concept(Id, Category, Subconcepts, _, _),
                    cfg_rule(RId, Category, Subconcepts,
                             [derived_from([Id]), project(Name)])) :-
    atom_concat(r_, Id, RId).

relation_rules(Name, Relations, EvidenceDB, Rules) :-
    maplist(relation_to_cfg_rule(Name, EvidenceDB), Relations, Rules).

relation_to_cfg_rule(Name, _EvidenceDB,
                     relation(Id, sequence, Parts, _, _),
                     cfg_rule(RId, sequence, Parts,
                              [derived_from([Id]), project(Name)])) :-
    atom_concat(r_, Id, RId).
relation_to_cfg_rule(Name, _EvidenceDB,
                     relation(Id, alternative, Parts, _, _),
                     cfg_rule(RId, alternative, Parts,
                              [derived_from([Id]), project(Name)])) :-
    atom_concat(r_, Id, RId).
relation_to_cfg_rule(Name, _EvidenceDB,
                     relation(Id, Rel, Parts, _, _),
                     cfg_rule(RId, Rel, Parts,
                              [derived_from([Id]), project(Name)])) :-
    atom_concat(r_, Id, RId).

evidence_rules(Name, Evidences, Constraints, _EvidenceDB, Rules) :-
    maplist(evidence_to_cfg_rule(Name, Constraints), Evidences, Rules).

evidence_to_cfg_rule(Name, Constraints,
                     evidence(EId, Dept, _Type, Subject, Value, _Unit, _Ctx,
                              Conf, _Prov, _Time, _Loc, _Meta),
                     cfg_rule(RId, Subject, [Value],
                              [requires(EId),
                               confidence_policy(Conf),
                               department(Dept),
                               derived_from([EId])])) :-
    atom_concat(r_, EId, RId).

remove_duplicate_rules(Rules, Unique) :-
    sort(Rules, Unique).

index_rules([], _, []).
index_rules([rule_placeholder|Rest], N, Rules) :-
    N1 is N + 1,
    index_rules(Rest, N1, Rules).
index_rules([cfg_rule(_Id, LHS, RHS, Ann)|Rest], N,
            [cfg_rule(RId, LHS, RHS, Ann)|Rules]) :-
    format(atom(RId), 'r~w', [N]),
    N1 is N + 1,
    index_rules(Rest, N1, Rules).

%% merge_cfg_rules(+Rules1, +Rules2, -Merged) is det.
%  Merges two rule sets, combining annotations for rules with same LHS/RHS.
merge_cfg_rules(R1, R2, Merged) :-
    append(R1, R2, All),
    sort(All, Merged).

%% cfg_to_text(+CFGRules, -Text) is det.
%  Converts CFG rules to BNF-style text.
cfg_to_text([], '').
cfg_to_text(Rules, Text) :-
    maplist(cfg_rule_to_text_line, Rules, Lines),
    atomic_list_concat(Lines, '\n', Text).

cfg_rule_to_text_line(cfg_rule(_Id, LHS, RHS, _Ann), Line) :-
    rhs_to_text(RHS, RHSText),
    format(atom(Line), '<~w> ::= ~w', [LHS, RHSText]).
cfg_rule_to_text_line(cfg_rule(LHS, RHS), Line) :-
    rhs_to_text(RHS, RHSText),
    format(atom(Line), '<~w> ::= ~w', [LHS, RHSText]).

rhs_to_text([], '').
rhs_to_text(Items, Text) :-
    is_list(Items),
    maplist(rhs_item_to_text, Items, Texts),
    atomic_list_concat(Texts, ' ', Text).
rhs_to_text(Item, Text) :-
    atom(Item),
    format(atom(Text), '<~w>', [Item]).

rhs_item_to_text(terminal(T), T) :- !.
rhs_item_to_text(A, Text) :- atom(A), format(atom(Text), '<~w>', [A]).
rhs_item_to_text(T, Text) :- term_to_atom(T, Text).

%% Internal IR accessors (cfg2_ir compatible).
:- use_module(library(option)).
