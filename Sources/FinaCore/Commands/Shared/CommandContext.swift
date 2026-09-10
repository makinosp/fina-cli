import ArgumentParser
import Foundation

/// Shared helpers for commands (client construction, output).
public struct CommandContext: Sendable {
    public var clientFactory: ClientFactory
    public var formatter: OutputFormatter

    public init(clientFactory: ClientFactory = ClientFactory(), formatter: OutputFormatter = OutputFormatter()) {
        self.clientFactory = clientFactory
        self.formatter = formatter
    }

    public func makeClient() throws -> FireflyClient {
        try clientFactory.makeClient()
    }
}
