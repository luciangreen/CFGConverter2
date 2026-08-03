%% cfg2_schema.pl
%% Schema definition and validation for CFG Converter 2.
%%
%% Schemas define field names, types, required fields, units,
%% allowed values, null handling, confidence representation,
%% provenance fields, and department mappings.

:- module(cfg2_schema,
    [
        register_schema/2,
        validate_schema/3,
        schema_field/4,
        schema_to_evidence/4,
        list_schemas/1,
        schema_registered/1
    ]).

:- use_module(library(lists)).
:- use_module(cfg2_evidence).

:- dynamic schema_definition/2.

%% register_schema(+SchemaName, +SchemaDef) is det.
register_schema(Name, Def) :-
    must_be(atom, Name),
    retractall(schema_definition(Name, _)),
    assertz(schema_definition(Name, Def)).

%% schema_registered(+SchemaName) is semidet.
schema_registered(Name) :- schema_definition(Name, _).

%% list_schemas(-Names) is det.
list_schemas(Names) :-
    findall(N, schema_definition(N, _), Names).

%% schema_field(+SchemaName, +FieldName, -FieldSpec, -Options) is semidet.
schema_field(Name, Field, Spec, Opts) :-
    schema_definition(Name, Def),
    member(field(Field, Spec, Opts), Def).

%% validate_schema(+SchemaName, +Record, -Errors) is det.
validate_schema(SchemaName, Record, Errors) :-
    (   schema_definition(SchemaName, Def)
    ->  validate_record_against_schema(Def, Record, Errors)
    ;   Errors = [error(schema, not_registered, SchemaName)]
    ).

validate_record_against_schema(Def, Record, Errors) :-
    % Check required fields
    findall(E, check_field(Def, Record, E), Errors).

check_field(Def, Record, error(field(Field), missing_required, Field)) :-
    member(field(Field, _Spec, Opts), Def),
    member(required(true), Opts),
    \+ (is_list(Record), member(Field=_, Record)).

check_field(Def, Record, error(field(Field), wrong_type(Type, Actual), Field)) :-
    member(field(Field, type(Type), _Opts), Def),
    is_list(Record),
    member(Field=Val, Record),
    \+ check_type(Type, Val),
    Actual = Val.

check_type(atom,    V) :- atom(V).
check_type(integer, V) :- integer(V).
check_type(float,   V) :- float(V).
check_type(number,  V) :- number(V).
check_type(list,    V) :- is_list(V).
check_type(any,     _).
check_type(confidence, V) :- cfg2_evidence:valid_confidence(V).

%% schema_to_evidence(+SchemaName, +Record, +Options, -Evidence) is det.
%  Maps a validated record to a canonical evidence term using the schema.
schema_to_evidence(SchemaName, Record, Options, Evidence) :-
    (   schema_definition(SchemaName, Def)
    ->  extract_field(Def, Record, id_field, Id, ev_default_id),
        extract_field(Def, Record, department_field, Dept, unknown),
        extract_field(Def, Record, type_field, Type, unknown_type),
        extract_field(Def, Record, subject_field, Subject, unknown),
        extract_field(Def, Record, value_field, Value, missing),
        extract_field(Def, Record, unit_field, Unit, dimensionless),
        extract_field(Def, Record, context_field, Context, context([])),
        extract_field(Def, Record, confidence_field, Conf, unknown),
        extract_field(Def, Record, provenance_field, Prov, provenance([])),
        extract_field(Def, Record, time_field, Time, unknown),
        extract_field(Def, Record, location_field, Loc, unknown),
        extract_field(Def, Record, metadata_field, Meta, []),
        Evidence = evidence(Id, Dept, Type, Subject, Value, Unit,
                            Context, Conf, Prov, Time, Loc, Meta)
    ;   throw(error(schema_not_registered(SchemaName), schema_to_evidence/4))
    ).

extract_field(Def, Record, Mapping, Value, Default) :-
    (   member(mapping(Mapping, FieldName), Def),
        is_list(Record),
        member(FieldName=Value, Record)
    ->  true
    ;   Value = Default
    ).

%% Built-in schemas

register_builtin_schemas :-
    register_schema(olfactory_schema,
        [
            field(id,         type(atom),       [required(true)]),
            field(department, type(atom),       [required(false), default(neuroolfaction)]),
            field(type,       type(atom),       [required(false), default(qualitative_measurement)]),
            field(subject,    type(atom),       [required(true)]),
            field(value,      type(atom),       [required(true)]),
            field(unit,       type(atom),       [required(false), default(neuroolfactory_unit)]),
            field(context,    type(any),        [required(false), default(context([]))]),
            field(confidence, type(confidence), [required(false), default(unknown)]),
            field(provenance, type(any),        [required(false), default(provenance([]))]),
            field(time,       type(any),        [required(false), default(unknown)]),
            field(location,   type(atom),       [required(false), default(unknown)]),
            mapping(id_field,          id),
            mapping(department_field,  department),
            mapping(type_field,        type),
            mapping(subject_field,     subject),
            mapping(value_field,       value),
            mapping(unit_field,        unit),
            mapping(confidence_field,  confidence),
            mapping(provenance_field,  provenance)
        ]),
    register_schema(formula_schema,
        [
            field(id,         type(atom),       [required(true)]),
            field(department, type(atom),       [required(false), default(mathematics)]),
            field(type,       type(atom),       [required(false), default(formula)]),
            field(formula,    type(any),        [required(true)]),
            field(variables,  type(list),       [required(false), default([])]),
            field(domain,     type(any),        [required(false), default(unknown)]),
            mapping(id_field,      id),
            mapping(department_field, department),
            mapping(type_field,    type),
            mapping(value_field,   formula)
        ]),
    register_schema(indicator_schema,
        [
            field(id,          type(atom),       [required(true)]),
            field(domain,      type(atom),       [required(true)]),
            field(subject,     type(atom),       [required(true)]),
            field(signal,      type(atom),       [required(true)]),
            field(direction,   type(any),        [required(true)]),
            field(strength,    type(any),        [required(false), default(moderate)]),
            field(reliability, type(confidence), [required(false), default(unknown)]),
            field(context,     type(any),        [required(false), default(context([]))]),
            field(provenance,  type(any),        [required(false), default(provenance([]))]),
            mapping(id_field,      id),
            mapping(subject_field, subject)
        ]).

:- use_module(library(error)).
:- initialization(register_builtin_schemas, now).
