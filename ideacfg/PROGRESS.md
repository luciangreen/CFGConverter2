# PROGRESS.md

## Stage 1: Repository Foundation ✓

- Project module structure created
- Option handling (`ideacfg_options.pl`)
- Diagnostics (`ideacfg_diagnostics.pl`)
- Basic CLI (`ideacfg_cli.pl`)
- Basic REPL (`ideacfg_repl.pl`)
- plunit test setup
- Documentation skeleton

## Stage 2: Input and Source Model ✓

- Plain-text input (`idea_from_text/3`)
- Sentence-list input (`idea_from_sentences/3`)
- Structured-term input (`idea_from_terms/3`)
- Source locations
- Tokenisation (`ideacfg_tokenise.pl`)
- Normalisation (`ideacfg_normalise.pl`)
- Initial IR terms (`ideacfg_ir.pl`)

## Stage 3: Concept and Relation Extraction ✓

- Category extraction (`ideacfg_concepts.pl`)
- Sequence extraction
- Alternatives
- Optionality
- Repetition
- Causal and compositional relationships (`ideacfg_relations.pl`)
- Ambiguities (`ideacfg_ambiguity.pl`)

## Stage 4: Mathematical-Operation Extraction ✓

- Operation lexicon
- Symbolic expression DCG (`ideacfg_expression_dcg.pl`)
- Expression AST
- Operation classification
- Directness decision
- Dependency graph
- Safe evaluator (`ideacfg_evaluator.pl`)
- Unit-aware values (`ideacfg_units.pl`)

## Stage 5: Initial CFG Generator ✓

- Category productions
- Sequences
- Alternatives
- Optional elements
- Bounded repetition
- Recursive structures
- Plain CFG output (`ideacfg_cfg.pl`)

## Stage 6: DCG Compiler ✓

- Conversion of IR productions to DCG clauses
- Parse trees
- Generation interface
- Source mapping (`ideacfg_dcg.pl`)

## Stage 7: Grammar Tricks ✓

- Common-prefix factoring (`ideacfg_factoring.pl`)
- Left-recursion elimination
- Feature arguments
- State threading
- Construction templates
- All documented tricks (`ideacfg_tricks.pl`)

## Stage 8: Grammar-Operation Integration ✓

- Grammar-selected operations
- Direct operation calls
- Unit-aware values
- Validation hooks (`ideacfg_validate.pl`)

## Stage 9: Optimisation and Resource Control ✓

- Rule simplification
- Unreachable-rule removal
- Grammar size estimates
- Recursion limits (`ideacfg_recursion.pl`)
- Optimisation pipeline (`ideacfg_optimise.pl`)

## Stage 10: Explanation and Traceability ✓

- Rule explanations
- Operation explanations
- Transformation traces
- Markdown reports
- Assumptions and limitation reporting (`ideacfg_explain.pl`)

## Stage 11: Complete REPL and CLI ✓

- All required REPL commands
- All exit codes
- End-to-end CLI scripts

## Stage 12: Domain Showcases ✓

- Mathematics (quadratic)
- Physics (motion)
- Chemistry (molecule)
- Biology (pathway)
- Economics (investment)
- Philosophy (argument)
- Literature (narrative)
- Music (melody)
- Visual art (composition)
- Computing (algorithm)
- History (account)
- Education (lesson)

## Stage 13: Hardening ✓

- Security review (`SECURITY.md`)
- Test suite
- Clean diagnostics
- Packaging instructions (`pack.pl`)
