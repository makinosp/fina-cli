import Foundation
import Testing

@testable import FinaCore

@Test func formatterRendersAlignedPlainText() async throws {
    let output = OutputFormatter().accountsTable([
        Account(id: "1", name: "Cash", type: "asset", currencyCode: "JPY", balance: "1000"),
        Account(id: "22", name: "Bank", type: "asset", currencyCode: "JPY", balance: "20000"),
    ])
    #expect(output.contains("ID"))
    #expect(output.contains("Cash"))
    #expect(output.contains("20000"))
    #expect(!output.contains("{"))
    let lines = output.split(separator: "\n").map(String.init)
    #expect(lines.count == 3)
    // Aligned columns: NAME column starts at the same offset in every row.
    func columnOffset(_ line: String, _ needle: String) -> Int? {
        guard let range = line.range(of: needle) else { return nil }
        return line.distance(from: line.startIndex, to: range.lowerBound)
    }
    let nameOffsets = [
        columnOffset(lines[0], "NAME"),
        columnOffset(lines[1], "Cash"),
        columnOffset(lines[2], "Bank"),
    ]
    #expect(
        nameOffsets[0] != nil && nameOffsets[0] == nameOffsets[1]
            && nameOffsets[1] == nameOffsets[2])

    let created = OutputFormatter().resultLines(id: "42", action: "Created transaction")
    #expect(created == "Created transaction: 42")
}

@Test func jsonFormatterRendersValidJSON() async throws {
    let output = OutputFormatter(format: .json).accountsTable([
        Account(id: "1", name: "Cash", type: "asset", currencyCode: "JPY", balance: "1000")
    ])
    #expect(output.contains("\"accounts\""))
    #expect(output.contains("\"Cash\""))
}

@Test func tableAlignsWithVaryingLastColumn() async throws {
    let output = OutputFormatter().transactionsTable([
        TransactionView(
            id: "1", journalId: "1", date: "2026-09-01", description: "A", type: "withdrawal",
            amount: "10", source: "Cash", destination: "S"),
        TransactionView(
            id: "22", journalId: "2", date: "2026-09-02", description: "Long description here",
            type: "deposit", amount: "20000", source: "Employer",
            destination: "A very long destination name"),
    ])
    let lines = output.split(separator: "\n").map(String.init)
    #expect(lines.count == 3)
    // No trailing whitespace on any line (last column unpadded by design).
    for line in lines {
        #expect(!line.hasSuffix(" "))
    }
    // SOURCE column starts at the same offset in every row.
    func columnOffset(_ line: String, _ needle: String) -> Int? {
        guard let range = line.range(of: needle) else { return nil }
        return line.distance(from: line.startIndex, to: range.lowerBound)
    }
    let sourceOffsets = [
        columnOffset(lines[0], "SOURCE"),
        columnOffset(lines[1], "Cash"),
        columnOffset(lines[2], "Employer"),
    ]
    #expect(
        sourceOffsets[0] != nil && sourceOffsets[0] == sourceOffsets[1]
            && sourceOffsets[1] == sourceOffsets[2])
}
