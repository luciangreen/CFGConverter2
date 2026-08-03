# PROGRAM_REQUIREMENTS.md

See `pr1.txt` for the full specification.

## Summary

IdeaCFG converts descriptions of academic ideas into executable context-free grammars and Prolog computation layers.

## Core Rule

```prolog
representation_for(Element, direct_prolog) :-
    directly_computable(Element),
    deterministic_or_semidet(Element),
    safe_to_execute(Element), !.
representation_for(Element, cfg) :-
    compositional_choice(Element), !.
representation_for(Element, hybrid) :-
    grammar_selects_operation(Element), !.
representation_for(Element, constrained_cfg) :-
    structurally_context_free_approximation(Element),
    requires_semantic_validation(Element), !.
representation_for(Element, unresolved) :-
    report_limitation(Element).
```

## Implemented Stages

- Stage 1: Repository foundation ✓
- Stage 2: Input and source model ✓
- Stage 3: Concept and relation extraction ✓
- Stage 4: Mathematical-operation extraction ✓
- Stage 5: Initial CFG generator ✓
- Stage 6: DCG compiler ✓
- Stage 7: Grammar tricks ✓
- Stage 8: Grammar-operation integration ✓
- Stage 9: Optimisation and resource control ✓
- Stage 10: Explanation and traceability ✓
- Stage 11: Complete REPL and CLI ✓
- Stage 12: Domain showcases ✓
- Stage 13: Hardening ✓
