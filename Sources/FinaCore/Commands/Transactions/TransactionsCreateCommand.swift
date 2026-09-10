import ArgumentParser
import Foundation

public struct TransactionsCreate: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a single-split transaction."
    )

    @Option(name: .long, help: "Transaction type: withdrawal, deposit, transfer.")
    public var type: String

    @Option(name: .long, help: "Transaction date (YYYY-MM-DD).")
    public var date: String

    @Option(name: .long, help: "Transaction amount.")
    public var amount: String

    @Option(name: .long, help: "Transaction description.")
    public var description: String

    @Option(name: .long, help: "Source account ID or name.")
    public var source: String

    @Option(name: .long, help: "Destination account ID or name.")
    public var destination: String

    @Option(name: .long, help: "Currency code.")
    public var currency: String?

    public init() {
        self.type = ""
        self.date = ""
        self.amount = ""
        self.description = ""
        self.source = ""
        self.destination = ""
    }

    public func run() async throws {
        let split = TransactionSplitRequest(
            type: type,
            date: date,
            amount: amount,
            description: description,
            source: AccountReference.resolve(source),
            destination: AccountReference.resolve(destination),
            currencyCode: currency
        )
        let context = CommandContext()
        let client = try context.makeClient()
        let id = try await client.createTransaction(split: split)
        print(context.formatter.resultLines(id: id, action: "Created transaction"))
    }
}
