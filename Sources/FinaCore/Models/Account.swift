import Foundation

public struct AccountResource: Decodable {
    public var id: String
    public var attributes: AccountAttributes

    public init(id: String, attributes: AccountAttributes) {
        self.id = id
        self.attributes = attributes
    }
}

public struct AccountAttributes: Decodable {
    public var name: String?
    public var type: String?
    public var currencyCode: String?
    public var currencySymbol: String?
    public var currentBalance: String?

    enum CodingKeys: String, CodingKey {
        case name, type
        case currencyCode = "currency_code"
        case currencySymbol = "currency_symbol"
        case currentBalance = "current_balance"
    }

    public init(
        name: String? = nil,
        type: String? = nil,
        currencyCode: String? = nil,
        currencySymbol: String? = nil,
        currentBalance: String? = nil
    ) {
        self.name = name
        self.type = type
        self.currencyCode = currencyCode
        self.currencySymbol = currencySymbol
        self.currentBalance = currentBalance
    }
}

/// Domain account used by commands and formatter.
public struct Account: Equatable, Sendable {
    public var id: String
    public var name: String
    public var type: String
    public var currencyCode: String
    public var balance: String

    public init(id: String, name: String, type: String, currencyCode: String, balance: String) {
        self.id = id
        self.name = name
        self.type = type
        self.currencyCode = currencyCode
        self.balance = balance
    }

    public static func from(resource: AccountResource) -> Account {
        Account(
            id: resource.id,
            name: resource.attributes.name ?? "",
            type: resource.attributes.type ?? "",
            currencyCode: resource.attributes.currencyCode ?? "",
            balance: resource.attributes.currentBalance ?? ""
        )
    }
}

/// Account reference: numeric strings become IDs, otherwise names.
public enum AccountReference: Equatable, Sendable {
    case id(String)
    case name(String)

    public static func resolve(_ raw: String) -> AccountReference {
        if Int(raw) != nil {
            return .id(raw)
        }
        return .name(raw)
    }
}
