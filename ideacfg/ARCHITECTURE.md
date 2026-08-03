# IdeaCFG Architecture

## Overview

IdeaCFG is structured as a pipeline of independent modules, each responsible for one transformation stage.

## Module Dependency Graph

```
ideacfg_api
├── ideacfg_input
│   ├── ideacfg_tokenise
│   ├── ideacfg_normalise
│   └── ideacfg_ir
├── ideacfg_concepts
├── ideacfg_relations
├── ideacfg_ambiguity
├── ideacfg_operations
│   └── ideacfg_expression_dcg
│       └── ideacfg_evaluator
├── ideacfg_units
├── ideacfg_patterns
├── ideacfg_cfg
├── ideacfg_dcg
├── ideacfg_tricks
├── ideacfg_factoring
├── ideacfg_recursion
├── ideacfg_constraints
├── ideacfg_validate
├── ideacfg_optimise
├── ideacfg_codegen
├── ideacfg_explain
├── ideacfg_export
├── ideacfg_options
└── ideacfg_diagnostics
```

## Processing Stages

1. **Input** (`ideacfg_input`) — Accept text, sentences, or structured terms
2. **Tokenisation** (`ideacfg_tokenise`) — Split into tokens with source references
3. **Normalisation** (`ideacfg_normalise`) — Lowercase, synonym mapping
4. **IR Construction** (`ideacfg_ir`) — Build the Intermediate Representation
5. **Concept Extraction** (`ideacfg_concepts`) — Identify categories and entities
6. **Relation Extraction** (`ideacfg_relations`) — Sequences, alternatives, optionals, repetitions
7. **Operation Extraction** (`ideacfg_operations`) — Remove mathematical operations from grammar
8. **Pattern Matching** (`ideacfg_patterns`) — Apply domain-general idea patterns
9. **CFG Generation** (`ideacfg_cfg`) — Convert IR to grammar rules
10. **DCG Compilation** (`ideacfg_dcg`) — Convert grammar to executable DCG
11. **Grammar Tricks** (`ideacfg_tricks`) — Apply optimisation transformations
12. **Factoring** (`ideacfg_factoring`) — Factor prefixes and suffixes
13. **Recursion Analysis** (`ideacfg_recursion`) — Detect and bound recursion
14. **Validation** (`ideacfg_validate`) — Check grammar and operations
15. **Optimisation** (`ideacfg_optimise`) — Remove duplicates, unreachable rules
16. **Code Generation** (`ideacfg_codegen`) — Assemble final Prolog modules
17. **Explanation** (`ideacfg_explain`) — Produce traceability reports
18. **Export** (`ideacfg_export`) — Write files safely

## Design Principles

- Grammar represents choices; Prolog computes results.
- Operations are extracted before grammar generation (iterative by default).
- All IR elements retain source references.
- No user text becomes executable Prolog through unrestricted evaluation.
