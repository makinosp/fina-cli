import Foundation
import Testing
@testable import FinaCore

@Test func accountDecodingIsTolerant() async throws {
    let json = try fixtureData("accounts.json")
    let decoded = try JSONDecoder().decode(ListResponse<AccountResource>.self, from: json)
    #expect(decoded.data.count == 1)
    let account = Account.from(resource: decoded.data[0])
    #expect(account == Account(id: "1", name: "Cash", type: "asset", currencyCode: "JPY", balance: "1000"))
}

@Test func transactionDecodingIsTolerant() async throws {
    let json = try fixtureData("transaction-single.json")
    let decoded = try JSONDecoder().decode(ListResponse<TransactionResource>.self, from: json)
    let view = TransactionView.from(groupId: "42", split: decoded.data[0].attributes.transactions![0])
    #expect(view.id == "42")
    #expect(view.source == "Cash")
    #expect(view.destination == "Cafe")
}

@Test func accountReferenceResolution() async throws {
    #expect(AccountReference.resolve("123") == .id("123"))
    #expect(AccountReference.resolve("Cash") == .name("Cash"))
}

@Test func createRequestUsesIdOrName() async throws {
    let byName = TransactionSplitRequest(
        type: "withdrawal", date: "2026-09-01", amount: "10", description: "x",
        source: .name("Cash"), destination: .name("Cafe")
    )
    #expect(byName.sourceName == "Cash")
    #expect(byName.sourceId == nil)
    let byId = TransactionSplitRequest(
        type: "transfer", date: "2026-09-01", amount: "10", description: "x",
        source: .id("1"), destination: .id("2")
    )
    #expect(byId.sourceId == "1")
    #expect(byId.destinationId == "2")
}

@Test func multiSplitIsRejected() async throws {
    let split = TransactionSplitRequest(
        type: "withdrawal", date: "2026-09-01", amount: "10", description: "x",
        source: .name("A"), destination: .name("B")
    )
    do {
        _ = try TransactionStoreRequest(transactions: [split, split])
        Issue.record("expected multi-split rejection")
    } catch let error as SingleSplitError {
        #expect(error.errorDescription?.contains("single-split") == true)
    }
    do {
        _ = try TransactionUpdateRequest(transactions: [
            TransactionSplitUpdate(description: "a"),
            TransactionSplitUpdate(description: "b"),
        ])
        Issue.record("expected multi-split rejection")
    } catch let error as SingleSplitError {
        #expect(error.errorDescription?.contains("single-split") == true)
    }
}
