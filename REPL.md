# REPL.md — CFG Converter 2

## Starting the REPL

```bash
swipl -g "use_module(prolog/cfg2_repl), cfg2_repl." prolog/cfg2_api.pl
```

## Commands

| Command | Description |
|---------|-------------|
| `load <source>` | Load evidence from file |
| `schema <schema-name>` | Set active schema |
| `department <department-name>` | Set active department |
| `convert` | Generate CFG/DCG from loaded evidence |
| `show evidence` | Show loaded evidence records |
| `show cfg` | Show generated CFG |
| `show dcg` | Show generated DCG clauses |
| `show interpretations` | Show generated interpretations |
| `explain <item-id>` | Explain a generated item |
| `validate` | Validate loaded evidence |
| `export <format> <path>` | Export result (prolog/cfg/json) |
| `clear` | Clear all state |
| `help` | Show help |
| `quit` | Exit the REPL |

## Example Session

```
cfg2> department neuroolfaction
Department set to: neuroolfaction
cfg2> load observations.pl
Loaded 5 evidence records.
cfg2> convert
Conversion complete.
cfg2> show cfg
<response_intensity> ::= <strong>
...
cfg2> explain r1
explanation(item_id(r1), derived_from([e1]), via_stages([...]))
cfg2> export prolog result.pl
Exported to: result.pl
cfg2> quit
Goodbye.
```

## Notes

- The REPL does not require a chatbot or internet connection.
- All state is local to the REPL session.
- Use `clear` to reset all loaded evidence and results.
