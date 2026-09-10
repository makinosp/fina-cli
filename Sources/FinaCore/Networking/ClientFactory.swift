import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Shared factory for building API clients from loaded config.
/// Keeps command files thin and gives auth expansion a single seam.
public struct ClientFactory: Sendable {
    public var session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func makeClient(config: FinaConfig? = nil) throws -> FireflyClient {
        let resolved = try config ?? ConfigLoader().load()
        return try FireflyClient(config: resolved, session: session)
    }
}
