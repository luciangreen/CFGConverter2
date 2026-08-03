%% schemas/indicator_schema.pl
%% Indicator schema for CFG Converter 2.

:- module(indicator_schema, []).
:- use_module('../prolog/cfg2_schema').

:- initialization(
    register_schema(indicator_schema, [
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
    ]),
    now
).
