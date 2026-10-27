# CHANGELOG.md — CFG Converter 2

## Unreleased

### Fixed

- Parse JSON Lines input as JSON objects rather than Prolog terms.
- Preserve the full contents of text source files without attempting to parse
  their prefix as a Prolog term.
- Reject unsupported constraint conditions instead of emitting unresolved
  semantic goals.

### Documentation and tests

- Document source formats, feature guides, full CFG2 and legacy test commands,
  and known implementation gaps.
- Add regression tests for text-file and JSON Lines ingestion and fail-closed
  constraint translation.
- Correct the legacy relation tests to call their module-local detectors and
  assert that each detector matches its example.

## 0.1.0 — Initial Release (2026-08-03)

### Added

- **Stage 1**: Copied and baselined CFG Converter (IdeaCFG) from luciangreen/cfgconverter
- **Stage 2**: Implemented canonical evidence model (`cfg2_evidence.pl`)
  - 12-argument canonical evidence term
  - Validated evidence types, confidence values
  - Normalisation for shorter forms
  - Evidence indexing by id, department, type, subject
- **Stage 3**: Source adapters and schemas (`cfg2_sources.pl`, `cfg2_schema.pl`)
  - Prolog terms, CSV, TSV, JSON, JSON Lines, text, key-value,
    observation_table, formula_terms, indicator_records adapters
  - Built-in schemas: olfactory_schema, formula_schema, indicator_schema
- **Stage 4**: Department architecture (`cfg2_departments.pl`)
  - 16 registered department profiles
  - mathematics, formal_logic, physics, chemistry, biology, neuroscience,
    neuroolfaction, psychology, social_science, history, philosophy,
    literature, visual_arts, music, general_humanities, interdisciplinary
  - Department-specific confidence and intuition policies
- **Stage 5**: IR extension
  - `cfg2_ir/10` with evidence, indicators, constraints, interpretations
  - Backward-compatible with original `idea/3` IR
- **Stage 6**: CFG and DCG integration (`cfg2_cfg.pl`, `cfg2_dcg.pl`)
  - Evidence-annotated CFG rules with provenance
  - Attributed DCG clauses with semantic arguments
  - Evidence-guarded branches
  - Restricted semantic actions to approved allow-list
- **Stage 7**: Intuition and uncertainty (`cfg2_intuition.pl`, `cfg2_uncertainty.pl`)
  - Intuition never compiles to unconditional facts
  - Policies: strict, balanced, expert_weighted, plural, cautious, custom
  - Uncertainty: boolean, three_valued, numeric, ordinal, interval, count, weighted
- **Stage 8**: Explanation and export (`cfg2_explain.pl`, `cfg2_codegen.pl`)
  - `explain_derivation/3` and `explain_evidence_use/3`
  - Export formats: prolog, cfg, json
  - Path traversal protection
- **Stage 9**: CLI and REPL (`cfg2_cli.pl`, `cfg2_repl.pl`)
  - Commands: convert, validate, inspect, explain, export, test, help
  - REPL state machine with load/schema/department/convert/show/explain/export
- **Stage 10**: Final verification
  - All test suites created
  - All modules load in SWI-Prolog
  - Documentation complete

### Backward Compatibility

The original `idea_to_cfg/3` and `idea_to_cfg/4` predicates remain available
through `cfg2_api.pl` via delegation to `ideacfg_api.pl`.

### Intentional Incompatibilities

None. All new predicates are additions to the original API.

### Known Limitations

- JSON import requires `library(http/json)` to be available
- Streaming for very large files is partially implemented
- CLP(FD) and CLP(R) constraints are declared but not yet wired
