## Why

Firefly III is a self-hosted personal finance manager with a REST JSON API, but there is no Swift-native CLI for daily operations. A small SwiftPM-distributed CLI lowers friction for balance checks and transaction entry from the terminal.

## What Changes

- Add `fina` CLI with `accounts list`, `transactions list`, `transactions create`, and `transactions update` commands backed by Firefly III API v1.
- Add config file support at `~/.config/fina/config.json` storing base URL and Personal Access Token with restrictive file permissions.
- Render command output as plain text tables for humans.
- Support single-split transactions only; reject multi-split payloads with a clear error.
- Support account references by ID or by name for transaction create.

## Capabilities

### New Capabilities

- `fina-cli`: Firefly III CLI covering configuration, account listing with balances, transaction listing, single-split transaction creation, and full-field transaction update.

### Modified Capabilities

None.

## Impact

- Affected code: `Sources/fina/` (new CLI, config loader, API client, output formatter), `Tests/finaTests/`.
- Dependencies: add `swift-argument-parser` via SwiftPM; use Foundation `URLSession` and `Codable`, no other runtime dependencies.
- External systems: Firefly III instance exposing `/api/v1` with a Personal Access Token.
