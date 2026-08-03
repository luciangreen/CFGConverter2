# PROGRAM_REQUIREMENTS.md — CFG Converter 2

This file contains the complete program requirements for CFG Converter 2.

The requirements are reproduced from `pr1.txt` as the authoritative reference
for this implementation.

---

## 1. Project Summary

CFG Converter 2 shall be created as a working copy and extension of CFG Converter.

The original system converts human ideas, sentences, structured terms, concepts, relationships, and mathematical operations into:

- Context-free grammar rules
- Executable Prolog DCGs
- Supporting Prolog predicates
- Validation reports
- Explanations and traceability information
- Exportable source files

CFG Converter 2 extends this process so that grammar construction can also take account of non-chatbot-recordable data.

Non-chatbot-recordable data means observations, measurements, judgements, signals, indicators, records, or structured evidence that cannot be adequately represented as ordinary conversational text alone.

---

## 2. Central Design Principle

CFG Converter 2 distinguishes between:

1. **Grammar structure** — What sequences, alternatives, repetitions, classifications, and interpretations are permitted.
2. **Computable operations** — Mathematical, logical, scientific, statistical, or deterministic operations that Prolog should compute directly.
3. **Evidence conditions** — Measurements, observations, indicators, confidence values, provenance records, and expert judgements that constrain or support grammar rules.
4. **Interpretive outputs** — Scientific classifications, mathematical results, humanities interpretations, intuitional conclusions, and explanations generated from the grammar and evidence.

The guiding rule: **Grammar represents structured possibilities; Prolog predicates compute operations; evidence predicates constrain or support interpretations.**

No arbitrary external data shall be converted directly into executable Prolog source.

---

## 3. Required Repository Strategy

1. Copy the complete contents of luciangreen/cfgconverter
2. Preserve the original licence, documentation history, tests, examples, and attribution
3. Rename the extended program to CFG Converter 2
4. Rename modules only where necessary
5. Preserve backward compatibility with the original public API
6. Add new modules rather than unnecessarily rewriting stable modules
7. Keep the original CFG Converter behaviour available through compatibility predicates
8. Document every intentional incompatibility
9. Place the requirements in PROGRAM_REQUIREMENTS.md
10. Maintain a staged progress log in PROGRESS.md

---

## 4. Goals

CFG Converter 2 shall:

- Convert ideas and structured evidence into CFG and DCG representations
- Support multiple academic departments through a common evidence model
- Separate computations from grammar productions
- Preserve the origin and provenance of every derived grammar rule
- Permit qualitative as well as quantitative data
- Represent uncertainty without pretending that uncertain evidence is certain
- Represent intuition as structured indicators rather than unexplained truth
- Generate executable and inspectable SWI-Prolog
- Avoid dependence on a chatbot at runtime
- Accept data produced outside conversational interfaces
- Allow department-specific plugins without changing the core compiler
- Explain why each generated rule exists
- Validate generated grammars against evidence and test examples
- Support parsing, generation, classification, and interpretation
- Remain simple enough to operate through a Prolog API, CLI, and REPL

---

## 5. Non-Goals

The first release shall not:

- Train neural networks
- Perform unrestricted machine learning
- Claim that intuition is objectively correct
- Infer medical diagnoses automatically
- Replace scientific instruments or expert review
- Execute arbitrary code embedded in input data
- Require cloud services
- Require a chatbot
- Attempt to understand every possible binary file format
- Treat correlation as causation
- Convert uncertain humanities judgements into false numerical precision
- Guarantee that a generated grammar is a true scientific theory
- Use unrestricted `read/1`, `consult/1`, `call/1`, or `term_to_atom/2` on untrusted data

---

## 6. High-Level Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for the full pipeline description.

---

## 7. Required New Modules

- `prolog/cfg2_api.pl` — Main public API
- `prolog/cfg2_evidence.pl` — Canonical evidence representation
- `prolog/cfg2_sources.pl` — Source adapter protocol
- `prolog/cfg2_departments.pl` — Department profile registry
- `prolog/cfg2_measurements.pl` — Quantitative and qualitative measurements
- `prolog/cfg2_indicators.pl` — Humanities and intuitional indicators
- `prolog/cfg2_intuition.pl` — Structured intuitional input
- `prolog/cfg2_constraints.pl` — Evidence-to-constraint conversion
- `prolog/cfg2_provenance.pl` — Source-to-output traceability
- `prolog/cfg2_uncertainty.pl` — Explicit uncertainty representations
- `prolog/cfg2_semantics.pl` — Attributed semantic outputs
- `prolog/cfg2_schema.pl` — Source schema definition and validation
- `prolog/cfg2_cfg.pl` — Evidence-annotated CFG generation
- `prolog/cfg2_dcg.pl` — Attributed DCG generation
- `prolog/cfg2_codegen.pl` — Code generation and export
- `prolog/cfg2_validate.pl` — Input and grammar validation
- `prolog/cfg2_explain.pl` — Derivation explanations
- `prolog/cfg2_cli.pl` — Command-line interface
- `prolog/cfg2_repl.pl` — Interactive REPL

---

## 8. Intermediate Representation

The original IR is extended with evidence, indicators, constraints, and interpretations:

```prolog
cfg2_ir(Name, Metadata, Concepts, Relations, Operations,
        Evidence, Indicators, Constraints, Interpretations, Sources).
```

---

## 9–39. Full Requirements

See `pr1.txt` for the complete numbered requirements sections 9–39.
