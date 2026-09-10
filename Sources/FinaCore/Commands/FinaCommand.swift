import ArgumentParser
import Foundation

public struct Fina: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "fina",
        abstract: "Swift-native CLI for Firefly III.",
        subcommands: [Accounts.self, Transactions.self]
    )

    public init() {}
}
