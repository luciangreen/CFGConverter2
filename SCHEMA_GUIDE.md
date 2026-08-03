# SCHEMA_GUIDE.md — CFG Converter 2

## Overview

Schemas map external data records to the canonical evidence term.

## Built-in Schemas

- `olfactory_schema` — Qualitative neuroolfactory observations
- `formula_schema` — Mathematical formula terms
- `indicator_schema` — Humanities/intuitional indicators

## Registering a Schema

```prolog
:- use_module(prolog/cfg2_schema).

:- register_schema(my_schema, [
    field(id,         type(atom),   [required(true)]),
    field(department, type(atom),   [required(false), default(my_dept)]),
    field(subject,    type(atom),   [required(true)]),
    field(value,      type(any),    [required(true)]),
    field(confidence, type(confidence), [required(false), default(unknown)]),
    mapping(id_field,          id),
    mapping(department_field,  department),
    mapping(subject_field,     subject),
    mapping(value_field,       value),
    mapping(confidence_field,  confidence)
]).
```

## Validating Records

```prolog
?- validate_schema(my_schema, [id=e1, subject=response, value=strong], Errors).
Errors = [].
```

## Converting Records to Evidence

```prolog
?- schema_to_evidence(olfactory_schema,
                      [id=e1, subject=response_intensity, value=strong],
                      [], Evidence).
Evidence = evidence(e1, neuroolfaction, qualitative_measurement, ...).
```

## Field Types

| Type | Description |
|------|-------------|
| `atom` | SWI-Prolog atom |
| `integer` | Integer |
| `float` | Float |
| `number` | Any number |
| `list` | List |
| `any` | Any Prolog term |
| `confidence` | Valid confidence value (see EVIDENCE_MODEL.md) |
