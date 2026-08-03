%% cfg2_semantics.pl
%% Generates attributed semantic outputs from parses.
%%
%% Example output:
%%   interpretation(
%%       classification(likely_floral_response),
%%       confidence(0.82),
%%       evidence([e17, e18]),
%%       alternatives([mixed_response]),
%%       provenance([rule(r14), profile(neuroolfaction)])
%%   ).

:- module(cfg2_semantics,
    [
        make_interpretation/5,
        make_interpretation/6,
        interpretation_conclusion/2,
        interpretation_confidence/2,
        interpretation_evidence/2,
        interpretation_alternatives/2,
        interpretation_status/2,
        combine_interpretations/3,
        interpret_parse_result/4,
        classify_evidence/3
    ]).

:- use_module(library(lists)).
:- use_module(cfg2_uncertainty).

%% make_interpretation(+Conclusion, +Confidence, +Evidence,
%%                     +Alternatives, -Interpretation) is det.
make_interpretation(Conc, Conf, Evids, Alts,
    interpretation(Conc, confidence(Conf), evidence(Evids),
                   alternatives(Alts), status(supported))).

%% make_interpretation(+Conclusion, +Confidence, +Evidence,
%%                     +Alternatives, +Status, -Interpretation) is det.
make_interpretation(Conc, Conf, Evids, Alts, Status,
    interpretation(Conc, confidence(Conf), evidence(Evids),
                   alternatives(Alts), status(Status))).

%% Accessors
interpretation_conclusion(interpretation(C,_,_,_,_), C).
interpretation_confidence(interpretation(_,confidence(C),_,_,_), C).
interpretation_evidence(interpretation(_,_,evidence(E),_,_), E).
interpretation_alternatives(interpretation(_,_,_,alternatives(A),_), A).
interpretation_status(interpretation(_,_,_,_,status(S)), S).

%% combine_interpretations(+Policy, +InterpretationList, -Combined) is det.
combine_interpretations(retain_all, Interps, combined(Interps)).
combine_interpretations(highest_confidence, Interps, Best) :-
    (   Interps = []
    ->  Best = none
    ;   maplist([I, C-I]>>(interpretation_confidence(I, C)), Interps, Pairs),
        msort(Pairs, Sorted),
        last(Sorted, _-Best)
    ).
combine_interpretations(majority_vote, Interps, combined(Winners)) :-
    maplist(interpretation_conclusion, Interps, Conclusions),
    msort(Conclusions, Sorted),
    group_runs(Sorted, Groups),
    maplist([G-N]>>(length(G, N)), Groups, _),
    predsort([O, G1-N1, G2-N2]>>(compare(O, N2, N1)), Groups, Top),
    (   Top = [Conc-_|_]
    ->  include([I]>>(interpretation_conclusion(I, Conc)), Interps, Winners)
    ;   Winners = Interps
    ).
combine_interpretations(_, Interps, combined(Interps)).

group_runs([], []).
group_runs([H|T], [[H|Hs]-_|Groups]) :-
    partition(==(H), T, Hs, Rest),
    group_runs(Rest, Groups).

%% interpret_parse_result(+ParseTree, +EvidenceDB, +Department, -Interpretation) is det.
interpret_parse_result(Tree, EvidenceDB, Department, Interpretation) :-
    tree_evidence_ids(Tree, EvidIds),
    include([E]>>(cfg2_evidence:evidence_id(E, Id), member(Id, EvidIds)),
            EvidenceDB, UsedEvidence),
    (   UsedEvidence = []
    ->  Conf = unknown
    ;   maplist(cfg2_evidence:evidence_confidence, UsedEvidence, Confs),
        combine_confidence(mean, Confs, [], Conf)
    ),
    tree_conclusion(Tree, Conclusion),
    make_interpretation(Conclusion, Conf, EvidIds, [], supported, Interpretation).

tree_evidence_ids(tree(_Sym, Children), Ids) :-
    maplist(tree_evidence_ids, Children, IdLists),
    flatten(IdLists, Ids).
tree_evidence_ids(evidence_ref(Id), [Id]) :- !.
tree_evidence_ids(_, []).

tree_conclusion(tree(Sym, _), Sym).
tree_conclusion(Sym, Sym) :- atom(Sym).

%% classify_evidence(+EvidenceList, +Department, -Classifications) is det.
classify_evidence([], _, []).
classify_evidence([E|Es], Dept, [Class|Classes]) :-
    cfg2_evidence:evidence_type(E, Type),
    cfg2_evidence:evidence_value(E, Value),
    cfg2_evidence:evidence_id(E, Id),
    Class = classification(Id, Type, Value, department(Dept)),
    classify_evidence(Es, Dept, Classes).
