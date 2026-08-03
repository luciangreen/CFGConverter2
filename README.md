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

## Test Command

```bash
swipl -g "load_files([tests/test_api, tests/test_evidence, tests/test_schema,
                      tests/test_departments, tests/test_sources,
                      tests/test_cfg, tests/test_dcg,
                      tests/test_provenance, tests/test_security]),
          run_tests, halt." \
      -t halt prolog/cfg2_api.pl
```

---

## Original Repository

CFG Converter 2 is based on [luciangreen/cfgconverter](https://github.com/luciangreen/cfgconverter).
The original code is preserved in the `ideacfg/` directory with its original licence.
