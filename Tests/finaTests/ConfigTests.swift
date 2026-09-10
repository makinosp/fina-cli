import Foundation
import Testing
@testable import FinaCore

@Test func configLoadsValidFile() async throws {
    try withTempDir { dir in
        let path = dir.appendingPathComponent("config.json")
        try #"{"baseURL": "https://demo.example", "token": "abc"}"#.write(to: path, atomically: true, encoding: .utf8)
        let config = try ConfigLoader().load(from: path, env: [:])
        #expect(config.baseURL == "https://demo.example")
        #expect(config.token == "abc")
    }
}

@Test func configMissingThrowsActionableError() async throws {
    try withTempDir { dir in
        let path = dir.appendingPathComponent("missing.json")
        do {
            _ = try ConfigLoader().load(from: path, env: [:])
            Issue.record("expected missing config error")
        } catch let error as ConfigError {
            #expect(error.errorDescription?.contains(path.path) == true)
            #expect(error.errorDescription?.contains("baseURL") == true)
            #expect(error.errorDescription?.contains("token") == true)
        }
    }
}

@Test func configInvalidThrowsActionableError() async throws {
    try withTempDir { dir in
        let path = dir.appendingPathComponent("config.json")
        try "not-json".write(to: path, atomically: true, encoding: .utf8)
        do {
            _ = try ConfigLoader().load(from: path, env: [:])
            Issue.record("expected invalid config error")
        } catch let error as ConfigError {
            #expect(error.errorDescription?.contains(path.path) == true)
        }
    }
}

@Test func configEnvFallback() async throws {
    try withTempDir { dir in
        let path = dir.appendingPathComponent("missing.json")
        let config = try ConfigLoader().load(
            from: path,
            env: ["FINA_BASE_URL": "https://env.example", "FINA_TOKEN": "env-token"]
        )
        #expect(config.baseURL == "https://env.example")
        #expect(config.token == "env-token")
    }
}

@Test func configFilePermissionsAreRestricted() async throws {
    try withTempDir { dir in
        let path = dir.appendingPathComponent("config.json")
        try #"{"baseURL": "https://demo.example", "token": "abc"}"#.write(to: path, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: path.path)
        _ = try ConfigLoader().load(from: path, env: [:])
        #expect(ConfigLoader.currentPermissions(at: path) == 0o600)
    }
}
