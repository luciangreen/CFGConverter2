# SECURITY.md — CFG Converter 2

## Design Principles

CFG Converter 2 is designed to be safe when processing untrusted input data.

## Guarantees

- **No input is executed as Prolog code.** All imported strings and terms are treated as data.
- **No unrestricted `call/1`** in generated semantic actions.
- **No `assert/1`, `consult/1`, or `read/1`** on untrusted data.
- **Generated semantic goals** call only predicates on a declared allow-list (`cfg2_constraints.pl`).
- **Path traversal prevention** in file export (`safe_write_file/3`).
- **Input validation** rejects malformed evidence, invalid confidence values, and unsafe predicate names.

## Allow-listed Predicates in Generated Code

```prolog
cfg2_evidence_valid/1
cfg2_evidence_value/2
cfg2_measurement_above/2
cfg2_measurement_below/2
cfg2_qualitative_at_least/2
cfg2_evidence_measurement/3
cfg2_valid_formula/1
cfg2_valid_stimulus/1
cfg2_evidence_in_range/1
cfg2_score/1
cfg2_bounded/2
cfg2_observed_at/1
cfg2_located_at/1
cfg2_derived_from/1
```

## Intuition Safety

Intuitions are never compiled to unconditional facts. They produce:
- Guarded DCG branches
- Defeasible interpretations
- Confidence-bearing semantic outputs
- Candidate interpretations requiring validation

## What to Avoid

Do NOT pass the output of `term_to_atom/2`, `read_term/2`, or `atom_to_term/3`
to `call/1` with untrusted data.

Do NOT use `assertz/1` with terms derived from external input without
full validation.

## Reporting Issues

Please file a GitHub issue if you discover a safety vulnerability.
