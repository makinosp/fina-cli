import Foundation

/// Client-side validation for single-split transaction inputs.
/// Shape-only checks (no API calls); failures throw `TransactionInputError`
/// with plain-text messages surfaced by ArgumentParser as non-zero exits.
public enum TransactionInputError: Error, LocalizedError, Equatable {
  case missingFields([String])
  case invalidType(String)
  case invalidDate(String)
  case invalidAmount(String)
  case emptyUpdate

  public var errorDescription: String? {
    switch self {
    case .missingFields(let fields):
      return "Missing required fields: \(fields.joined(separator: ", "))."
    case .invalidType(let value):
      return "Invalid type '\(value)'. Expected one of: withdrawal, deposit, transfer."
    case .invalidDate(let value):
      return "Invalid date '\(value)'. Expected format: YYYY-MM-DD."
    case .invalidAmount(let value):
      return "Invalid amount '\(value)'. Expected a non-empty decimal string."
    case .emptyUpdate:
      return
        "No fields to update. Provide at least one of: --type, --date, --amount, --description, --source, --destination, --currency."
    }
  }
}

public struct TransactionInputValidator: Sendable {
  public static let allowedTypes: Set<String> = ["withdrawal", "deposit", "transfer"]

  public init() {}

  /// Shape check only (`YYYY-MM-DD`); calendar validity is left to the API.
  public static func isValidDateShape(_ date: String) -> Bool {
    guard date.count == 10 else { return false }
    let scalars = Array(date.unicodeScalars)
    for (i, s) in scalars.enumerated() {
      if i == 4 || i == 7 {
        guard s == "-" else { return false }
      } else {
        guard CharacterSet.decimalDigits.contains(s) else { return false }
      }
    }
    return true
  }

  private static func isBlank(_ value: String?) -> Bool {
    guard let value else { return true }
    return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  /// Validate `transactions create` inputs. Throws before any API request.
  public static func validateCreate(
    type: String,
    date: String,
    amount: String,
    description: String,
    source: String,
    destination: String
  ) throws {
    var missing: [String] = []
    if isBlank(type) { missing.append("type") }
    if isBlank(date) { missing.append("date") }
    if isBlank(amount) { missing.append("amount") }
    if isBlank(description) { missing.append("description") }
    if isBlank(source) { missing.append("source") }
    if isBlank(destination) { missing.append("destination") }
    if !missing.isEmpty {
      throw TransactionInputError.missingFields(missing)
    }
    let trimmedType = type.trimmingCharacters(in: .whitespacesAndNewlines)
    guard allowedTypes.contains(trimmedType) else {
      throw TransactionInputError.invalidType(type)
    }
    let trimmedDate = date.trimmingCharacters(in: .whitespacesAndNewlines)
    guard isValidDateShape(trimmedDate) else {
      throw TransactionInputError.invalidDate(date)
    }
    let trimmedAmount = amount.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedAmount.isEmpty else {
      throw TransactionInputError.invalidAmount(amount)
    }
  }

  /// Validate `transactions update` fields. `journalId` alone does not count as an update.
  public static func validateUpdate(_ fields: TransactionUpdateFields) throws {
    let candidates: [String?] = [
      fields.type, fields.date, fields.amount, fields.description,
      fields.source, fields.destination, fields.currencyCode,
    ]
    let hasUpdate = candidates.contains { !isBlank($0) }
    guard hasUpdate else {
      throw TransactionInputError.emptyUpdate
    }
    if let type = fields.type, !isBlank(type) {
      let trimmed = type.trimmingCharacters(in: .whitespacesAndNewlines)
      guard allowedTypes.contains(trimmed) else {
        throw TransactionInputError.invalidType(type)
      }
    }
    if let date = fields.date, !isBlank(date) {
      let trimmed = date.trimmingCharacters(in: .whitespacesAndNewlines)
      guard isValidDateShape(trimmed) else {
        throw TransactionInputError.invalidDate(date)
      }
    }
    if let amount = fields.amount, !isBlank(amount) {
      // Non-empty (post-trim) is sufficient; numeric range is API-validated.
    } else if fields.amount != nil {
      throw TransactionInputError.invalidAmount(fields.amount ?? "")
    }
  }
}
