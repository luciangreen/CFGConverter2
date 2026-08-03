# ARCHITECTURE.md — CFG Converter 2

## Pipeline

```
Input source
   ↓
Source adapter (cfg2_sources.pl)
   ↓
Typed evidence records (cfg2_evidence.pl)
   ↓
Validation and normalisation (cfg2_validate.pl)
   ↓
Department profile (cfg2_departments.pl)
   ↓
Evidence-to-concept mapping
   ↓
Intermediate representation (cfg2_ir / cfg2_ir extension)
   ↓
Concept and relation extraction
   ↓
Operation extraction
   ↓
Evidence constraint extraction (cfg2_constraints.pl)
   ↓
Pattern discovery
   ↓
CFG generation (cfg2_cfg.pl)
   ↓
Attributed DCG generation (cfg2_dcg.pl)
   ↓
Grammar transformations
   ↓
Factoring and recursion analysis (ideacfg_factoring.pl, ideacfg_recursion.pl)
   ↓
Validation (cfg2_validate.pl)
   ↓
Optimisation (ideacfg_optimise.pl)
   ↓
Code generation (cfg2_codegen.pl)
   ↓
Explanation, provenance and export (cfg2_explain.pl, cfg2_provenance.pl)
```

## Module Responsibilities

| Module | Responsibility |
|--------|---------------|
| `cfg2_api` | Public entry points; backward compatibility |
| `cfg2_evidence` | Canonical evidence term; accessors; validation |
| `cfg2_sources` | Source adapters for CSV, TSV, JSON, Prolog terms, etc. |
| `cfg2_schema` | Schema registration and record-to-evidence mapping |
| `cfg2_departments` | Department profile registry and policy lookup |
| `cfg2_measurements` | Unit validation, ordinal scales, aggregation |
| `cfg2_indicators` | Indicator terms; direction analysis |
| `cfg2_intuition` | Intuition terms; policy-based interpretation |
| `cfg2_constraints` | Evidence-to-constraint conversion; safe goals |
| `cfg2_uncertainty` | Confidence policies; combination operators |
| `cfg2_provenance` | Provenance chain recording and querying |
| `cfg2_semantics` | Interpretation construction from parse results |
| `cfg2_cfg` | Evidence-annotated CFG rule generation |
| `cfg2_dcg` | Attributed DCG clause generation |
| `cfg2_validate` | Input, grammar, and safety validation |
| `cfg2_explain` | Derivation and evidence-use explanations |
| `cfg2_codegen` | Module text generation and file export |
| `cfg2_cli` | Command-line interface |
| `cfg2_repl` | Interactive REPL |
| `departments/*.pl` | Department-specific plugins |
| `schemas/*.pl` | Registered source schemas |

## Data Flow

```
Evidence records ──► IR ──► CFG rules ──► DCG clauses ──► Module text
      │                │         │              │
      ▼                ▼         ▼              ▼
Validation      Constraints  Provenance   Explanations
```

## Safety Invariants

1. No input string or term is passed to `call/1`, `assert/1`, or `consult/1`.
2. Generated semantic goals call only predicates on the allow-list in `cfg2_constraints`.
3. File export checks for path traversal.
4. Evidence confidence values are validated before use.
