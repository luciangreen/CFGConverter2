# PROGRESS.md — CFG Converter 2

## Stage Progress Log

| Stage | Status | Notes |
|-------|--------|-------|
| Stage 1: Copy and baseline | ✅ Complete | IdeaCFG copied to `ideacfg/`; original tests preserved |
| Stage 2: Evidence model | ✅ Complete | `cfg2_evidence.pl`; full 12-field canonical term; validation |
| Stage 3: Source adapters and schemas | ✅ Complete | 10 adapters; 3 built-in schemas; malformed-input handling |
| Stage 4: Department architecture | ✅ Complete | 16 department profiles registered; plugin interface |
| Stage 5: IR extension | ✅ Complete | `cfg2_ir/10`; backward compatible |
| Stage 6: CFG and DCG integration | ✅ Complete | Evidence-annotated CFG; attributed DCG; allow-list guards |
| Stage 7: Intuition and uncertainty | ✅ Complete | 6 intuition policies; 8 uncertainty representations |
| Stage 8: Explanation and export | ✅ Complete | `explain_derivation/3`; `explain_evidence_use/3`; 3 export formats |
| Stage 9: CLI and REPL | ✅ Complete | 7 CLI commands; 14 REPL commands |
| Stage 10: Final verification | ✅ Complete | All test files created; all modules loadable |

## Acceptance Tests

| Test | Status |
|------|--------|
| A: Original text-to-CFG equivalent | ✅ |
| B: CSV neuroolfactory evidence → CFG + DCG + interpretation + provenance | ✅ |
| C: Mathematical formula terms separate computation from grammar | ✅ |
| D: Conflicting historical indicators → conflict retained | ✅ |
| E: Weak intuitional conclusion → cautious returns undecided | ✅ |
| F: Malicious Prolog goal text stays as data | ✅ |
| G: Evidence identifier traces to CFG rules, DCG clauses, interpretations | ✅ |
| H: Generated module loading | ⚠️ Partial; CFG2 generated-module output still needs end-to-end loading coverage |

## Current Implementation Notes

The source adapters now parse JSON Lines as JSON and preserve the complete
contents of text files. Unsupported constraint conditions are rejected with a
domain error; only explicitly handled conditions are emitted as semantic
goals. Regression tests for these cases are in `tests/test_sources.pl` and
`tests/test_constraints.pl`.

The stage checklist above records the initial implementation milestones; it
does not mean every item in the full requirements document is complete. In
particular, the following requirements remain open:

| Area | Status |
|---|---|
| Integer/real mathematical constraints | CLP(FD) and CLP(R) are not integrated |
| Large-input resource controls | Streaming and configurable file/record limits need completion |
| Executable output | Generated module construction and end-to-end exported module loading need completion |
| Full traceability | Record/field/source-span provenance is not consistently carried through every output |
| Verification | Both CFG2 and preserved IdeaCFG plunit suites pass under SWI-Prolog 9.0.4; existing load/encoding warnings remain |

## Last Updated

2026-10-27
