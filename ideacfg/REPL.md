# IdeaCFG REPL Reference

## Starting the REPL

```prolog
?- ideacfg.
IdeaCFG>
```

Or from the command line:
```bash
swipl -q -s ideacfg.pl
```

## Commands

| Command | Description |
|---|---|
| `new IDEA.` | Create a new idea context |
| `add TEXT.` | Add text to the current idea |
| `load FILE.` | Load idea from file |
| `analyse.` | Analyse the current idea |
| `extract operations.` | Extract operations only |
| `build cfg.` | Build the CFG only |
| `optimise.` | Run optimisations |
| `show(source).` | Show input source |
| `show(concepts).` | Show extracted concepts |
| `show(relations).` | Show extracted relations |
| `show(operations).` | Show extracted operations |
| `show(constraints).` | Show constraints |
| `show(cfg).` | Show generated CFG |
| `show(dcg).` | Show generated DCG |
| `show(prolog).` | Show generated Prolog module |
| `show(assumptions).` | Show recorded assumptions |
| `show(ambiguities).` | Show detected ambiguities |
| `show(warnings).` | Show diagnostics |
| `test.` | Run tests |
| `reset.` | Reset all state |
| `save(DIR).` | Save to directory |
| `help.` | Show this help |
| `quit.` | Exit |

## Example Session

```
IdeaCFG> new sonata.
IdeaCFG> add 'A sonata has an exposition, development and recapitulation.'.
IdeaCFG> add 'A theme may be transposed by an integer number of semitones.'.
IdeaCFG> analyse.
IdeaCFG> show(concepts).
IdeaCFG> show(operations).
IdeaCFG> show(cfg).
IdeaCFG> show(prolog).
IdeaCFG> test.
IdeaCFG> save('generated/sonata').
IdeaCFG> quit.
```
