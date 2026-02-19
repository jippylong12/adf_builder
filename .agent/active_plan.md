# Active Plan

## Request
Revert timeframe handling to structured node model and align tests with corrected spec source.

## Hard Constraints
- Use ADF DTD/spec behavior as project source of truth, while honoring confirmed user corrections.
- Maintain current validated changes for other DTD items (root/prospect/finance/option/color/id/contact rules).

## Steps
1. Restore `Customer#timeframe` block API and `Timeframe` node with `description`, `earliestdate`, `latestdate`.
2. Enforce validation: if `timeframe` exists, require `earliestdate` and/or `latestdate`; validate ISO 8601 for dates.
3. Update specs so they assert structured timeframe behavior (`description`, `earliestdate`, `latestdate`).
4. Run full test suite and verify no regressions.
