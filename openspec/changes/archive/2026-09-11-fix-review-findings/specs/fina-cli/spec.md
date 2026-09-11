## MODIFIED Requirements

### Requirement: Transaction listing
The system SHALL list transactions with ID, date, description, type, amount, source, and destination via `fina transactions list`.

#### Scenario: List with limit
- **WHEN** the user runs `fina transactions list --limit N`
- **THEN** the system returns at most N transactions in reverse chronological order

#### Scenario: Filter by account
- **WHEN** the user passes `--account <id-or-name>`
- **THEN** the system filters transactions to that account

#### Scenario: Filter applies before limit
- **WHEN** the user passes both `--account <id-or-name>` and `--limit N`
- **THEN** the system filters to the matching account first and returns at most N of the filtered transactions in reverse chronological order

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

#### Scenario: Reject missing required fields
- **WHEN** the user omits any of type, date, amount, description, source, or destination
- **THEN** the CLI exits non-zero with a plain-text error naming the missing fields and sends no API request

#### Scenario: Reject invalid type or date
- **WHEN** the user provides a type other than withdrawal, deposit, or transfer, or a date not in `YYYY-MM-DD` shape
- **THEN** the CLI exits non-zero with a plain-text error stating the expected values and sends no API request

### Requirement: Transaction update
The system SHALL update all API-updatable fields of a single-split transaction via `fina transactions update <id>`.

#### Scenario: Update description and amount
- **WHEN** the user provides a transaction ID plus updated fields
- **THEN** the system sends a PUT request with `transaction_journal_id` and prints the updated ID

#### Scenario: Reject empty update
- **WHEN** the user provides a transaction ID with no updatable fields
- **THEN** the CLI exits non-zero with a plain-text error stating at least one field is required and sends no API request

#### Scenario: Reject invalid update field values
- **WHEN** the user provides an invalid type or malformed date in an update
- **THEN** the CLI exits non-zero with a plain-text error stating the expected values and sends no API request

### Requirement: Plain-text output
The system SHALL render all success and error output as human-readable plain text without JSON by default.

#### Scenario: Human-readable rows
- **WHEN** any list, create, or update command succeeds
- **THEN** output uses aligned plain-text columns or key-value lines

#### Scenario: Aligned columns
- **WHEN** a list command renders a table
- **THEN** every column including the last is padded consistently so rows align, and empty tables render headers only
