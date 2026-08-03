# EVIDENCE_MODEL.md — CFG Converter 2

## Canonical Evidence Term

```prolog
evidence(
    EvidenceId,       % atom or integer — unique identifier
    Department,       % atom — e.g. neuroolfaction, history, mathematics
    Type,             % atom — see valid_evidence_type/1
    Subject,          % atom — what the evidence is about
    Value,            % any — the observed or measured value
    Unit,             % atom — measurement unit or scale
    Context,          % term — context(...)
    Confidence,       % number 0.0–1.0, ordinal/1, interval/2, or unknown
    Provenance,       % term — provenance(...)
    Time,             % atom or time term
    Location,         % atom or location term
    Metadata          % list — additional key-value pairs
).
```

## Example

```prolog
evidence(
    e17,
    neuroscience,
    qualitative_measurement,
    odour_response,
    strong,
    neuroolfactory_unit,
    context(participant(p1), stimulus(rose)),
    0.82,
    provenance(observer(dr_smith), instrument(panel_v2)),
    time('2026-08-03T14:00:00+10:00'),
    location(laboratory_2),
    [scale(ordinal), consent_recorded(true)]
).
```

## Valid Evidence Types

- `qualitative_measurement` — ordinal or nominal scale measurement
- `quantitative_measurement` — numeric measurement with a unit
- `observation` — unstructured or semi-structured observation
- `formula` — mathematical formula or logical expression
- `indicator` — humanities or intuitional indicator
- `intuition` — expert judgement as evidence
- `annotation` — textual annotation
- `classification` — categorical classification
- `judgement` — expert judgement
- `provenance_record` — archival provenance
- `instrument_reading` — instrument or sensor reading
- `expert_assessment` — formal expert assessment
- `tacit_observation` — embodied or tacit knowledge record
- `temporal_observation` — time-indexed observation
- `spatial_observation` — location-indexed observation
- `trust_judgement` — trust or reliability assessment
- `confidence_weighted` — confidence-weighted aggregate
- `archival_record` — historical archival record
- `sensor_data` — sensor or instrument data
- `image_metadata` — image or visual metadata
- `audio_metadata` — audio or signal metadata

## Valid Confidence Values

| Form | Description |
|------|-------------|
| `0.0`–`1.0` | Numeric probability or score |
| `ordinal(V)` | V ∈ {none, very_low, low, moderate, high, very_high, certain} |
| `interval(Lo, Hi)` | Confidence interval [Lo, Hi] ⊆ [0, 1] |
| `count(N, Total)` | N of Total trials support the conclusion |
| `unknown` | Confidence not assessed |
| `not_applicable` | Confidence concept does not apply |

## Missing Values

```prolog
missing.
unknown.
not_recorded.
not_applicable.
below_detection_limit.
```

## Conflict Representation

```prolog
evidence_conflict(
    ConflictId,
    Subject,
    EvidenceIds,
    ConflictType,
    ResolutionStatus
).
```

Default conflict policy: `retain_all`. Conflicts are never silently resolved.
