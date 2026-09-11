import Foundation
import Testing

@testable import FinaCore

@Test func createValidationAcceptsValidInput() async throws {
  try TransactionInputValidator.validateCreate(
    type: "withdrawal", date: "2026-09-11", amount: "1500",
    description: "Coffee", source: "Cash", destination: "Cafe"
  )
}

@Test func createValidationRejectsMissingFields() async throws {
  do {
    try TransactionInputValidator.validateCreate(
      type: "", date: "2026-09-11", amount: "10",
      description: "x", source: "A", destination: "B"
    )
    Issue.record("expected missing-fields error")
  } catch let error as TransactionInputError {
    #expect(error.errorDescription?.contains("type") == true)
  }
}

@Test func createValidationRejectsInvalidTypeAndDate() async throws {
  do {
    try TransactionInputValidator.validateCreate(
      type: "bogus", date: "2026-09-11", amount: "10",
      description: "x", source: "A", destination: "B"
    )
    Issue.record("expected invalid-type error")
  } catch let error as TransactionInputError {
    #expect(error.errorDescription?.contains("withdrawal") == true)
  }
  do {
    try TransactionInputValidator.validateCreate(
      type: "deposit", date: "09/11/2026", amount: "10",
      description: "x", source: "A", destination: "B"
    )
    Issue.record("expected invalid-date error")
  } catch let error as TransactionInputError {
    #expect(error.errorDescription?.contains("YYYY-MM-DD") == true)
  }
}

@Test func updateValidationRejectsEmptyUpdate() async throws {
  do {
    try TransactionInputValidator.validateUpdate(TransactionUpdateFields())
    Issue.record("expected empty-update error")
  } catch let error as TransactionInputError {
    #expect(error == .emptyUpdate)
  }
  // journalId alone does not count as an update.
  do {
    try TransactionInputValidator.validateUpdate(TransactionUpdateFields(journalId: "7"))
    Issue.record("expected empty-update error for journalId-only")
  } catch let error as TransactionInputError {
    #expect(error == .emptyUpdate)
  }
}

@Test func updateValidationRejectsInvalidFieldValues() async throws {
  do {
    try TransactionInputValidator.validateUpdate(TransactionUpdateFields(type: "bogus"))
    Issue.record("expected invalid-type error")
  } catch let error as TransactionInputError {
    #expect(error.errorDescription?.contains("withdrawal") == true)
  }
  do {
    try TransactionInputValidator.validateUpdate(TransactionUpdateFields(date: "not-a-date"))
    Issue.record("expected invalid-date error")
  } catch let error as TransactionInputError {
    #expect(error.errorDescription?.contains("YYYY-MM-DD") == true)
  }
  // Valid partial update passes.
  try TransactionInputValidator.validateUpdate(TransactionUpdateFields(description: "Updated"))
}
