# Operation Extraction

IdeaCFG extracts mathematical and directly computable operations before or during grammar generation to avoid enumerating them as grammar alternatives.

## Principle

> Do not force calculations into a grammar.

## Detected Operations

- Arithmetic: add, subtract, multiply, divide, power, root, logarithm
- Comparison: equal, greater than, less than, at least, at most, between, range
- Aggregation: sum, average, count, minimum, maximum, sort, rank
- Transformation: convert, transpose, rotate, shift
- Probabilistic: probability calculations, combinatorics

## Linguistic Indicators

Phrases like `multiplied by`, `the average of`, `calculate`, `sum of`, `convert`, `increased by` trigger extraction.

## Operation Classification

Each operation is classified as:
`arithmetic | comparison | aggregation | transformation | constraint | lookup | logical | probabilistic | symbolic | external | unknown`

## Execution Mode Decision

| Class | Default mode |
|---|---|
| arithmetic | direct_prolog |
| comparison | direct_prolog |
| aggregation | direct_prolog |
| transformation (qualitative) | cfg_enumeration |
| transformation (quantitative) | hybrid |
| probabilistic | direct_prolog |
| unknown | deferred |

## Safety

Generated operations are assembled from an allowlisted internal model. Unsafe or unknown formulas are emitted as `unresolved` obligations, never executed.

## Example

Input:
```
The area is width multiplied by height.
```

Extracted operation:
```prolog
rectangle_area(Width, Height, Area) :-
    must_be(number, Width),
    must_be(number, Height),
    Area is Width * Height.
```

The multiplication is **not** represented as grammar alternatives.
