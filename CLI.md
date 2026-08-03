# CLI.md — CFG Converter 2

## Commands

```
cfg2 convert INPUT [--department DEPT] [--schema SCHEMA]
cfg2 validate INPUT
cfg2 inspect INPUT
cfg2 explain ITEM_ID
cfg2 export INPUT --format FORMAT [--output PATH]
cfg2 test
cfg2 help
```

## Running via SWI-Prolog

```bash
swipl -g "use_module(prolog/cfg2_cli), cfg2_main." \
      -t halt prolog/cfg2_api.pl -- convert input.pl --department neuroolfaction
```

## Examples

```bash
# Convert a text input using original API
swipl -g "cfg2_main" prolog/cfg2_api.pl -- convert 'A cat sits on a mat.'

# Convert evidence from a Prolog terms file
swipl -g "cfg2_main" prolog/cfg2_api.pl -- convert observations.pl --department neuroolfaction

# Validate evidence
swipl -g "cfg2_main" prolog/cfg2_api.pl -- validate observations.pl

# Inspect evidence
swipl -g "cfg2_main" prolog/cfg2_api.pl -- inspect observations.pl

# Export as CFG text
swipl -g "cfg2_main" prolog/cfg2_api.pl -- export observations.pl --format cfg

# Run tests
swipl -g "cfg2_main" prolog/cfg2_api.pl -- test
```

## Exit Codes

- `0` — Success
- `1` — Fatal error (validation failure, file not found, etc.)

## Formats

- `prolog` — SWI-Prolog module source
- `cfg` — BNF-style CFG text
- `json` — JSON-encoded result
