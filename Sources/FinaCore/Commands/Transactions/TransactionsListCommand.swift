import ArgumentParser
import Foundation

public struct Transactions: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "transactions",
        abstract: "Manage transactions.",
        subcommands: [TransactionsList.self, TransactionsCreate.self, TransactionsUpdate.self]
    )

    public init() {}
}

public struct TransactionsList: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List transactions."
    )

    @Option(name: .long, help: "Maximum number of transactions.")
    public var limit: Int?

    @Option(name: .long, help: "Filter by account ID or name.")
    public var account: String?

    public init() {}

    public init(limit: Int? = nil, account: String? = nil) {
        self.limit = limit
        self.account = account
    }

    public func run() async throws {
        let context = CommandContext()
        let client = try context.makeClient()
        let transactions = try await client.listTransactions(limit: limit, account: account)
        print(context.formatter.transactionsTable(transactions))
    }
}
