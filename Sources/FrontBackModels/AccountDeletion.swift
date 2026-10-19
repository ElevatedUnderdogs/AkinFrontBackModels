//
//  AccountDeletion.swift
//  AkinFrontBackModels
//
//  The account deletion contract, stated once and shared by the app and the
//  server so neither has to reach into the other to know what deletion means.
//

import Foundation

/// What the app sends to ask for its own account to be erased.
///
/// The confirmation phrase travels with the request rather than being checked
/// only in the user interface, so a request assembled anywhere else still has to
/// carry the deliberate act with it. `Self.requiredConfirmation` is the single
/// place that phrase is defined, so the screen that asks for it and the server
/// that checks it cannot drift apart.
public struct AccountDeletionRequest: Codable, Sendable, Equatable {

    /// The exact word the person typed to confirm.
    public let confirmation: String

    /// Why they are leaving, if they chose to say. Never required, never a gate.
    ///
    /// Guideline 5.1.1(v) is about the account being deletable, so nothing here
    /// may stand between the request and the deletion. This is optional in the
    /// type as well as in the interface so the compiler enforces that.
    public let reason: String?

    /// The phrase the confirmation must match, defined once for both sides.
    public static let requiredConfirmation: String = "DELETE"

    public init(confirmation: String, reason: String? = nil) {
        self.confirmation = confirmation
        self.reason = reason
    }

    /// Whether this request carries the deliberate act, ignoring case and
    /// surrounding whitespace so a keyboard's autocapitalization or a trailing
    /// space cannot deny someone their own deletion.
    public var isConfirmed: Bool {
        confirmation.trimmingCharacters(in: .whitespacesAndNewlines)
            .caseInsensitiveCompare(Self.requiredConfirmation) == .orderedSame
    }
}

/// What the server answers, in enough detail for the app to prove it happened.
///
/// The counts are here because Apple's rule is that the data is erased, not that
/// the account is switched off, and a person is entitled to see which of their
/// records went. They also give the app something concrete to show instead of a
/// bare "done", and they give the automated test something to assert on.
public struct AccountDeletionResult: Codable, Sendable, Equatable {

    /// True when no user row, and nothing owned by that user, remains.
    public let deleted: Bool

    /// The account that was erased, echoed back so a client cannot mistake this
    /// for a response about somebody else.
    public let userID: UUID

    /// Rows removed, keyed by the table they came from.
    ///
    /// Kept as an ordinary dictionary rather than a fixed set of fields so that
    /// adding a table to the purge does not require a wire format change.
    public let removedRecordCounts: [String: Int]

    /// Stored images evicted from the file store.
    public let removedImageCount: Int

    /// When the erasure completed, from the server's clock.
    public let deletedAt: Date

    public init(
        deleted: Bool,
        userID: UUID,
        removedRecordCounts: [String: Int],
        removedImageCount: Int,
        deletedAt: Date
    ) {
        self.deleted = deleted
        self.userID = userID
        self.removedRecordCounts = removedRecordCounts
        self.removedImageCount = removedImageCount
        self.deletedAt = deletedAt
    }

    /// Every row this deletion removed, across every table.
    public var totalRemovedRecords: Int {
        removedRecordCounts.values.reduce(0, +)
    }
}

/// Anything that can delete the signed-in account.
///
/// The app depends on this rather than on a networking type, so the deletion
/// screen can be driven by a stub in a test without a server, and the real
/// implementation can be swapped without the screen knowing.
public protocol AccountDeleting {

    /// Erase the signed-in account and everything it owns.
    ///
    /// - Throws: `AccountDeletionError`, never an unlabelled error, so a caller
    ///   always has a message naming the cause and the fix.
    func deleteAccount(_ request: AccountDeletionRequest) async throws -> AccountDeletionResult
}
