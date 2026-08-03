# EXAMPLES.md — CFG Converter 2

## Example 1: Mathematics (Section 29)

```prolog
?- load_evidence(formula_terms, [
       formula(f1, plus(2, 3, 5)),
       formula(f2, implies(even(x), integer(x))),
       relation(sequence, [assumption, derivation, conclusion])
   ], [department(mathematics)], Evidence),
   evidence_to_cfg(math_proof, mathematics, Evidence, Result).
```

Expected conceptual CFG:
```
<proof> ::= <assumption> <derivation> <conclusion>
```

---

## Example 2: Neuroolfactory Measurement (Section 30)

```prolog
?- evidence_to_cfg(rose_study, neuroolfaction, [
       evidence(e1, neuroolfaction, qualitative_measurement,
                response_intensity, strong, neuroolfactory_unit,
                context(stimulus(rose)), 0.82,
                provenance(observer(o1)), time(t1), location(lab), [])
   ], Result).
```

Expected interpretation:
```prolog
interpretation(
    strong_olfactory_response,
    confidence(0.82),
    evidence([e1]),
    alternatives([])
).
```

---

## Example 3: Humanities Intuition (Section 31)

```prolog
?- use_module(prolog/cfg2_intuition),
   intuition_to_interpretation(
       intuition(in1, expert(reader_1), poem(p1),
                 theme(displacement),
                 [indicator(repeated_departure_images),
                  indicator(fragmented_geography)],
                 0.68, [theme(memory), theme(exile)],
                 stanza_range(1, 5),
                 provenance(annotation_set(a1))),
       cautious,
       Result
   ).
```

Expected output (cautious policy with confidence 0.68 > 0.6):
```prolog
interpretation(theme(displacement), confidence(0.68),
               status(supported_not_proven), evidence([]))
```

---

## Example 4: Conflicting Historical Evidence (Acceptance Test D)

```prolog
?- evidence_to_cfg(letter_conflict, history, [
       evidence(e1, history, archival_record, letter_42, dated_1812,
                year, context(archive_3), 0.7, provenance(archivist(a1)),
                unknown, archive_3, []),
       evidence(e2, history, archival_record, letter_42, post_1815,
                year, context(archive_3), 0.65, provenance(analyst(a2)),
                unknown, archive_3, [])
   ], [conflict_policy(retain_all)], Result).
```

Both conflicting records are retained. No silent resolution.

---

## Example 5: Hybrid Text + Evidence

```prolog
?- hybrid_to_cfg(rose_response, neuroolfaction,
       ['A strong recognised floral response indicates category A.'],
       [csv('observations.csv', olfactory_schema)],
       [confidence_policy(weighted_indicators)],
       Result).
```

---

## Running Examples

```bash
swipl -g "[examples/mathematics/proof_example], run_example, halt." prolog/cfg2_api.pl
swipl -g "[examples/neuroolfaction/olfactory_example], run_example, halt." prolog/cfg2_api.pl
swipl -g "[examples/history/historical_conflict_example], run_example, halt." prolog/cfg2_api.pl
swipl -g "[examples/literature/humanities_intuition_example], run_example, halt." prolog/cfg2_api.pl
```
