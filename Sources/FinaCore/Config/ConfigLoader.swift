import Foundation

/// Loads `FinaConfig` from disk with environment fallback.
public struct ConfigLoader: Sendable {
    public static var envBaseURLKey: String { "FINA_BASE_URL" }
    public static var envTokenKey: String { "FINA_TOKEN" }

    public init() {}

    /// Default config path: `~/.config/fina/config.json`.
    public static func defaultPath() -> URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent(".config/fina/config.json")
    }

    /// Expected path string for error messages.
    public static func expectedPathString(_ path: URL?) -> String {
        (path ?? defaultPath()).path
    }

    /// Load config. File values take precedence; env vars fill gaps / act as fallback.
    /// - Parameters:
    ///   - path: Config file path. Defaults to `~/.config/fina/config.json`.
    ///   - env: Environment dictionary. Defaults to process environment.
    public func load(from path: URL? = nil, env: [String: String]? = nil) throws -> FinaConfig {
        let resolvedPath = path ?? Self.defaultPath()
        let environment = env ?? ProcessInfo.processInfo.environment

        var fileBaseURL: String?
        var fileToken: String?
        var fileExists = false
        var fileInvalidReason: String?

        if FileManager.default.fileExists(atPath: resolvedPath.path) {
            fileExists = true
            do {
                let data = try Data(contentsOf: resolvedPath)
                let decoded = try JSONDecoder().decode(FinaConfig.self, from: data)
                fileBaseURL = decoded.baseURL
                fileToken = decoded.token
                // Enforce restrictive permissions on successful load.
                try? Self.securePermissions(at: resolvedPath)
            } catch let error as DecodingError {
                fileInvalidReason = "invalid JSON (\(error.localizedDescription))"
            } catch {
                fileInvalidReason = error.localizedDescription
            }
        }

        let envBaseURL = environment[Self.envBaseURLKey]?.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty == false ? environment[Self.envBaseURLKey] : nil
        let envToken = environment[Self.envTokenKey]?.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty == false ? environment[Self.envTokenKey] : nil

        let baseURL = fileBaseURL ?? envBaseURL
        let token = fileToken ?? envToken

        guard let baseURL, !baseURL.isEmpty, let token, !token.isEmpty else {
            if fileExists, let reason = fileInvalidReason, fileBaseURL == nil || fileToken == nil {
                // File existed but was unusable and env did not fill the gap.
                if envBaseURL == nil && envToken == nil {
                    throw ConfigError.invalid(path: resolvedPath.path, reason: reason)
                }
            }
            throw ConfigError.missing(path: resolvedPath.path)
        }

        // Validate base URL shape.
        guard URL(string: baseURL) != nil else {
            throw ConfigError.invalid(path: resolvedPath.path, reason: "baseURL is not a valid URL")
        }

        return FinaConfig(baseURL: baseURL, token: token)
    }

    /// Create parent directory for first use.
    @discardableResult
    public static func ensureParentDirectory(for path: URL) throws -> Bool {
        let dir = path.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            return true
        }
        return false
    }

    /// Set file mode to 0600. No-op if file does not exist.
    public static func securePermissions(at path: URL) throws {
        guard FileManager.default.fileExists(atPath: path.path) else { return }
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: path.path)
    }

    /// Current POSIX permissions, if readable.
    public static func currentPermissions(at path: URL) -> Int? {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path.path),
              let perms = attrs[.posixPermissions] as? NSNumber
        else { return nil }
        return perms.intValue & 0o777
    }
}
