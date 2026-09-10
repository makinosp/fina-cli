import Foundation

public struct TransactionResource: Decodable {
    public var id: String
    public var attributes: TransactionGroupAttributes

    public init(id: String, attributes: TransactionGroupAttributes) {
        self.id = id
        self.attributes = attributes
    }
}

public struct TransactionGroupAttributes: Decodable {
    public var transactions: [TransactionSplit]?

    public init(transactions: [TransactionSplit]? = nil) {
        self.transactions = transactions
    }
}

public struct TransactionSplit: Decodable {
    public var transactionJournalId: String?
    public var type: String?
    public var date: String?
    public var amount: String?
    public var description: String?
    public var sourceId: String?
    public var sourceName: String?
    public var destinationId: String?
    public var destinationName: String?
    public var currencyCode: String?

    enum CodingKeys: String, CodingKey {
        case type, date, amount, description
        case transactionJournalId = "transaction_journal_id"
        case sourceId = "source_id"
        case sourceName = "source_name"
        case destinationId = "destination_id"
        case destinationName = "destination_name"
        case currencyCode = "currency_code"
    }

    public init(
        transactionJournalId: String? = nil,
        type: String? = nil,
        date: String? = nil,
        amount: String? = nil,
        description: String? = nil,
        sourceId: String? = nil,
        sourceName: String? = nil,
        destinationId: String? = nil,
        destinationName: String? = nil,
        currencyCode: String? = nil
    ) {
        self.transactionJournalId = transactionJournalId
        self.type = type
        self.date = date
        self.amount = amount
        self.description = description
        self.sourceId = sourceId
        self.sourceName = sourceName
        self.destinationId = destinationId
        self.destinationName = destinationName
        self.currencyCode = currencyCode
    }
}

/// Flattened single-split view for listing.
public struct TransactionView: Equatable, Sendable {
    public var id: String
    public var journalId: String
    public var date: String
    public var description: String
    public var type: String
    public var amount: String
    public var source: String
    public var destination: String
    public var currencyCode: String

    public init(
        id: String,
        journalId: String,
        date: String,
        description: String,
        type: String,
        amount: String,
        source: String,
        destination: String,
        currencyCode: String = ""
    ) {
        self.id = id
        self.journalId = journalId
        self.date = date
        self.description = description
        self.type = type
        self.amount = amount
        self.source = source
        self.destination = destination
        self.currencyCode = currencyCode
    }

    public static func from(groupId: String, split: TransactionSplit) -> TransactionView {
        TransactionView(
            id: groupId,
            journalId: split.transactionJournalId ?? "",
            date: split.date ?? "",
            description: split.description ?? "",
            type: split.type ?? "",
            amount: split.amount ?? "",
            source: split.sourceName ?? split.sourceId ?? "",
            destination: split.destinationName ?? split.destinationId ?? "",
            currencyCode: split.currencyCode ?? ""
        )
    }
}

public enum SingleSplitError: Error, LocalizedError, Equatable {
    case multiSplitNotSupported

    public var errorDescription: String? {
        "Only single-split transactions are supported."
    }
}

public struct TransactionSplitRequest: Encodable {
    public var type: String
    public var date: String
    public var amount: String
    public var description: String
    public var sourceId: String?
    public var sourceName: String?
    public var destinationId: String?
    public var destinationName: String?
    public var currencyCode: String?

    enum CodingKeys: String, CodingKey {
        case type, date, amount, description
        case sourceId = "source_id"
        case sourceName = "source_name"
        case destinationId = "destination_id"
        case destinationName = "destination_name"
        case currencyCode = "currency_code"
    }

    public init(
        type: String,
        date: String,
        amount: String,
        description: String,
        source: AccountReference,
        destination: AccountReference,
        currencyCode: String? = nil
    ) {
        self.type = type
        self.date = date
        self.amount = amount
        self.description = description
        switch source {
        case .id(let v): sourceId = v
        case .name(let v): sourceName = v
        }
        switch destination {
        case .id(let v): destinationId = v
        case .name(let v): destinationName = v
        }
        self.currencyCode = currencyCode
    }
}

public struct TransactionStoreRequest: Encodable {
    public var transactions: [TransactionSplitRequest]

    public init(transactions: [TransactionSplitRequest]) throws {
        guard transactions.count == 1 else {
            throw SingleSplitError.multiSplitNotSupported
        }
        self.transactions = transactions
    }
}

public struct TransactionSplitUpdate: Encodable {
    public var transactionJournalId: String?
    public var type: String?
    public var date: String?
    public var amount: String?
    public var description: String?
    public var sourceId: String?
    public var sourceName: String?
    public var destinationId: String?
    public var destinationName: String?
    public var currencyCode: String?

    enum CodingKeys: String, CodingKey {
        case type, date, amount, description
        case transactionJournalId = "transaction_journal_id"
        case sourceId = "source_id"
        case sourceName = "source_name"
        case destinationId = "destination_id"
        case destinationName = "destination_name"
        case currencyCode = "currency_code"
    }

    public init(
        transactionJournalId: String? = nil,
        type: String? = nil,
        date: String? = nil,
        amount: String? = nil,
        description: String? = nil,
        source: AccountReference? = nil,
        destination: AccountReference? = nil,
        currencyCode: String? = nil
    ) {
        self.transactionJournalId = transactionJournalId
        self.type = type
        self.date = date
        self.amount = amount
        self.description = description
        if let source {
            switch source {
            case .id(let v): sourceId = v
            case .name(let v): sourceName = v
            }
        }
        if let destination {
            switch destination {
            case .id(let v): destinationId = v
            case .name(let v): destinationName = v
            }
        }
        self.currencyCode = currencyCode
    }
}

public struct TransactionUpdateRequest: Encodable {
    public var transactions: [TransactionSplitUpdate]

    public init(transactions: [TransactionSplitUpdate]) throws {
        guard transactions.count == 1 else {
            throw SingleSplitError.multiSplitNotSupported
        }
        self.transactions = transactions
    }
}

/// Updatable fields for `transactions update`.
public struct TransactionUpdateFields: Equatable, Sendable {
    public var type: String?
    public var date: String?
    public var amount: String?
    public var description: String?
    public var source: String?
    public var destination: String?
    public var currencyCode: String?
    public var journalId: String?

    public init(
        type: String? = nil,
        date: String? = nil,
        amount: String? = nil,
        description: String? = nil,
        source: String? = nil,
        destination: String? = nil,
        currencyCode: String? = nil,
        journalId: String? = nil
    ) {
        self.type = type
        self.date = date
        self.amount = amount
        self.description = description
        self.source = source
        self.destination = destination
        self.currencyCode = currencyCode
        self.journalId = journalId
    }

    public func makeSplit(journalId: String?) -> TransactionSplitUpdate {
        TransactionSplitUpdate(
            transactionJournalId: self.journalId ?? journalId,
            type: type,
            date: date,
            amount: amount,
            description: description,
            source: source.map(AccountReference.resolve),
            destination: destination.map(AccountReference.resolve),
            currencyCode: currencyCode
        )
    }
}
