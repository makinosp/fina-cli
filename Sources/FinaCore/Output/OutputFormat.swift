import Foundation

/// Output format selector. `plain` is the current default; `json` is a stub seam.
public enum OutputFormat: String, Equatable, Sendable {
    case plain
    case json
}

public protocol OutputRendering: Sendable {
    func accountsTable(_ accounts: [Account]) -> String
    func transactionsTable(_ transactions: [TransactionView]) -> String
    func resultLines(id: String, action: String) -> String
}

/// Plain-text rendering for humans. No JSON output by default.
public struct OutputFormatter: OutputRendering, Sendable {
    public var format: OutputFormat

    public init(format: OutputFormat = .plain) {
        self.format = format
    }

    public func accountsTable(_ accounts: [Account]) -> String {
        switch format {
        case .plain:
            return TableFormatter().accountsTable(accounts)
        case .json:
            return JSONFormatter().accountsJSON(accounts)
        }
    }

    public func transactionsTable(_ transactions: [TransactionView]) -> String {
        switch format {
        case .plain:
            return TableFormatter().transactionsTable(transactions)
        case .json:
            return JSONFormatter().transactionsJSON(transactions)
        }
    }

    public func resultLines(id: String, action: String) -> String {
        switch format {
        case .plain:
            return ResultFormatter().resultLines(id: id, action: action)
        case .json:
            return JSONFormatter().resultJSON(id: id, action: action)
        }
    }
}
