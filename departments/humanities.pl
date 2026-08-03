%% departments/humanities.pl
%% Humanities department plugin for CFG Converter 2.
%%
%% Humanities data may include textual passages, annotations, historical
%% records, source provenance, conflicting accounts, symbolic motifs,
%% stylistic indicators, expert judgements, interpretive traditions, etc.

:- module(dept_humanities,
    [
        humanities_interpretation_cfg/1,
        humanities_interpretation_dcg/1,
        permit_multiple_interpretations/2,
        annotation_to_ir/3,
        conflicting_humanities_evidence/3
    ]).

:- use_module(library(lists)).
:- use_module('../prolog/cfg2_evidence').
:- use_module('../prolog/cfg2_indicators').
:- use_module('../prolog/cfg2_intuition').
:- use_module('../prolog/cfg2_uncertainty').

%% humanities_interpretation_cfg(-CFGRules) is det.
%  Example CFG for humanities interpretation.
humanities_interpretation_cfg([
    cfg_rule(r_hum1, document_interpretation,
             [literal_reading], [department(general_humanities)]),
    cfg_rule(r_hum2, document_interpretation,
             [political_reading], [department(general_humanities)]),
    cfg_rule(r_hum3, document_interpretation,
             [symbolic_reading], [department(general_humanities)]),
    cfg_rule(r_hum4, document_interpretation,
             [uncertain_reading], [department(general_humanities)])
]).

%% humanities_interpretation_dcg(-DCGText) is det.
humanities_interpretation_dcg(Text) :-
    Text = "document_interpretation(\n\
    tree(symbolic_reading, Children),\n\
    interpretation(symbolic_reading, Confidence),\n\
    evidence_state(Used, Remaining)\n\
) -->\n\
    symbolic_indicator(Child1, I1),\n\
    contextual_indicator(Child2, I2),\n\
    {\n\
        Children = [Child1, Child2],\n\
        combine_indicator_confidence([I1, I2], Confidence),\n\
        Used = [I1, I2],\n\
        evidence_remaining([I1, I2], Remaining)\n\
    }.".

%% permit_multiple_interpretations(+IndicatorList, -Interpretations) is det.
%  Returns all sufficiently-supported interpretations without asserting truth.
permit_multiple_interpretations(Indicators, Interpretations) :-
    findall(
        interpretation(Conc, supported_by(Supp), contradicted_by(Contra), confidence(Conf), alternatives(Alts)),
        (
            member(Ind, Indicators),
            indicator_direction(Ind, supports(Conc)),
            supporting_indicators(Indicators, Conc, Supp),
            contradicting_indicators(Indicators, Conc, Contra),
            length(Supp, NS), length(Contra, NC),
            (NS > 0 ->
                maplist(indicator_weight, Supp, Ws),
                sumlist(Ws, WSum),
                length(Supp, NW),
                Conf is WSum / NW
            ;
                Conf = 0.0
            ),
            findall(Alt, (member(I2, Indicators), indicator_direction(I2, supports(Alt)), Alt \= Conc), Alts0),
            sort(Alts0, Alts)
        ),
        InterpsDup
    ),
    sort(InterpsDup, Interpretations).

%% annotation_to_ir(+Evidence, +Options, -IRElement) is det.
annotation_to_ir(E, _Options, IRElement) :-
    evidence_id(E, EId),
    evidence_subject(E, Subject),
    evidence_value(E, Annotation),
    IRElement = concept(EId, Subject, [annotation(Annotation)],
                        dept(general_humanities), [source(EId)]).

%% conflicting_humanities_evidence(+EvidenceList, +Subject, -Conflicts) is det.
%  Identifies conflicting evidence for the same subject.
conflicting_humanities_evidence(EvidenceList, Subject, Conflicts) :-
    include([E]>>(evidence_subject(E, Subject)), EvidenceList, SubjectEvidence),
    findall(
        evidence_conflict(cid, Subject, [E1Id, E2Id], value_conflict, unresolved),
        (
            member(E1, SubjectEvidence),
            member(E2, SubjectEvidence),
            E1 \= E2,
            evidence_value(E1, V1),
            evidence_value(E2, V2),
            V1 \= V2,
            evidence_id(E1, E1Id),
            evidence_id(E2, E2Id),
            E1Id @< E2Id  % avoid duplicates
        ),
        Conflicts
    ).

:- initialization(format('Humanities department plugin loaded.~n'), now).
