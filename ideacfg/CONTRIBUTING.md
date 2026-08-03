# Contributing to IdeaCFG

## Style

- Use SWI-Prolog module declarations
- Use descriptive predicate names
- Document public predicates with PlDoc comments
- Use `must_be/2` at public boundaries
- Avoid unnecessary global state
- Use explicit state threading where state is required
- Prefer deterministic predicates for analysis and code generation
- Include tests with every feature

## Running Tests

```bash
cd ideacfg
swipl -g "load_test_files([verbose(normal)]), run_tests, halt" -t 'halt(1)' test/test_input.pl
```

Or run all:
```bash
swipl -g run_tests -t halt test/test_input.pl test/test_concepts.pl test/test_operations.pl
```

## Adding a Domain Example

1. Create `examples/DOMAIN/IDEA.pl`
2. Include at least one CFG element and (if applicable) direct Prolog operations
3. Add a test
4. Update EXAMPLES.md and PROGRESS.md
