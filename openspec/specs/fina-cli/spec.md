## Purpose

Provides a Swift-native terminal client for Firefly III covering account balances and single-split transaction workflows.

## Requirements

### Requirement: Configuration file loading
The system SHALL load Firefly III connection settings from `~/.config/fina/config.json` containing base URL and Personal Access Token.

#### Scenario: Valid config loads
- **WHEN** the config file exists with valid JSON containing base URL and token
- **THEN** commands authenticate against `<base-url>/api/v1` with `Authorization: Bearer <token>`

#### Scenario: Missing config fails clearly
- **WHEN** the config file is missing or invalid
- **THEN** the CLI exits non-zero with a plain-text message stating the expected path and required fields

### Requirement: Account listing
The system SHALL list accounts with ID, name, type, currency, and current balance via `fina accounts list`.

#### Scenario: List asset accounts
- **WHEN** the user runs `fina accounts list`
- **THEN** the system displays one plain-text row per account including balance

### Requirement: Balance display
The system SHALL show current balance per account in the account list output.

#### Scenario: Balance shown
- **WHEN** account data includes balance fields from the API
- **THEN** the output row includes currency code and balance amount

### Requirement: Transaction listing
The system SHALL list transactions with ID, date, description, type, amount, source, and destination via `fina transactions list`.

#### Scenario: List with limit
- **WHEN** the user runs `fina transactions list --limit N`
- **THEN** the system returns at most N transactions in reverse chronological order

#### Scenario: Filter by account
- **WHEN** the user passes `--account <id-or-name>`
- **THEN** the system filters transactions to that account

### Requirement: Single-split transaction creation
The system SHALL create withdrawal, deposit, and transfer transactions with exactly one split via `fina transactions create`.

#### Scenario: Create withdrawal by account names
- **WHEN** the user provides type, date, amount, description, source name, and destination name
- **THEN** the system creates the transaction and prints its ID in plain text

#### Scenario: Create by account IDs
- **WHEN** the user provides source and destination as numeric IDs
- **THEN** the system resolves them as IDs without name lookup

#### Scenario: Reject multi-split
- **WHEN** the payload would contain more than one split
- **THEN** the CLI rejects the input with a plain-text error stating single-split only

### Requirement: Transaction update
The system SHALL update all API-updatable fields of a single-split transaction via `fina transactions update <id>`.

#### Scenario: Update description and amount
- **WHEN** the user provides a transaction ID plus updated fields
- **THEN** the system sends a PUT request with `transaction_journal_id` and prints the updated ID

### Requirement: Plain-text output
The system SHALL render all success and error output as human-readable plain text without JSON by default.

#### Scenario: Human-readable rows
- **WHEN** any list, create, or update command succeeds
- **THEN** output uses aligned plain-text columns or key-value lines
