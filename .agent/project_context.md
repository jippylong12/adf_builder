# Project Context

## Constraints
- Use the ADF 1.0 DTD as the source of truth when validating schema compliance work.

## Anti-Patterns
- Treating custom DSL extensions as DTD-compliant without explicitly documenting them as extensions.

## Patterns & Recipes
- **Topic:** ADF DTD Compliance Audits
- **Rule:** Verify both element presence and exact cardinality/attribute semantics (including defaulted and optional attributes) against the DTD.
- **Reason:** Current implementation can include all major nodes while still drifting from strict DTD behavior due to cardinality and validation differences.
- **Topic:** DTD Enforcement in Builders
- **Rule:** Enforce structure where DTD requires order/cardinality: `adf` must include `prospect+`; `finance` requires `method` and `amount+`; `option` requires `optionname` + `weighting`; `colorcombination` requires at least one color + `preference`.
- **Reason:** Node presence alone is insufficient for schema compliance; nested groups need explicit validation guards.
- **Topic:** Customer Timeframe Representation
- **Rule:** Represent `customer/timeframe` as a structured node with optional `description` plus `earliestdate` and/or `latestdate`.
- **Reason:** The corrected ADF reference semantics require timeframe detail fields, and timeframe validity depends on date presence/format rules.
