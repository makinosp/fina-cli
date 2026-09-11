## Context

See `proposal.md` (Why) for motivation. Current state:
- `TransactionsCreate.run()` / `TransactionsUpdate.run()` build request models with no client-side checks; invalid input reaches `FireflyClient` and the API.
- `FireflyClient.listTransactions(limit:account:)` sends `limit` as an API query param, then truncates locally with `prefix(limit)`, then filters by `account` — so combined `--account + --limit` can return fewer rows than expected.
- `ConfigLoader.load(from:env:)` mixes file-invalid vs missing branching in one guard; behavior (file > env precedence) is correct but hard to read.
- `TableFormatter.alignedTable` intentionally skips padding the last column (avoids trailing whitespace); this is undocumented and was flagged as a possible alignment bug.
- Tests cover happy paths (`ClientTests`, `ConfigTests`, `FormatterTests`) but not validation rejections or filter-then-limit ordering.

## Goals / Non-Goals

**Goals:**
- Reject invalid create/update input locally with plain-text errors and no API request.
- Define `transactions list` as filter-then-limit over reverse-chronological results.
- Simplify config error branching without changing precedence.
- Document and lock table-alignment behavior with tests.

**Non-Goals:**
- No new CLI flags, no server-side search, no JSON output mode, no auth changes.

## Decisions

### 1. Shared input validator in `FinaCore` (not inline guards in each command)
- **What:** Add a small `Sendable` validator (e.g. `TransactionInputValidator`) used by both `TransactionsCreate` and `TransactionsUpdate`; commands call it at the top of `run()` and throw a `LocalizedError` on failure.
- **Why:** Keeps command files thin (consistent with `ClientFactory`/`CommandContext` seam), makes rules unit-testable without invoking ArgumentParser, and shares type-allowlist (`withdrawal|deposit|transfer`) and `YYYY-MM-DD` shape checks.
- **Alternatives considered:** Inline `guard` in each command (duplicates rules); ArgumentParser `validate()` override (couples validation to the framework and is harder to unit test).

### 2. Filter-then-limit in `listTransactions`, API `limit` kept as hint only
- **What:** Fetch (with existing `limit` query as a fetch-size hint), flatten splits in API order, filter by `account` (exact match on source/destination, unchanged), then apply `prefix(limit)`.
- **Why:** Matches spec scenario "filter first, then at most N"; minimal change, no new API params.
- **Alternatives considered:** Pushing account filter to the Firefly query API (larger surface, account-ID vs name resolution differs per Firefly version — out of scope); removing local truncation entirely (would break `--limit` when API ignores it).

### 3. `ConfigLoader` early-return refactor, no behavior change
- **What:** Split the final guard into: (a) file existed but undecodable and env cannot fill gaps → `invalid`; (b) still missing baseURL/token → `missing`; (c) malformed URL → `invalid`. Precedence file > env unchanged.
- **Why:** Each error path becomes independently readable/testable.
- **Alternatives considered:** New error cases (unnecessary churn; existing `ConfigError.missing/invalid` already cover the matrix).

### 4. Keep last-column unpadded, document as intentional
- **What:** `alignedTable` continues to skip padding the final column to avoid trailing whitespace; add a code comment + spec scenario ("every column including the last is padded consistently" is satisfied by consistent widths — last column needs no trailing pad because nothing follows it). Fix only the real gap: fill missing columns and handle empty-row input (headers only).
- **Why:** Padding the last column would add trailing spaces to every line (worse for copy/paste and snapshot tests). The review concern is resolved by documenting intent plus a regression test with varying-length last-column values.
- **Alternatives considered:** Pad all columns including last (rejected — trailing whitespace).

### 5. Plain-text errors via thrown `LocalizedError`
- **What:** Validation failures throw a `LocalizedError` whose `errorDescription` is the user-facing message; ArgumentParser surfaces it and exits non-zero. No `print` + `exit()` in library code.
- **Why:** Consistent with existing `ConfigError`/`SingleSplitError` pattern and the plain-text output requirement.

## Risks / Trade-offs

- [Risk] Stricter create validation rejects input the API previously coerced (e.g. lowercase vs mixed-case type) → Mitigation: allowlist check is case-sensitive and documented; error message lists expected values.
- [Risk] Filter-then-limit changes row counts for combined `--account + --limit` users → Mitigation: intended spec clarification; covered by new ordering test.
- [Risk] Date check is shape-only (`YYYY-MM-DD` regex), not calendar-valid → Mitigation: deliberate; full calendar validation (leap days etc.) left to the API to avoid duplicating logic.

## Migration Plan

No migration. No flag changes. Previously valid invocations behave identically; previously invalid invocations now fail fast locally instead of at the API.

## Open Questions

None. Date strictness (shape vs calendar) is settled as shape-only per Risks above.
