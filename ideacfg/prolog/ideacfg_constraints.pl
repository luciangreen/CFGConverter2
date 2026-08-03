%% ideacfg_constraints.pl
%% Constraint representation and validation for IdeaCFG.
:- module(ideacfg_constraints,
    [
        constraint_type/1,
        validate_constraint/2,
        extract_constraints/2,
        build_constraint/5
    ]).

:- use_module(ideacfg_ir).
:- use_module(ideacfg_diagnostics).
:- use_module(library(lists)).

%% constraint_type(?Type) is nondet.
constraint_type(ordering).
constraint_type(cardinality).
constraint_type(value_range).
constraint_type(type_check).
constraint_type(unit_compatibility).
constraint_type(negative).
constraint_type(semantic).
constraint_type(custom).

%% validate_constraint(+Constraint, -Diagnostics) is det.
%  Validates a constraint term and returns diagnostics.
validate_constraint(constraint(Id, Type, Args, Props, Src), Diags) :-
    (   constraint_type(Type)
    ->  Diags = []
    ;   format(atom(Msg), 'Unknown constraint type ~w for ~w', [Type, Id]),
        Diags = [diagnostic(warning, unknown_constraint_type, Msg, Src, [Id], 'Use a known constraint type')]
    ).
validate_constraint(Other, [diagnostic(warning, malformed_constraint, 'Malformed constraint', unknown, [Other], 'Check constraint structure')]).

%% extract_constraints(+IR, -Constraints) is det.
%  Extracts constraint elements from IR.
extract_constraints(IR, Constraints) :-
    ir_elements(IR, Elems),
    include([E]>>(E = constraint(_, _, _, _, _)), Elems, Constraints).

%% build_constraint(+Type, +Args, +Props, +Src, -Constraint) is det.
build_constraint(Type, Args, Props, Src, constraint(Id, Type, Args, Props, Src)) :-
    must_be(atom, Type),
    gensym(constraint_, Id).
