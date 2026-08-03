%% schemas/formula_schema.pl
%% Formula schema for CFG Converter 2.

:- module(formula_schema, []).
:- use_module('../prolog/cfg2_schema').

:- initialization(
    register_schema(formula_schema, [
        field(id,         type(atom), [required(true)]),
        field(department, type(atom), [required(false), default(mathematics)]),
        field(type,       type(atom), [required(false), default(formula)]),
        field(formula,    type(any),  [required(true)]),
        field(variables,  type(list), [required(false), default([])]),
        field(domain,     type(any),  [required(false), default(unknown)]),
        field(assumptions,type(list), [required(false), default([])]),
        mapping(id_field,         id),
        mapping(department_field, department),
        mapping(type_field,       type),
        mapping(value_field,      formula)
    ]),
    now
).
