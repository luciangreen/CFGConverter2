%% schemas/olfactory_schema.pl
%% Olfactory observation schema for CFG Converter 2.

:- module(olfactory_schema, []).

:- use_module('../prolog/cfg2_schema').

:- initialization(
    register_schema(olfactory_schema, [
        field(id,           type(atom),       [required(true)]),
        field(department,   type(atom),       [required(false), default(neuroolfaction)]),
        field(type,         type(atom),       [required(false), default(qualitative_measurement)]),
        field(subject,      type(atom),       [required(true)]),
        field(value,        type(atom),       [required(true)]),
        field(unit,         type(atom),       [required(false), default(neuroolfactory_unit)]),
        field(context,      type(any),        [required(false), default(context([]))]),
        field(confidence,   type(confidence), [required(false), default(unknown)]),
        field(provenance,   type(any),        [required(false), default(provenance([]))]),
        field(time,         type(any),        [required(false), default(unknown)]),
        field(location,     type(atom),       [required(false), default(unknown)]),
        field(stimulus,     type(atom),       [required(false)]),
        field(dimension,    type(atom),       [required(false), default(perceived_intensity)]),
        field(observer,     type(atom),       [required(false)]),
        mapping(id_field,          id),
        mapping(department_field,  department),
        mapping(type_field,        type),
        mapping(subject_field,     subject),
        mapping(value_field,       value),
        mapping(unit_field,        unit),
        mapping(confidence_field,  confidence),
        mapping(provenance_field,  provenance)
    ]),
    now
).
