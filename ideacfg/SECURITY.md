# IdeaCFG Security

## Threat Model

IdeaCFG accepts user-provided text and structured Prolog terms as input. The primary security concern is that user input should never become executable Prolog code through unsafe evaluation paths.

## Protections

### No Unrestricted Execution
- `call/1` is not applied to user-provided terms
- `consult/1` is not called on generated content
- `assert/1` is not used to inject clauses from user text
- `term_string/2` is not used for arbitrary execution

### Expression Evaluation
- The evaluator uses an explicit allowlist of operators: `add`, `sub`, `mul`, `div`, `pow`, `neg`, `abs_val`, `sqrt_op`, `log_op`, `mod_op`
- Unknown AST nodes are rejected with a type error
- Division by zero is detected before evaluation

### File Operations
- All output paths are validated against path traversal (`..`)
- Writing only occurs to permitted output directories
- No arbitrary file loading from generated content

### Generated Code
- Predicate and module names are sanitised (only `[a-z0-9_]`)
- Generated modules are syntactically validated before execution
- No dynamic code execution via generated clauses

### Network
- No implicit network access

## Reporting Unsafe Operations

Unsafe or unsupported operations are emitted as:
```prolog
operation(Id, unknown, [], [], unsupported, [unsafe], Source)
```

They are reported in the diagnostics but never executed.

## Fuzz Testing

The test suite includes fuzz tests that verify:
- Bounded random IR models generate loadable modules
- Validators terminate
- Direct operations do not execute unsafe terms
