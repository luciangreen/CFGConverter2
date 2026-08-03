# IdeaCFG Examples

## Mathematics — Quadratic Expression

See `examples/mathematics/quadratic.pl`.

Input:
```
A quadratic expression contains coefficients and a variable.
The discriminant is b squared minus four times a times c.
```

CFG: expression structure; Prolog: discriminant and roots.

## Physics — Motion

See `examples/physics/motion.pl`.

Input:
```
A motion problem contains initial velocity, acceleration and time.
Final velocity equals initial velocity plus acceleration multiplied by time.
```

CFG: problem structure; Prolog: `final_velocity/4`, `displacement/4`.

## Chemistry — Molecule

See `examples/chemistry/molecule.pl`.

Direct operations: `molar_mass/2`, `atomic_mass/2`.

## Biology — Pathway

See `examples/biology/pathway.pl`.

CFG: stage ordering; constraints: required preceding stages.

## Economics — Investment

See `examples/economics/investment.pl`.

Prolog: `compound_value(P, R, N, FV)`.

## Philosophy — Argument

See `examples/philosophy/argument.pl`.

CFG: argument structure with optional objection.

## Literature — Narrative

See `examples/literature/narrative.pl`.

CFG: narrative with bounded subplot recursion.

## Music — Melody

See `examples/music/melody.pl`.

Prolog: `transpose_pitches/3` with range validation.

## Visual Art — Composition

See `examples/visual_art/composition.pl`.

CFG: compositional alternatives; Prolog: `golden_ratio_proportion/2`.

## Computing — Algorithm

See `examples/computing/algorithm.pl`.

CFG: algorithm structure with bounded loop representation.

## History — Account

See `examples/history/account.pl`.

Prolog: `date_difference/3`, `precedes_date/2`.

## Education — Lesson

See `examples/education/lesson.pl`.

Prolog: `lesson_score/3` with division-by-zero handling.
