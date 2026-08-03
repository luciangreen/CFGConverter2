# IdeaCFG Intermediate Representation

## Overview

The IdeaCFG IR separates all components of an idea into typed terms.

## Top-Level Structure

```prolog
idea(Name, Metadata, Elements).
```

## Element Types

### Concept
```prolog
concept(Id, Label, Type, Properties, Source).
```
Types: `category`, `entity`, `process`, `stage`, `property`, `relation_concept`, `operation_concept`, `unknown`.

### Relation
```prolog
relation(Type, From, To, Properties, Source).
```

### Sequence
```prolog
sequence(Id, Members, Properties, Source).
```
Members is an ordered list of concept or nonterminal identifiers.

### Alternative
```prolog
alternative(Id, Members, Properties, Source).
```

### Optional
```prolog
optional(Id, Member, Properties, Source).
```

### Repetition
```prolog
repetition(Id, Member, Minimum, Maximum, Properties, Source).
```
Maximum may be `unbounded` or an integer.

### Operation
```prolog
operation(Id, Class, Inputs, Output, Mode, Properties, Source).
```
Class: `arithmetic | comparison | aggregation | transformation | constraint | lookup | logical | probabilistic | symbolic | external | unknown`
Mode: `direct_prolog | cfg_enumeration | hybrid | deferred | unsupported`

### Constraint
```prolog
constraint(Id, Type, Arguments, Properties, Source).
```

### Feature
```prolog
feature(Entity, Name, Value, Source).
```

### Example
```prolog
example(Id, Input, Output, Properties, Source).
```

### Ambiguity
```prolog
ambiguity(Id, Alternatives, Source).
```

### Assumption
```prolog
assumption(Id, Statement, Reason, Source).
```

## Source References

Source terms take the form:
- `source_line(N)` — line number in input text
- `source_term` — derived from structured term input
- `source_tokens` — derived from token analysis
- `source_pattern` — applied from a domain pattern
- `source_decl` — from explicit declaration
