# CFG Converter 2

CFG Converter 2 is an extension of [CFG Converter (IdeaCFG)](https://github.com/luciangreen/cfgconverter) that adds support for **non-chatbot-recordable evidence sources** and **department-specific interpretation**.

It converts both ordinary ideas and structured external evidence into Context-Free Grammar (CFG) and Definite Clause Grammar (DCG) forms whose productions, constraints, semantic arguments, and outputs reflect the supplied evidence.

---

## Purpose

- Convert ideas and structured evidence into CFG and DCG representations
- Support multiple academic departments through a common evidence model
- Separate computations from grammar productions
- Preserve the origin and provenance of every derived grammar rule
- Permit qualitative as well as quantitative data
- Represent uncertainty without pretending uncertain evidence is certain
- Represent intuition as structured indicators rather than unexplained truth
- Generate executable and inspectable SWI-Prolog
- Avoid dependence on a chatbot at runtime

---

## Installation

Requirements: [SWI-Prolog](https://www.swi-prolog.org/) 8.x or later.

```bash
git clone https://github.com/luciangreen/CFGConverter2.git
cd CFGConverter2
```

Load the main API in SWI-Prolog:

```prolog
?- [prolog/cfg2_api].
```

---

## First Example — Idea to CFG (Backward Compatible)

```prolog
?- idea_to_cfg(my_idea, 'A cat sits on a mat.', Result).
Result = result(idea(my_idea), cfg(...), dcg(...), ...).
```

---

## Data-to-CFG Example

```prolog
?- load_evidence(prolog_terms, [
       evidence(e1, neuroolfaction, qualitative_measurement,
                response_intensity, strong, neuroolfactory_unit,
                context(stimulus(rose)), 0.82,
                provenance(observer(o1)), time(t1), location(lab), [])
   ], [], Evidence),
   evidence_to_cfg(rose_study, neuroolfaction, Evidence, Result).
```

---

## Neuroolfactory Example

```prolog
?- evidence_to_cfg(
       rose_response,
       neuroolfaction,
       [evidence(e1, neuroolfaction, qualitative_measurement,
                 response_intensity, strong, neuroolfactory_unit,
                 context(stimulus(rose)), 0.82,
                 provenance(observer(o1)), time(t1), location(lab), [])],
       [confidence_policy(weighted_indicators)],
       Result
   ).
```

---

## Humanities Example

```prolog
?- evidence_to_cfg(
       letter_study,
       history,
       [
           evidence(e1, history, archival_record, letter_42,
                    dated_1812, year, context(archive_3),
                    0.7, provenance(archivist(a1)), unknown, archive_3, []),
           evidence(e2, history, archival_record, letter_42,
                    post_1815, year, context(archive_3),
                    0.65, provenance(analyst(a2)), unknown, archive_3, [])
       ],
       [conflict_policy(retain_all)],
       Result
   ).
```

---

## Safety Warning

CFG Converter 2 never executes imported data as Prolog code. All input is
treated as data. Generated semantic actions call only a declared allow-list
of safe predicates. See [SECURITY.md](SECURITY.md) for details.

---

## Features and Documentation

The CFG2 pipeline includes canonical 12-field evidence records, validation and
normalisation, source adapters, schemas, department profiles, confidence and
intuition policies, evidence-annotated CFG rules, attributed DCG clauses,
provenance, explanations, export, a CLI and a REPL. The original IdeaCFG
implementation and API remain available under `ideacfg/`.

Supported source adapters are `prolog_terms`, `csv`, `tsv`, `json`,
`json_lines`, `text`, `key_value`, `observation_table`, `formula_terms` and
`indicator_records`. JSON Lines files are read as one JSON object per line;
text files are preserved as text. CSV/TSV schemas and department mappings are
described in the guides below.

| Guide | Covers |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Pipeline, module responsibilities, safety invariants |
| [EVIDENCE_MODEL.md](EVIDENCE_MODEL.md) | Evidence record fields, validation, provenance |
| [SCHEMA_GUIDE.md](SCHEMA_GUIDE.md) | Built-in and custom source schemas |
| [DEPARTMENT_PROFILES.md](DEPARTMENT_PROFILES.md) | Registered departments and policy profiles |
| [EXAMPLES.md](EXAMPLES.md) | Mathematics, science, humanities, and hybrid examples |
| [CLI.md](CLI.md) | CLI commands, arguments, formats, and exit status |
| [REPL.md](REPL.md) | Interactive commands |
| [SECURITY.md](SECURITY.md) | Input handling and generated-code safety |
| [PROGRESS.md](PROGRESS.md) | Implemented scope and remaining work |
| [PROGRAM_REQUIREMENTS.md](PROGRAM_REQUIREMENTS.md) | Full requirements and design goals |
| [pr1.txt](pr1.txt) | Complete numbered requirements |

Constraint conditions are translated only when they use an explicitly
allow-listed form. Unsupported conditions raise a domain error rather than
being emitted as an unresolved generated goal.

## API Summary

| Predicate | Description |
|-----------|-------------|
| `idea_to_cfg/3,4` | Original CFG Converter API (backward compatible) |
| `evidence_to_cfg/4,5` | Evidence-only CFG generation |
| `data_to_cfg/3,4` | Multi-source CFG generation |
| `hybrid_to_cfg/5,6` | Combined text + evidence CFG |
| `load_evidence/4` | Load evidence from a source |
| `validate_evidence/3` | Validate evidence list |
| `explain_derivation/3` | Explain a generated item |
| `explain_evidence_use/3` | Trace evidence to grammar rules |
| `export_cfg2/3,4` | Export results |

---

## Tests

Run the complete CFG2 test suite from the repository root:

```sh
swipl -q -g "expand_file_name('tests/test_*.pl', Files), maplist(load_files, Files), run_tests, halt."
```

Run the preserved IdeaCFG suite separately:

```sh
swipl -q -g "expand_file_name('ideacfg/test/test_*.pl', Files), maplist(load_files, Files), run_tests, halt."
```

Both commands require SWI-Prolog 8.x or later. Each `tests/test_*.pl` file is a
plunit suite; source-adapter tests include temporary-file checks for text and
JSON Lines input.

---

## Original Repository

CFG Converter 2 is based on [luciangreen/cfgconverter](https://github.com/luciangreen/cfgconverter).
The original code is preserved in the `ideacfg/` directory with its original licence.
