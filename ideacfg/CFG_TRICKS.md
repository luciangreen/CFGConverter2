# CFG Tricks Reference

IdeaCFG implements a library of explicit conversion tricks for handling non-trivial grammar patterns.

## 1. Category Abstraction

**Purpose**: Convert related items into a single category with alternatives.

**Input pattern**: `A painting can use oil, acrylic or watercolour.`

**Output pattern**:
```
MEDIUM → OIL | ACRYLIC | WATERCOLOUR
```

**Limitations**: Assumes all members are genuine equals.

## 2. Sequence Extraction

**Purpose**: Convert ordered composition into a sequence rule.

**Input pattern**: `An experiment contains a hypothesis, method, results and conclusion.`

**Output pattern**:
```
EXPERIMENT → HYPOTHESIS METHOD RESULTS CONCLUSION
```

## 3. Alternative Extraction

**Input**: `A proof may use induction, contradiction or construction.`

**Output**:
```
PROOF_METHOD → INDUCTION | CONTRADICTION | CONSTRUCTION
```

## 4. Optionality

**Input**: `A report may include an appendix.`

**Output**:
```
REPORT → BODY OPTIONAL_APPENDIX
OPTIONAL_APPENDIX → APPENDIX | ε
```

## 5. Bounded Repetition

**Input**: `A paragraph contains one or more sentences.`

**Output**:
```
PARAGRAPH → SENTENCE MORE_SENTENCES
MORE_SENTENCES → SENTENCE MORE_SENTENCES | ε
```

**Assumptions**: Recursion depth is bounded by `maximum_depth` option.

## 6. Recursive Hierarchy

**Input**: `A section may contain subsections.`

**Output**:
```
SECTION → CONTENT SUBSECTIONS
SUBSECTIONS → SECTION SUBSECTIONS | ε
```

## 7. Feature Splitting

**Purpose**: Handle finite agreements through DCG arguments.

**Example**:
```prolog
statement(Domain, Level) -->
    subject(Domain, Level),
    predicate(Domain, Level).
```

## 8. State Threading

**Purpose**: Handle mutable state through explicit DCG arguments.

**Example**:
```prolog
process(S0, S) -->
    step(S0, S1),
    process(S1, S).
```

## 9. Common-Prefix Factoring

**Input**:
```
ARGUMENT → CLAIM EVIDENCE
ARGUMENT → CLAIM EXAMPLE
ARGUMENT → CLAIM COUNTERARGUMENT
```

**Output**:
```
ARGUMENT → CLAIM SUPPORT
SUPPORT → EVIDENCE | EXAMPLE | COUNTERARGUMENT
```

## 10. Left-Recursion Elimination

**Input**: `EXPR → EXPR "+" TERM | TERM`

**Output**:
```
EXPR → TERM EXPR_TAIL
EXPR_TAIL → "+" TERM EXPR_TAIL | ε
```

**Note**: Arithmetic is then computed by direct Prolog, not grammar enumeration.

## 11. Semantic Filtering

**Purpose**: Generate broad candidates, validate with Prolog.

```prolog
valid_candidate(Tree) :- domain_constraints(Tree).
```

## 12. Bounded Cross-Dependency Approximation

**Purpose**: Handle non-context-free dependencies through finite feature arguments, state threading, or post-parse validation.

**Assumptions**: Approximation is documented. Depth bound is configurable.
