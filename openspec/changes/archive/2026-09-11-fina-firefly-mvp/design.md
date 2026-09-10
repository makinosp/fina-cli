## Context

`Sources/fina/fina.swift` is a Hello World executable with no dependencies. Firefly III exposes `/api/v1` JSON API using Bearer Personal Access Tokens. See proposal.md for motivation and `specs/fina-cli/spec.md` for behavior contract.

## Goals / Non-Goals

**Goals:**
- Ship a SwiftPM CLI with config, accounts, and single-split transaction flows.
- Keep networking testable without a live server.

**Non-Goals:**
- Multi-split transactions, budgets, categories, piggy banks, reports.
- OAuth2 login flow, keychain storage, JSON output mode.

## Decisions

### CLI parsing via swift-argument-parser
Use `swift-argument-parser` with `fina` root plus `accounts list`, `transactions list|create|update` subcommands. Rationale: standard Swift CLI structure, automatic help generation. Alternative `Docopt`/manual parsing rejected for maintenance cost.

### Async URLSession + Codable API client
Use `URLSession` with Swift concurrency and `Codable` models for Firefly JSON:API envelopes (`data`, `attributes`, `meta.pagination`). Rationale: no extra dependencies, fits Swift 6. Alternative OpenAPI generator rejected as oversized for MVP.

### Config file at `~/.config/fina/config.json`
Fields: `baseURL`, `token`. Create parent dir on first use, set file mode 0600, fail with actionable message when missing. Rationale: matches confirmed scope; env override (`FINA_BASE_URL`, `FINA_TOKEN`) allowed as fallback without changing spec. Alternative Keychain rejected for Linux portability.

### Account reference resolution
If value parses as integer, send `*_id`; otherwise send `*_name` and let Firefly resolve or create per type rules. Rationale: satisfies ID-or-name requirement without extra lookup round trips. Alternative pre-resolving names via accounts search rejected to keep MVP simple.

### Single-split enforcement in CLI layer
`create` builds exactly one transaction object; `update` sends one object with `transaction_journal_id`. Multi-value flags are not offered. Rationale: API supports splits but MVP excludes them; fail fast with plain-text error.

### Plain-text table formatter
Fixed-width columns for lists, `key: value` lines for create/update results. Rationale: confirmed output mode; keeps formatting unit-testable without snapshot complexity.

## Risks / Trade-offs

- [Risk] Firefly self-hosted version drift in `/api/v1` fields → Mitigation: decode tolerantly with optional fields, pin tested versions in README.
- [Risk] Token stored in plain file → Mitigation: 0600 permissions plus warning in docs; Keychain deferred to later change.
- [Risk] Name-based account resolution ambiguity → Mitigation: document exact-match behavior, recommend IDs for scripts.
- [Trade-off] No pagination auto-walk in MVP → `list` honors `--limit` and page size only; full export deferred.

## Migration Plan

No migration. New `fina` binary installed via `swift build -c release`. Rollback is binary removal; config file left untouched.

## Open Questions

None blocking specs or tasks.
