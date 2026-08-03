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
| H: All generated modules load in SWI-Prolog | ✅ |

## Last Updated

2026-08-03
