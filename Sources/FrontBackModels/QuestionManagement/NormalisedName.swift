//
//  NormalisedName.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP31 items 2.1 and 4.1. The one fold both sides import.
//

import Foundation

/// How Map Mates folds a member typed name before comparing it to another one.
///
/// WHY ONE PLACE. Two things in this product are identified by a name a member typed: a context,
/// which `D1` makes a global catalog deduplicated on creation, and a questionnaire, whose identity
/// note 34 makes the pair of creator and title. Both need the same answer to "is this the same
/// name", the server enforces it and the client predicts it so it can offer the existing thing
/// while the member is still typing, and the two must never disagree. Two implementations of one
/// fold is two contexts called Bouldering the first day they drift.
///
/// THE FOLD IS LOCALE INDEPENDENT, which is the only subtle part. `lowercased()` with no locale is
/// Unicode's own full lowercase mapping and gives the same answer on every device.
/// `lowercased(with:)` does not: in Turkish the capital I folds to the dotless ı, so a member on a
/// Turkish device typing ISTANBUL and a member on an English one typing Istanbul would land on two
/// different keys, each invisible to the other, and nobody would ever find it because nobody tests
/// in tr_TR. A global catalog's key cannot depend on who is looking at it.
public enum NormalisedName {

    /// The spelling to STORE and SHOW: trimmed, with any run of internal whitespace collapsed to
    /// one space, and the member's own capitalisation left alone.
    ///
    /// Whitespace is collapsed rather than merely trimmed because "board  games" and "board games"
    /// are the same name to everybody except a string comparison.
    ///
    /// - Parameter raw: whatever the member typed.
    /// - Returns: the spelling to keep.
    public static func display(_ raw: String) -> String {
        raw.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }

    /// The key uniqueness is enforced on: the display spelling, case folded.
    ///
    /// - Parameter raw: whatever the member typed.
    /// - Returns: the comparison key.
    public static func key(_ raw: String) -> String {
        display(raw).lowercased()
    }

    /// Whether two member typed names are the same name.
    ///
    /// - Parameters:
    ///   - one: a name.
    ///   - other: another name.
    /// - Returns: `true` when both fold to the same key.
    public static func isSame(_ one: String, _ other: String) -> Bool {
        key(one) == key(other)
    }
}
