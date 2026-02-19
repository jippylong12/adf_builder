# Project Memory

## Architectural Decisions
- The library currently behaves as an ADF-oriented DSL with strict validations in some areas (currency, condition, country) and permissive behavior in others (cardinality in nested nodes), so DTD compliance must be validated explicitly rather than assumed.
- The builder now enforces strict DTD-style cardinality for core structures: root requires at least one prospect, prospect keeps singular customer/vendor/provider, and finance/option/colorcombination enforce required child composition.
- `id@source` is optional across nodes; `source` is serialized only when provided.
- `customer/timeframe` is a structured node; when present it must include `earliestdate` and/or `latestdate`, and both dates are validated as ISO 8601.

## Gotchas
- Passing a full element checklist is not enough for compliance: cardinality (`?`, `+`, singular vs multiple) and attribute rules (defaults, optional vs required) are where most drift occurs.
- Contact shape is constrained: one email max, one address max, phones can repeat; repeated email/address calls replace previous values.
