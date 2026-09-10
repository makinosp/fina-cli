import Foundation

public enum FireflyError: Error, LocalizedError {
    case invalidBaseURL(String)
    case requestFailed(status: Int, message: String)
    case decodingFailed(String)
    case networkError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidBaseURL(let v):
            return "Invalid base URL: \(v)"
        case .requestFailed(let status, let message):
            return "Request failed (\(status)): \(message)"
        case .decodingFailed(let m):
            return "Failed to decode response: \(m)"
        case .networkError(let m):
            return "Network error: \(m)"
        }
    }
}
