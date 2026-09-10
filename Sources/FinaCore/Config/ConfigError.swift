import Foundation

/// Errors thrown while loading configuration.
public enum ConfigError: Error, LocalizedError, Equatable {
    case missing(path: String)
    case invalid(path: String, reason: String)

    public var errorDescription: String? {
        switch self {
        case .missing(let path):
            return "Missing config at \(path). Expected JSON with required fields: baseURL, token."
        case .invalid(let path, let reason):
            return "Invalid config at \(path): \(reason). Expected JSON with required fields: baseURL, token."
        }
    }
}
