## Why

Code review of the `fina-cli` MVP found robustness gaps: missing client-side validation for required create/update fields, ambiguous `transactions list --limit` + `--account` interaction (filter applied after local limit truncation), complex config error branching, and table alignment edge cases. Fixing these now prevents invalid API requests and confusing output before wider adoption.

## What Changes

- Add client-side validation for `transactions create` (required: type/date/amount/description/source/destination; type allowlist; date `YYYY-MM-DD`; non-empty amount) with non-zero exit and plain-text error.
- Add client-side validation for `transactions update` (reject empty update with no fields; validate provided type/date/amount when present) with plain-text error.
- Clarify and fix `transactions list` semantics: apply `--account` filter before `--limit` truncation; document that limit caps the final filtered result in reverse-chronological order.
- Simplify `ConfigLoader.load` error branching into early returns (`invalid` vs `missing`) without changing resolved precedence (file > env).
- Fix `TableFormatter.alignedTable` last-column handling so rows align consistently (pad or document intentional no-pad).
- Extend tests: create-validation rejects, update empty-reject, list filter-then-limit ordering, config invalid/missing matrix, table alignment case.

## Capabilities

### New Capabilities

(none — no new user-facing capabilities; all work refines existing behavior.)

### Modified Capabilities

- `fina-cli`: Transaction listing requirement — clarify filter-then-limit ordering for `--limit` + `--account`.
- `fina-cli`: Single-split transaction creation requirement — add input validation behavior (required fields, type allowlist, date shape).
- `fina-cli`: Transaction update requirement — add empty-update rejection and per-field validation.
- `fina-cli`: Plain-text output requirement — clarify aligned-table behavior for last column.

## Impact

- Affected code: `Sources/FinaCore/Commands/Transactions/*`, `Sources/FinaCore/Networking/FireflyClient.swift` (`listTransactions`), `Sources/FinaCore/Config/ConfigLoader.swift`, `Sources/FinaCore/Output/TableFormatter.swift`, `Tests/finaTests/*`.
- No API or dependency changes; no breaking CLI flag changes (stricter validation may reject previously accepted invalid input — intended).
- No migration needed.
