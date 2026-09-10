import Foundation

/// Minimal API surface used by commands. Allows mocked clients in tests.
public protocol FireflyAPI: Sendable {
    func listAccounts() async throws -> [Account]
    func listTransactions(limit: Int?, account: String?) async throws -> [TransactionView]
    func createTransaction(split: TransactionSplitRequest) async throws -> String
    func updateTransaction(id: String, fields: TransactionUpdateFields) async throws -> String
}
