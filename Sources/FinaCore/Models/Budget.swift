import Foundation

// Placeholder for a future domain (budgets, categories, etc.).
// No logic yet; reserves the Models-per-domain convention.
public struct BudgetPlaceholder: Equatable, Sendable {
    public var id: String
    public var name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
