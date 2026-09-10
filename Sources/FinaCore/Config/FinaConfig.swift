import Foundation

/// Connection settings for a Firefly III instance.
public struct FinaConfig: Codable, Equatable, Sendable {
    public var baseURL: String
    public var token: String

    public init(baseURL: String, token: String) {
        self.baseURL = baseURL
        self.token = token
    }

    enum CodingKeys: String, CodingKey {
        case baseURL = "baseURL"
        case token
        // Accept snake_case variant as well.
        case baseURLSnake = "base_url"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let v = try? container.decode(String.self, forKey: .baseURL) {
            baseURL = v
        } else if let v = try? container.decode(String.self, forKey: .baseURLSnake) {
            baseURL = v
        } else {
            throw DecodingError.keyNotFound(
                CodingKeys.baseURL,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Missing baseURL")
            )
        }
        token = try container.decode(String.self, forKey: .token)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(baseURL, forKey: .baseURL)
        try container.encode(token, forKey: .token)
    }
}
