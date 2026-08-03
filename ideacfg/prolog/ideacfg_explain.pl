%% ideacfg_explain.pl
%% Explanation and traceability for IdeaCFG.
:- module(ideacfg_explain,
    [
        explain_idea/3,
        explain_rule/4,
        explain_operation/4,
        generate_report/3,
        review_checklist/2,
        accept_rule/3,
        reject_rule/3,
        replace_rule/4
    ]).

:- use_module(ideacfg_ir).
:- use_module(ideacfg_cfg).
:- use_module(ideacfg_diagnostics).
:- use_module(library(lists)).

%% explain_idea(+IdeaName, +IR, -Explanation) is det.
%  Produces a structured explanation of an idea's model.
explain_idea(IdeaName, IR, Explanation) :-
    must_be(atom, IdeaName),
    ir_concepts(IR, Concepts),
    ir_operations(IR, Ops),
    ir_relations(IR, Relations),
    ir_assumptions(IR, Assumptions),
    ir_ambiguities(IR, Ambiguities),
    generate_cfg(IdeaName, IR, CFG),
    length(CFG, NumRules),
    length(Concepts, NumConcepts),
    length(Ops, NumOps),
    Explanation = explanation(
        idea_name(IdeaName),
        concepts(NumConcepts, Concepts),
        operations(NumOps, Ops),
        relations(Relations),
        grammar_rules(NumRules, CFG),
        assumptions(Assumptions),
        ambiguities(Ambiguities)
    ).

%% explain_rule(+IdeaName, +RuleId, +IR, -Explanation) is semidet.
explain_rule(IdeaName, RuleId, _IR, Explanation) :-
    must_be(atom, IdeaName),
    must_be(atom, RuleId),
    Explanation = rule_explanation(RuleId, IdeaName, 'Rule derived from source analysis').

%% explain_operation(+IdeaName, +OpId, +IR, -Explanation) is semidet.
explain_operation(IdeaName, OpId, _IR, Explanation) :-
    must_be(atom, IdeaName),
    must_be(atom, OpId),
    Explanation = operation_explanation(OpId, IdeaName, 'Operation extracted from source text').

%% generate_report(+IdeaName, +IR, -Report) is det.
%  Generates a Markdown report for an idea.
generate_report(IdeaName, IR, Report) :-
    explain_idea(IdeaName, IR, Explanation),
    Explanation = explanation(
        idea_name(_),
        concepts(NC, _),
        operations(NO, Ops),
        relations(Rels),
        grammar_rules(NR, CFG),
        assumptions(_),
        ambiguities(Ambs)
    ),
    cfg_to_text(CFG, CFGText),
    length(Rels, NRel),
    length(Ambs, NAmb),
    (   Ops = []
    ->  OpLines = ['- No operations extracted']
    ;   maplist([operation(Id, Class, _, _, Mode, _, _), Line]>>(
                    format(atom(Line), '- `~w` (~w, ~w)', [Id, Class, Mode])
                ), Ops, OpLines)
    ),
    atomic_list_concat(OpLines, '\n', OpsText),
    format(atom(Report),
'# IdeaCFG Report: ~w\n\n## Summary\n- Concepts: ~w\n- Operations: ~w\n- Relations: ~w\n- Grammar rules: ~w\n- Ambiguities: ~w\n\n## Grammar\n\n```\n~w\n```\n\n## Operations\n\n~w\n',
[IdeaName, NC, NO, NRel, NR, NAmb, CFGText, OpsText]).

%% review_checklist(+IdeaName, -Checklist) is det.
%  Produces a review checklist for human review.
review_checklist(IdeaName, Checklist) :-
    format(atom(Checklist),
'## Review Checklist for ~w\n\n[ ] Are the main concepts correctly identified?\n[ ] Are alternatives genuinely alternatives?\n[ ] Are sequences in the correct order?\n[ ] Are optional components truly optional?\n[ ] Are mathematical operations extracted correctly?\n[ ] Are units explicit?\n[ ] Are recursion bounds acceptable?\n[ ] Are approximations clearly stated?\n[ ] Are semantic constraints sufficient?\n[ ] Do generated examples make sense?\n',
    [IdeaName]).

%% accept_rule(+IdeaName, +RuleId, +IR) is det.
%  Marks a rule as accepted (no-op in this implementation).
accept_rule(_IdeaName, _RuleId, _IR).

%% reject_rule(+IdeaName, +RuleId, +IR) is det.
%  Marks a rule as rejected (no-op stub).
reject_rule(_IdeaName, _RuleId, _IR).

%% replace_rule(+IdeaName, +RuleId, +Replacement, +IR) is det.
%  Replaces a rule (stub).
replace_rule(_IdeaName, _RuleId, _Replacement, _IR).
