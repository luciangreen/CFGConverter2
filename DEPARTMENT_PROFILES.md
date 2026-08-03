# DEPARTMENT_PROFILES.md — CFG Converter 2

## Overview

Each department profile declares:
- Accepted evidence types
- Output types
- Default policies

## Registered Departments

| Department | Confidence Policy | Intuition Policy |
|------------|------------------|-----------------|
| `mathematics` | numeric | strict |
| `formal_logic` | boolean | strict |
| `physics` | numeric | cautious |
| `chemistry` | numeric | cautious |
| `biology` | numeric | balanced |
| `neuroscience` | numeric | cautious |
| `neuroolfaction` | weighted_indicators | cautious |
| `psychology` | ordinal_confidence | balanced |
| `social_science` | ordinal_confidence | plural |
| `history` | ordinal_confidence | cautious |
| `philosophy` | three_valued | balanced |
| `literature` | ordinal_confidence | plural |
| `visual_arts` | ordinal_confidence | balanced |
| `music` | ordinal_confidence | plural |
| `general_humanities` | ordinal_confidence | cautious |
| `interdisciplinary` | weighted_indicators | plural |

## Department Plugin Protocol

```prolog
department_profile(+Department, -AcceptedEvidenceTypes, -OutputTypes, -DefaultPolicies).
```

Plugins in `departments/` may override or extend profiles using:

```prolog
register_department(+Dept, +AcceptedTypes, +OutputTypes, +Policies).
```

## Adding a Custom Department

```prolog
:- use_module(prolog/cfg2_departments).

:- register_department(my_department,
    [observation, annotation, expert_assessment],
    [cfg_rule, dcg_clause, interpretation],
    [confidence_policy=ordinal_confidence,
     conflict_policy=retain_all,
     intuition_policy=cautious]).
```

## Neuroolfactory Scale

```prolog
neuroolfactory_level(none,     0).
neuroolfactory_level(trace,    1).
neuroolfactory_level(weak,     2).
neuroolfactory_level(moderate, 3).
neuroolfactory_level(strong,   4).
neuroolfactory_level(intense,  5).
```

The scale is configurable by overriding facts in `departments/neuroolfaction.pl`.
