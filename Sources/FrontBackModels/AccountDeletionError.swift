//
//  AccountDeletionError.swift
//  AkinFrontBackModels
//
//  App Store Review Guideline 5.1.1(v) requires an in-app route to account
//  deletion. A route that can fail silently is not a route, so every way this
//  can fail is named here, on both sides of the wire, with the cause and the
//  fix in the message the person actually reads.
//

import Foundation

/// Every way account deletion can fail, each one specific.
///
/// There is deliberately no catch-all case. A generic `.unknown` would let any
/// new failure mode reach the user as "something went wrong", which is the exact
/// experience that leaves someone unable to delete their account and therefore
/// back in front of App Review. Adding a failure mode here is a compile-time
/// obligation to say what it is and what the person can do about it.
public enum AccountDeletionError: String, Codable, Sendable, Equatable, CaseIterable {

    /// No signed-in user was attached to the request.
    case notAuthenticated

    /// The access token was well formed but past its expiry.
    case tokenExpired

    /// The account referenced by the token is already gone.
    ///
    /// Deletion is idempotent, so this is reported rather than thrown when a
    /// retry arrives after a successful first pass. It exists as a case because
    /// the server still has to distinguish "already deleted" from "never existed"
    /// when it decides whether to answer success.
    case userAlreadyDeleted

    /// A row the user owns could not be removed, so the account row cannot go
    /// either without orphaning it.
    case dependentRecordsBlocking

    /// The user's stored images could not be evicted from the file store.
    case storageEvictionFailed

    /// The request never reached the server.
    case networkUnreachable

    /// The confirmation step was not completed, so nothing was deleted.
    case confirmationMismatch

    /// The server answered, but with a body this app cannot read.
    case malformedServerResponse

    /// What went wrong, in the words of the person it happened to.
    ///
    /// Every message names the cause and then the fix, in that order, because a
    /// message that only names the cause leaves the reader stuck.
    public var message: String {
        switch self {
        case .notAuthenticated:
            return "You are not signed in, so there is no account to delete. "
                + "Sign in again and reopen Settings to delete your account."
        case .tokenExpired:
            return "Your session expired before the deletion finished. "
                + "Sign in again and reopen Settings to delete your account."
        case .userAlreadyDeleted:
            return "This account has already been deleted. "
                + "Nothing further is stored, and you can close this screen."
        case .dependentRecordsBlocking:
            return "Some of your saved activity could not be removed, so your account was left intact "
                + "rather than half deleted. Try again in a few minutes."
        case .storageEvictionFailed:
            return "Your photos could not be erased, so your account was left intact "
                + "rather than deleted with your photos still stored. Try again in a few minutes."
        case .networkUnreachable:
            return "Your account was not deleted because the request never reached us. "
                + "Check your connection and try again."
        case .confirmationMismatch:
            return "The confirmation did not match, so nothing was deleted. "
                + "Type DELETE exactly as shown, then tap Delete My Account."
        case .malformedServerResponse:
            return "We could not read the response, so we cannot confirm whether your account was deleted. "
                + "Reopen the app and check Settings before trying again."
        }
    }
}

extension AccountDeletionError: LocalizedError {

    public var errorDescription: String? {
        message
    }
}
