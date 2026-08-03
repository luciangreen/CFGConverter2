%% ideacfg_ir.pl
%% Intermediate representation (IR) for IdeaCFG.
:- module(ideacfg_ir,
    [
        ir_empty/1,
        ir_add_element/3,
        ir_elements/2,
        ir_name/2,
        ir_metadata/2,
        valid_ir_element/1,
        ir_concepts/2,
        ir_operations/2,
        ir_relations/2,
        ir_constraints/2,
        ir_assumptions/2,
        ir_ambiguities/2,
        ir_serialize/2
    ]).

:- use_module(library(lists)).

:- discontiguous ir_operations/2, ir_relations/2, ir_ambiguities/2.

%% ir_empty(-IR) is det.
%  Creates an empty idea IR.
ir_empty(idea('', [], [])).

%% ir_add_element(+IR0, +Element, -IR1) is det.
%  Adds an element to the IR.
ir_add_element(idea(Name, Meta, Elems), Elem, idea(Name, Meta, [Elem|Elems])) :-
    valid_ir_element(Elem).

%% ir_elements(+IR, -Elements) is det.
%  Retrieves all elements from the IR.
ir_elements(idea(_, _, Elements), Elements).

%% ir_name(+IR, -Name) is det.
%  Retrieves the idea name.
ir_name(idea(Name, _, _), Name).

%% ir_metadata(+IR, -Meta) is det.
%  Retrieves idea metadata.
ir_metadata(idea(_, Meta, _), Meta).

%% valid_ir_element(+Element) is semidet.
%  True when Element is a valid IR element.
valid_ir_element(concept(_, _, _, _, _)).
valid_ir_element(relation(_, _, _, _, _)).
valid_ir_element(sequence(_, _, _, _)).
valid_ir_element(alternative(_, _, _, _)).
valid_ir_element(optional(_, _, _, _)).
valid_ir_element(repetition(_, _, _, _, _, _)).
valid_ir_element(operation(_, _, _, _, _, _, _)).
valid_ir_element(constraint(_, _, _, _, _)).
valid_ir_element(feature(_, _, _, _)).
valid_ir_element(example(_, _, _, _, _)).
valid_ir_element(ambiguity(_, _, _)).
valid_ir_element(assumption(_, _, _, _)).

%% ir_concepts(+IR, -Concepts) is det.
%  Extracts concept elements from IR.
ir_concepts(IR, Concepts) :-
    ir_elements(IR, Elems),
    include([E]>>(E = concept(_, _, _, _, _)), Elems, Concepts).

%% ir_operations(+IR, -Operations) is det.
%  Extracts operation elements from IR.
ir_operations(IR, Ops) :-
    ir_elements(IR, Elems),
    include([E]>>(E = operation(_, _, _, _, _, _, _)), Elems, Ops).

%% ir_relations(+IR, -Relations) is det.
%  Extracts relation elements from IR.
ir_relations(IR, Relations) :-
    ir_elements(IR, Elems),
    include([E]>>(E = relation(_, _, _, _, _)), Elems, Relations).

%% ir_constraints(+IR, -Constraints) is det.
%  Extracts constraint elements from IR.
ir_constraints(IR, Constraints) :-
    ir_elements(IR, Elems),
    include([E]>>(E = constraint(_, _, _, _, _)), Elems, Constraints).

%% ir_assumptions(+IR, -Assumptions) is det.
%  Extracts assumption elements from IR.
ir_assumptions(IR, Assumptions) :-
    ir_elements(IR, Elems),
    include([E]>>(E = assumption(_, _, _, _)), Elems, Assumptions).

%% ir_ambiguities(+IR, -Ambiguities) is det.
%  Extracts ambiguity elements from IR.
ir_ambiguities(IR, Ambiguities) :-
    ir_elements(IR, Elems),
    include([E]>>(E = ambiguity(_, _, _)), Elems, Ambiguities).

%% ir_serialize(+IR, -Term) is det.
%  Serializes IR as a Prolog term (identity, since IR is already terms).
ir_serialize(IR, IR).

%% Helper predicates exported for use by other modules.
ir_operations(IR, Ops) :-
    ir_elements(IR, Elems),
    include([E]>>(E = operation(_, _, _, _, _, _, _)), Elems, Ops).

ir_relations(IR, Rels) :-
    ir_elements(IR, Elems),
    include([E]>>(E = relation(_, _, _, _, _)), Elems, Rels).

ir_ambiguities(IR, Ambs) :-
    ir_elements(IR, Elems),
    include([E]>>(E = ambiguity(_, _, _)), Elems, Ambs).
