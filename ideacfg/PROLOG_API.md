# IdeaCFG Prolog API

## Conversion

```prolog
idea_to_cfg(+IdeaName, +Input, -Result).
idea_to_cfg(+IdeaName, +Input, +Options, -Result).
```

Input may be an atom (plain text), list of atoms (sentences), or list of structured terms.

## Parsing

```prolog
idea_parse(+IdeaName, +Tokens, -Tree).
idea_parse(+IdeaName, +Tokens, +Options, -Tree).
```

## Generation

```prolog
idea_generate(+IdeaName, -Tokens).
idea_generate(+IdeaName, +Options, -Tokens).
```

## Direct Computation

```prolog
idea_compute(+IdeaName, +Operation, +Inputs, -Output).
idea_compute(+IdeaName, +Bindings, -Results).
```

Example:
```prolog
?- idea_compute(compound_interest,
                [principal-1000, rate-0.05, periods-10],
                Result).
```

## Validation

```prolog
idea_validate(+IdeaName, +Tree, -Report).
```

## Explanation

```prolog
idea_explain(+IdeaName, -Explanation).
idea_explain_rule(+IdeaName, +RuleId, -Explanation).
idea_explain_operation(+IdeaName, +OperationId, -Explanation).
```

## Export

```prolog
idea_export(+IdeaName, +Path).
idea_export(+IdeaName, +Format, +Path).
```

Formats: `prolog`, `cfg`, `dcg`, `markdown`, `json`.

## Loading and Unloading

```prolog
idea_load(+Path, -IdeaName).
idea_unload(+IdeaName).
```

## Testing

```prolog
idea_test(+IdeaName, -Report).
```

## Input Forms

```prolog
idea_from_text(+IdeaName, +Text, -Model).
idea_from_sentences(+IdeaName, +Sentences, -Model).
idea_from_terms(+IdeaName, +Terms, -Model).
idea_from_hybrid(+IdeaName, +Text, +Declarations, -Model).
```

## Human Review

```prolog
accept_rule(+IdeaName, +RuleId).
reject_rule(+IdeaName, +RuleId).
replace_rule(+IdeaName, +RuleId, +Replacement).
```
