import ArgumentParser
import Foundation

public struct Accounts: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "accounts",
        abstract: "Manage accounts.",
        subcommands: [AccountsList.self]
    )

    public init() {}
}

public struct AccountsList: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List accounts with balances."
    )

    public init() {}

    public func run() async throws {
        let context = CommandContext()
        let client = try context.makeClient()
        let accounts = try await client.listAccounts()
        print(context.formatter.accountsTable(accounts))
    }
}
