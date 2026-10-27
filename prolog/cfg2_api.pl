%% cfg2_api.pl
%% Main public API for CFG Converter 2.
%%
%% This module re-exports the original idea_to_cfg/3 and idea_to_cfg/4
%% predicates (via the copied ideacfg module) and adds the new evidence-
%% aware entry points.

:- module(cfg2_api,
    [
        data_to_cfg/4,
        data_to_cfg/5,
        evidence_to_cfg/4,
        evidence_to_cfg/5,
        hybrid_to_cfg/5,
        hybrid_to_cfg/6,
        load_evidence/4,
        normalise_evidence/4,
        validate_evidence/3,
        compile_department/4,
        parse_with_evidence/5,
        generate_with_evidence/5,
        interpret_with_evidence/5,
        explain_derivation/3,
        explain_evidence_use/3,
        export_cfg2/3,
        export_cfg2/4,
        % Backward-compatible original API
        idea_to_cfg/3,
        idea_to_cfg/4
    ]).

:- use_module(library(lists)).
:- use_module(library(option)).

% New CFG2 modules
:- use_module(cfg2_evidence).
:- use_module(cfg2_sources).
:- use_module(cfg2_schema).
:- use_module(cfg2_departments).
:- use_module(cfg2_measurements).
:- use_module(cfg2_indicators).
:- use_module(cfg2_intuition).
:- use_module(cfg2_constraints).
:- use_module(cfg2_uncertainty).
:- use_module(cfg2_provenance).
:- use_module(cfg2_semantics).
:- use_module(cfg2_cfg).
:- use_module(cfg2_dcg).
:- use_module(cfg2_validate).
:- use_module(cfg2_explain).
:- use_module(cfg2_codegen).

% Original IdeaCFG API (backward compatibility)
:- use_module('../ideacfg/prolog/ideacfg_api').

%% idea_to_cfg(+IdeaName, +Input, -Result) is det.
%  Backward-compatible entry point.
idea_to_cfg(IdeaName, Input, Result) :-
    ideacfg_api:idea_to_cfg(IdeaName, Input, Result).

%% idea_to_cfg(+IdeaName, +Input, +Options, -Result) is det.
%  Backward-compatible entry point with options.
idea_to_cfg(IdeaName, Input, Options, Result) :-
    ideacfg_api:idea_to_cfg(IdeaName, Input, Options, Result).

%% ── Evidence-only entry points ──────────────────────────────────────────

%% data_to_cfg(+Name, +DataSources, +Options, -Result) is det.
data_to_cfg(Name, DataSources, Options, Result) :-
    must_be(atom, Name),
    load_all_sources(DataSources, Options, Evidence),
    (   member(department(Dept), Options) -> true ; Dept = unknown ),
    build_ir_from_evidence(Name, Evidence, Options, IR),
    generate_cfg2(Name, IR, Evidence, CFGRules),
    generate_dcg2(Name, IR, Evidence, DCGClauses),
    cfg_to_text(CFGRules, CFGText),
    generate_module2(Name, IR, Evidence, ModuleText),
    validate_evidence_list(Evidence, Options, Diags),
    Result = result(
        project(Name),
        department(Dept),
        schemas([]),
        sources(DataSources),
        evidence(Evidence),
        ir(IR),
        cfg(CFGRules, CFGText),
        dcg(DCGClauses),
        operations([]),
        constraints([]),
        interpretations([]),
        module(ModuleText),
        explanations([]),
        diagnostics(Diags)
    ).

%% data_to_cfg(+Name, +Department, +DataSources, +Options, -Result) is det.
data_to_cfg(Name, Dept, DataSources, Options, Result) :-
    must_be(atom, Name),
    must_be(atom, Dept),
    data_to_cfg(Name, DataSources, [department(Dept)|Options], Result).

%% evidence_to_cfg(+Name, +Department, +EvidenceList, -Result) is det.
evidence_to_cfg(Name, Dept, EvidenceList, Result) :-
    evidence_to_cfg(Name, Dept, EvidenceList, [], Result).

%% evidence_to_cfg(+Name, +Department, +EvidenceList, +Options, -Result) is det.
evidence_to_cfg(Name, Dept, EvidenceList, Options, Result) :-
    must_be(atom, Name),
    must_be(atom, Dept),
    Options1 = [department(Dept)|Options],
    validate_evidence_list(EvidenceList, Options1, Diags),
    build_ir_from_evidence(Name, EvidenceList, Options1, IR),
    generate_cfg2(Name, IR, EvidenceList, CFGRules),
    generate_dcg2(Name, IR, EvidenceList, DCGClauses),
    cfg_to_text(CFGRules, CFGText),
    generate_module2(Name, IR, EvidenceList, ModuleText),
    Result = result(
        project(Name),
        department(Dept),
        schemas([]),
        sources([evidence_list]),
        evidence(EvidenceList),
        ir(IR),
        cfg(CFGRules, CFGText),
        dcg(DCGClauses),
        operations([]),
        constraints([]),
        interpretations([]),
        module(ModuleText),
        explanations([]),
        diagnostics(Diags)
    ).

%% hybrid_to_cfg(+Name, +Department, +TextInput, +DataSources, -Result) is det.
hybrid_to_cfg(Name, Dept, TextInput, DataSources, Result) :-
    hybrid_to_cfg(Name, Dept, TextInput, DataSources, [], Result).

%% hybrid_to_cfg(+Name, +Department, +TextInput, +DataSources, +Options, -Result) is det.
hybrid_to_cfg(Name, Dept, TextInput, DataSources, Options, Result) :-
    must_be(atom, Name),
    % Get original CFG result from text (using 3-arg for safety with defaults)
    ideacfg_api:idea_to_cfg(Name, TextInput, OrigResult),
    % Load evidence from data sources
    load_all_sources(DataSources, [department(Dept)|Options], Evidence),
    % Extract CFG/DCG from original result (original 6-tuple format)
    (   OrigResult = result(_, cfg(OrigCFG, _), dcg(OrigDCG), _, _, _)
    ->  true
    ;   OrigCFG = [], OrigDCG = []
    ),
    build_ir_from_evidence(Name, Evidence, [department(Dept)|Options], IR),
    generate_cfg2(Name, IR, Evidence, ExtraCFG),
    generate_dcg2(Name, IR, Evidence, ExtraDCG),
    merge_cfg_rules(OrigCFG, ExtraCFG, CFGRules),
    append(OrigDCG, ExtraDCG, DCGClauses),
    cfg_to_text(CFGRules, CFGText),
    generate_module2(Name, IR, Evidence, ModuleText),
    validate_evidence_list(Evidence, [department(Dept)|Options], Diags),
    Result = result(
        project(Name),
        department(Dept),
        schemas([]),
        sources([text(TextInput)|DataSources]),
        evidence(Evidence),
        ir(IR),
        cfg(CFGRules, CFGText),
        dcg(DCGClauses),
        operations([]),
        constraints([]),
        interpretations([]),
        module(ModuleText),
        explanations([]),
        diagnostics(Diags)
    ).

%% load_evidence(+Format, +Source, +Options, -EvidenceList) is det.
load_evidence(Format, Source, Options, EvidenceList) :-
    source_adapter(Format, Source, Options, EvidenceList).

%% normalise_evidence(+Raw, +Options, +EvidenceList, -Normalised) is det.
normalise_evidence([], _, _, []).
normalise_evidence([E|Es], Options, DB, [N|Ns]) :-
    normalise_evidence_term(E, N),
    normalise_evidence(Es, Options, DB, Ns).

%% validate_evidence(+EvidenceList, +Options, -Errors) is det.
validate_evidence(EvidenceList, Options, Errors) :-
    validate_evidence_list(EvidenceList, Options, Errors).

%% compile_department(+Dept, +IR, +Options, -Result) is det.
compile_department(Dept, IR, Options, Result) :-
    (   department_registered(Dept)
    ->  department_profile(Dept, AcceptedTypes, OutputTypes, Policies),
        Result = department_result(
            department(Dept),
            accepted_types(AcceptedTypes),
            output_types(OutputTypes),
            policies(Policies),
            ir(IR)
        )
    ;   Result = error(department_not_registered(Dept))
    ).

%% parse_with_evidence(+Name, +Tokens, +EvidenceDB, +Options, -Tree) is semidet.
parse_with_evidence(Name, Tokens, EvidenceDB, Options, Tree) :-
    ideacfg_api:idea_parse(Name, Tokens, Options, BaseTree),
    Tree = parse_result(
        tree(BaseTree),
        evidence_available(EvidenceDB)
    ).

%% generate_with_evidence(+Name, +EvidenceDB, +Options, -Tokens, -EvidIds) is nondet.
generate_with_evidence(Name, EvidenceDB, Options, Tokens, EvidIds) :-
    ideacfg_api:idea_generate(Name, Options, Tokens),
    evidence_list_ids(EvidenceDB, EvidIds).

%% interpret_with_evidence(+ParseTree, +EvidenceDB, +Department, +Options, -Interp) is det.
interpret_with_evidence(ParseTree, EvidenceDB, Department, _Options, Interp) :-
    interpret_parse_result(ParseTree, EvidenceDB, Department, Interp).

%% Default options
default_options([
    confidence_policy(numeric),
    conflict_policy(retain_all),
    missing_value_policy(not_recorded),
    preserve_provenance(true),
    generate_cfg(true),
    generate_dcg(true),
    semantic_arguments(true),
    optimise(true),
    eliminate_left_recursion(true),
    max_rules(10000),
    max_depth(50),
    strict_units(true),
    intuition_policy(cautious),
    explanation_level(full)
]).

%% ── Internal helpers ─────────────────────────────────────────────────────

load_all_sources([], _Options, []).
load_all_sources([csv(Path, Schema)|Rest], Options, Evidence) :-
    source_adapter(csv, file(Path), [schema(Schema)|Options], Ev),
    load_all_sources(Rest, Options, RestEv),
    append(Ev, RestEv, Evidence).
load_all_sources([tsv(Path, Schema)|Rest], Options, Evidence) :-
    source_adapter(tsv, file(Path), [schema(Schema)|Options], Ev),
    load_all_sources(Rest, Options, RestEv),
    append(Ev, RestEv, Evidence).
load_all_sources([json(Path)|Rest], Options, Evidence) :-
    source_adapter(json, file(Path), Options, Ev),
    load_all_sources(Rest, Options, RestEv),
    append(Ev, RestEv, Evidence).
load_all_sources([prolog(Terms)|Rest], Options, Evidence) :-
    source_adapter(prolog_terms, Terms, Options, Ev),
    load_all_sources(Rest, Options, RestEv),
    append(Ev, RestEv, Evidence).
load_all_sources([evidence_list|Rest], Options, Evidence) :-
    load_all_sources(Rest, Options, Evidence).
load_all_sources([_Unknown|Rest], Options, Evidence) :-
    load_all_sources(Rest, Options, Evidence).

build_ir_from_evidence(Name, Evidence, Options, IR) :-
    option(department(Dept), Options, unknown),
    evidence_to_concepts(Evidence, Concepts),
    evidence_to_relations(Evidence, Relations),
    evidence_to_constraints(Evidence, Constraints),
    IR = cfg2_ir(
        Name,
        metadata([department(Dept)]),
        Concepts,
        Relations,
        [],          % operations
        Evidence,
        [],          % indicators
        Constraints,
        [],          % interpretations
        [evidence_list]   % sources
    ).

evidence_to_concepts([], []).
evidence_to_concepts([E|Es], [concept(EId, Subject, [Value], dept(Dept), [])|Cs]) :-
    evidence_id(E, EId),
    evidence_subject(E, Subject),
    evidence_value(E, Value),
    evidence_department(E, Dept),
    evidence_to_concepts(Es, Cs).

evidence_to_relations([], []).
evidence_to_relations([_|Es], Relations) :-
    evidence_to_relations(Es, Relations).

evidence_to_constraints([], []).
evidence_to_constraints([E|Es], [ir_constraint(CId, rule_candidate(EId), requires(evidence_valid(EId)), [EId], Dept)|Cs]) :-
    evidence_id(E, EId),
    evidence_department(E, Dept),
    atom_concat(c_, EId, CId),
    evidence_to_constraints(Es, Cs).

option(Opt, Options, Default) :-
    (   compound(Opt), Opt =.. [Key, _], member(Opt2, Options), Opt2 =.. [Key, _]
    ->  Opt2 = Opt
    ;   true
    ),
    (   memberchk(Opt, Options)
    ->  true
    ;   Opt =.. [_, Value], Value = Default -> true ; true
    ).
