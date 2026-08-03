# IdeaCFG Limitations

The following limitations are inherent to the system.

## Natural Language

- Not every academic idea is context-free.
- Natural-language understanding is based on pattern matching, not full semantic parsing.
- Ambiguous sentences are reported but not automatically resolved.
- Technical jargon not in the operation lexicon will not be recognised.

## Grammar Approximations

- The system creates structural representations and approximations.
- Non-context-free dependencies are bounded, approximated with feature arguments, or moved to Prolog constraints.
- Every approximation is documented in the conversion report.
- Generated grammars are not automatically complete theories of their domains.

## Operations

- Only operations in the allowlisted lexicon are automatically extracted.
- Unsafe or unknown formulas are emitted as unresolved obligations.
- Direct calculation does not establish truth of the underlying scholarly theory.
- Symbolic mathematics beyond basic arithmetic is not automatically supported.

## Domain Knowledge

- Semantic validators may be domain-limited.
- Generated scientific or scholarly models require human review.
- The system does not access external knowledge bases.

## Scale

- Very large ideas may trigger resource limits.
- Recursive grammars are bounded by `maximum_depth`.
- Grammar explosion is detected and reported.

## Security

- User-provided text never becomes executable Prolog through unrestricted evaluation.
- All file paths are validated; path traversal is rejected.
