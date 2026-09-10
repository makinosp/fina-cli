import Foundation
import Testing
@testable import FinaCore

@Suite(.serialized) struct MockClientTests {
    @Test func clientListsAccountsWithBearerAuth() async throws {
        let session = makeMockSession()
        let url = URL(string: "https://demo.example")!
        let client = FireflyClient(baseURL: url, token: "secret", session: session)
        let json = try fixtureData("accounts.json")
        nonisolated(unsafe) var seenAuth: String?
        nonisolated(unsafe) var seenURL: String?
        MockURLProtocol.handler = { request in
            seenAuth = request.value(forHTTPHeaderField: "Authorization")
            seenURL = request.url?.absoluteString
            return (httpResponse(url: request.url!), json)
        }
        defer { MockURLProtocol.handler = nil }
        let accounts = try await client.listAccounts()
        #expect(seenAuth == "Bearer secret")
        #expect(seenURL?.contains("/api/v1/accounts") == true)
        #expect(accounts.count == 1)
        #expect(accounts[0].balance == "1000")
    }

    @Test func clientListsTransactionsWithLimitAndFilter() async throws {
        let session = makeMockSession()
        let client = FireflyClient(baseURL: URL(string: "https://demo.example")!, token: "t", session: session)
        let json = try fixtureData("transactions.json")
        nonisolated(unsafe) var seenURLs: [String] = []
        MockURLProtocol.handler = { request in
            seenURLs.append(request.url?.absoluteString ?? "")
            return (httpResponse(url: request.url!), json)
        }
        defer { MockURLProtocol.handler = nil }
        let limited = try await client.listTransactions(limit: 1, account: nil)
        #expect(limited.count == 1)
        let filtered = try await client.listTransactions(limit: nil, account: "Bank")
        #expect(filtered.count == 1)
        #expect(filtered[0].destination == "Bank")
        #expect(seenURLs.count == 2)
        #expect(seenURLs[0].contains("limit=1") == true)
    }

    @Test func clientCreatesTransactionWithIdOrName() async throws {
        let session = makeMockSession()
        let client = FireflyClient(baseURL: URL(string: "https://demo.example")!, token: "t", session: session)
        nonisolated(unsafe) var seenMethod: String?
        nonisolated(unsafe) var seenBody: String = ""
        MockURLProtocol.handler = { request in
            seenMethod = request.httpMethod
            seenBody = String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""
            let json = try fixtureData("transaction-created.json")
            return (httpResponse(url: request.url!), json)
        }
        defer { MockURLProtocol.handler = nil }
        let split = TransactionSplitRequest(
            type: "withdrawal", date: "2026-09-01", amount: "10", description: "Coffee",
            source: .name("Cash"), destination: .name("Cafe")
        )
        let id = try await client.createTransaction(split: split)
        #expect(seenMethod == "POST")
        #expect(seenBody.contains("source_name"))
        #expect(id == "99")
    }

    @Test func clientUpdatesTransactionViaPut() async throws {
        let session = makeMockSession()
        let client = FireflyClient(baseURL: URL(string: "https://demo.example")!, token: "t", session: session)
        nonisolated(unsafe) var seenMethod: String?
        nonisolated(unsafe) var seenURL: String?
        nonisolated(unsafe) var seenBody: String = ""
        MockURLProtocol.handler = { request in
            seenMethod = request.httpMethod
            seenURL = request.url?.absoluteString
            seenBody = String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""
            let json = try fixtureData("transaction-updated.json")
            return (httpResponse(url: request.url!), json)
        }
        defer { MockURLProtocol.handler = nil }
        let updated = try await client.updateTransaction(
            id: "42",
            fields: TransactionUpdateFields(description: "Updated", journalId: "7")
        )
        #expect(seenMethod == "PUT")
        #expect(seenURL?.contains("/api/v1/transactions/42") == true)
        #expect(seenBody.contains("transaction_journal_id"))
        #expect(seenBody.contains("Updated"))
        #expect(updated == "42")
    }
}
