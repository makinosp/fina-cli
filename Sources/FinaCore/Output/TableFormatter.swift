import Foundation

/// Fixed-width plain-text tables.
public struct TableFormatter: Sendable {
    public init() {}

    public func accountsTable(_ accounts: [Account]) -> String {
        let headers = ["ID", "NAME", "TYPE", "CURRENCY", "BALANCE"]
        var rows: [[String]] = [headers]
        for a in accounts {
            rows.append([a.id, a.name, a.type, a.currencyCode, a.balance])
        }
        return alignedTable(rows)
    }

    public func transactionsTable(_ transactions: [TransactionView]) -> String {
        let headers = ["ID", "DATE", "DESCRIPTION", "TYPE", "AMOUNT", "SOURCE", "DESTINATION"]
        var rows: [[String]] = [headers]
        for t in transactions {
            rows.append([t.id, t.date, t.description, t.type, t.amount, t.source, t.destination])
        }
        return alignedTable(rows)
    }

    /// Align columns with two-space separators. The last column is intentionally
    /// left unpadded to avoid trailing whitespace; widths are still computed
    /// consistently so all preceding columns align. Missing cells are filled
    /// with "" and empty input returns "" (callers always include headers).
    func alignedTable(_ rows: [[String]]) -> String {
        guard !rows.isEmpty else { return "" }
        let columnCount = rows.map(\.count).max() ?? 0
        var widths = Array(repeating: 0, count: columnCount)
        for row in rows {
            for (i, cell) in row.enumerated() {
                widths[i] = max(widths[i], cell.count)
            }
        }
        let lines = rows.map { row -> String in
            var padded = row
            // Fill missing columns.
            while padded.count < columnCount { padded.append("") }
            return padded.enumerated().map { (i, cell) in
                if i == columnCount - 1 {
                    return cell
                }
                return cell.padding(toLength: widths[i], withPad: " ", startingAt: 0)
            }.joined(separator: "  ")
        }
        return lines.joined(separator: "\n")
    }
}
