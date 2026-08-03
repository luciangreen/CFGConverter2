%% cfg2_explain.pl
%% Derivation explanation and evidence-use queries for CFG Converter 2.

:- module(cfg2_explain,
    [
        explain_derivation/3,
        explain_evidence_use/3,
        explain_rule/4,
        explain_interpretation/3,
        provenance_summary/2
    ]).

:- use_module(library(lists)).
:- use_module(cfg2_evidence).
:- use_module(cfg2_provenance).

%% explain_derivation(+ItemId, +Result, -Explanation) is det.
%  Generates a human-readable explanation for a generated item.
explain_derivation(ItemId, Result, Explanation) :-
    (   Result = result(_, _, _, _, evidence(EvidList), ir(_IR),
                        cfg(CFGRules, _), dcg(DCGClauses), _, _,
                        interpretations(Interps), _, _, _)
    ->  find_cfg_rule(ItemId, CFGRules, RuleInfo),
        find_dcg_clause(ItemId, DCGClauses, DCGInfo),
        find_evidence_for(ItemId, EvidList, UsedEvidence),
        Explanation = explanation(
            item(ItemId),
            rule(RuleInfo),
            dcg(DCGInfo),
            evidence(UsedEvidence),
            narrative(narrative_for(ItemId, RuleInfo, UsedEvidence))
        )
    ;   Explanation = explanation(ItemId, no_result_context)
    ).

find_cfg_rule(ItemId, Rules, rule_found(R)) :-
    member(R, Rules),
    (   R = cfg_rule(ItemId, _, _, _)
    ;   R = cfg_rule(LHS, _), atom_concat(r_, ItemId, LHS)
    ), !.
find_cfg_rule(ItemId, _, rule_not_found(ItemId)).

find_dcg_clause(ItemId, Clauses, dcg_found(C)) :-
    member(C, Clauses),
    dcg_clause_head(C, head(ItemId, _)), !.
find_dcg_clause(ItemId, _, dcg_not_found(ItemId)).

find_evidence_for(ItemId, EvidList, Used) :-
    include([E]>>(cfg2_evidence:evidence_id(E, Id), Id == ItemId), EvidList, Used).

%% explain_evidence_use(+EvidenceId, +Result, -Uses) is det.
%  Identifies every grammar rule, DCG clause, and interpretation that used EvidenceId.
explain_evidence_use(EvidenceId, Result, Uses) :-
    (   Result = result(_, _, _, _, _, _,
                        cfg(CFGRules, _), dcg(DCGClauses), _, _,
                        interpretations(Interps), _, _, _)
    ->  include(cfg_uses_evidence(EvidenceId), CFGRules, UsedCFG),
        include(dcg_uses_evidence(EvidenceId), DCGClauses, UsedDCG),
        include(interp_uses_evidence(EvidenceId), Interps, UsedInterps),
        Uses = evidence_uses(
            evidence_id(EvidenceId),
            cfg_rules(UsedCFG),
            dcg_clauses(UsedDCG),
            interpretations(UsedInterps)
        )
    ;   Uses = evidence_uses(EvidenceId, no_result_context)
    ).

cfg_uses_evidence(EId, cfg_rule(_,_,_,Ann)) :-
    member(requires(EId), Ann).
cfg_uses_evidence(EId, cfg_rule(_,_,_,Ann)) :-
    member(derived_from(Ids), Ann), member(EId, Ids).

dcg_uses_evidence(EId, dcg_clause(_, body(_, Constrs, sources(Srcs)))) :-
    member(EId, Srcs).
dcg_uses_evidence(EId, dcg_clause(_, body(_, Constrs, _))) :-
    member(cfg2_evidence_valid(EId), Constrs).

interp_uses_evidence(EId, interpretation(_, _, evidence(Evids), _, _)) :-
    member(EId, Evids).

%% explain_rule(+RuleId, +IR, +EvidenceDB, -Explanation) is det.
explain_rule(RuleId, IR, EvidenceDB, Explanation) :-
    IR = cfg2_ir(_, _, _, _, _, Evidence, _, Constraints, _, _),
    include([E]>>(cfg2_evidence:evidence_id(E, EId), EId == RuleId),
            Evidence, DirectEvidence),
    include([C]>>(cfg2_constraints:constraint_id(C, CId), CId == RuleId),
            Constraints, DirectConstraints),
    Explanation = rule_explanation(
        rule(RuleId),
        direct_evidence(DirectEvidence),
        constraints(DirectConstraints)
    ).

%% explain_interpretation(+Interpretation, +EvidenceDB, -Explanation) is det.
explain_interpretation(Interp, EvidenceDB, Explanation) :-
    cfg2_semantics:interpretation_conclusion(Interp, Conc),
    cfg2_semantics:interpretation_confidence(Interp, Conf),
    cfg2_semantics:interpretation_evidence(Interp, EvidIds),
    include([E]>>(cfg2_evidence:evidence_id(E, Id), member(Id, EvidIds)),
            EvidenceDB, UsedEvidence),
    Explanation = interpretation_explanation(
        conclusion(Conc),
        confidence(Conf),
        evidence_count(length(EvidIds)),
        evidence_details(UsedEvidence)
    ).

%% provenance_summary(+Result, -Summary) is det.
provenance_summary(Result, Summary) :-
    (   Result = result(project(Name), department(Dept), _, sources(Srcs),
                        evidence(Evids), _, cfg(CFGRules, _),
                        dcg(DCGClauses), _, _, _, _, _, _)
    ->  length(Evids, NEv),
        length(CFGRules, NCfg),
        length(DCGClauses, NDcg),
        Summary = provenance_summary(
            project(Name),
            department(Dept),
            sources(Srcs),
            evidence_count(NEv),
            cfg_rules(NCfg),
            dcg_clauses(NDcg)
        )
    ;   Summary = provenance_summary(unknown)
    ).

:- use_module(cfg2_semantics).
:- use_module(cfg2_dcg, [dcg_clause_head/2]).
