# IdeaCFG CLI Reference

## Usage

```bash
swipl -q -s ideacfg.pl -- COMMAND [OPTIONS]
```

## Commands

### convert

```bash
swipl -q -s ideacfg.pl -- convert \
  --name sonata \
  --input examples/sonata.txt \
  --output generated/sonata
```

### show-operations

```bash
swipl -q -s ideacfg.pl -- show-operations \
  --input examples/economics.txt
```

### generate

```bash
swipl -q -s ideacfg.pl -- generate \
  --idea generated/sonata \
  --count 10
```

### parse

```bash
swipl -q -s ideacfg.pl -- parse \
  --idea generated/sonata \
  --text "exposition development recapitulation"
```

### test

```bash
swipl -q -s ideacfg.pl -- test \
  --idea generated/sonata
```

### help

```bash
swipl -q -s ideacfg.pl -- help
```

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | Invalid input |
| 2 | Unresolved ambiguity |
| 3 | Unsupported operation |
| 4 | Unsafe generated code |
| 5 | Test failure |
| 6 | Resource limit exceeded |
| 7 | Internal error |
