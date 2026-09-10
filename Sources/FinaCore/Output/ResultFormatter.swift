import Foundation

/// Key-value lines for create/update results.
public struct ResultFormatter: Sendable {
    public init() {}

    public func resultLines(id: String, action: String) -> String {
        "\(action): \(id)"
    }
}
