//
//  ContextCatalog.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP31 items 2.1 and 2.7. The global context catalog, and a member's own derived list.
//

import Foundation

/// How a context name is folded for comparison, in the ONE place both sides import.
///
/// Decision `D1` makes contexts a global catalog, and operator note 13 makes their names case
/// insensitive, so "bouldering" and "Bouldering" are one context. The rule for deciding that has
/// to live somewhere both the server, which enforces uniqueness, and the client, which offers the
/// existing context while the member is still typing, can read. Two implementations of one fold is
/// two contexts named Bouldering the first time they disagree.
public enum ContextName {

    /// The longest name a context may carry, in characters.
    ///
    /// Stated here rather than in the sheet that enforces it, so the server's refusal and the
    /// client's character counter cannot disagree about where the ceiling is.
    public static let maximumLength: Int = 32

    /// The display name, trimmed and with internal whitespace collapsed, but NOT case folded.
    ///
    /// This is what gets stored and shown. The first spelling anybody created is the one the
    /// catalog keeps: taking the newest spelling instead would rename a context under everybody
    /// already in it, every time somebody new joined it.
    ///
    /// - Parameter raw: whatever the member typed.
    /// - Returns: the spelling to store.
    public static func displayName(_ raw: String) -> String {
        NormalisedName.display(raw)
    }

    /// The key uniqueness is enforced on.
    ///
    /// Three steps, in this order, matching `design-coverage/specs/ContextCreateSheet.md`:
    ///
    /// 1. Trim leading and trailing whitespace, and collapse any run of internal whitespace to
    ///    one space, so "  bouldering " and "bouldering" and "boulder  ing" are not three keys
    ///    where the member meant one or two.
    /// 2. Case fold, for COMPARISON only.
    /// 3. Compare.
    ///
    /// The fold itself is ``NormalisedName/key(_:)``, which contexts share with questionnaire
    /// titles, and which records why it must stay locale independent.
    ///
    /// - Parameter raw: whatever the member typed.
    /// - Returns: the normalised key.
    public static func normalisedKey(_ raw: String) -> String {
        NormalisedName.key(raw)
    }

    /// Whether two names are the same context.
    ///
    /// - Parameters:
    ///   - one: a name.
    ///   - other: another name.
    /// - Returns: `true` when they normalise to the same key.
    public static func isSameContext(_ one: String, _ other: String) -> Bool {
        NormalisedName.isSame(one, other)
    }

    /// Whether a typed name is long enough and short enough to be a context.
    ///
    /// - Parameter raw: whatever the member typed.
    /// - Returns: `true` when the normalised display name is between one and
    ///   ``maximumLength`` characters.
    public static func isAcceptableLength(_ raw: String) -> Bool {
        let name = displayName(raw)
        return name.isEmpty == false && name.count <= maximumLength
    }
}

/// One entry in the global context catalog.
///
/// `D1`: a global catalog, deduplicated on creation and ordered by popularity. The member count is
/// the popularity, and it is the catalog's own fact rather than the member's: it says how many
/// people are in the context, which is what makes one worth joining.
///
/// The normalised key travels WITH the entry rather than being recomputed by each reader. Two
/// reasons. A reader that recomputes it is a second implementation of the fold, which is what
/// ``ContextName`` exists to prevent, and a client holding the catalog can offer an existing
/// context while the member is still typing without having to fold anything itself.
public struct ContextCatalogEntry: Codable, Hashable, Sendable, Identifiable {

    /// The context's identifier.
    public let id: UUID

    /// The spelling to show, which is the first spelling anybody created.
    public let displayName: String

    /// The key uniqueness is enforced on. See ``ContextName/normalisedKey(_:)``.
    public let normalisedKey: String

    /// How many members are in this context.
    public let memberCount: Int

    /// Whether the context was created by a member rather than shipped with the app.
    ///
    /// Carried because it decides the chip's colour: `D5`'s compliance posture is that the app
    /// ships with no company created romance context, so a member created one has to be
    /// distinguishable from a built in one without the client guessing from the name.
    public let isMemberCreated: Bool

    /// Memberwise, computing the key so a caller cannot pass one that disagrees with the name.
    ///
    /// - Parameters:
    ///   - id: the context's identifier.
    ///   - displayName: whatever spelling the catalog holds.
    ///   - memberCount: how many members are in it.
    ///   - isMemberCreated: whether a member created it.
    public init(id: UUID, displayName: String, memberCount: Int, isMemberCreated: Bool) {
        self.id = id
        self.displayName = ContextName.displayName(displayName)
        self.normalisedKey = ContextName.normalisedKey(displayName)
        self.memberCount = memberCount
        self.isMemberCreated = isMemberCreated
    }
}

/// One row of a member's OWN context list.
///
/// `D6`: the list is DERIVED, never curated. A context is on it because the member answered a
/// question in that context, and it leaves when those answers do. ``yourAnsweredQuestionCount`` is
/// therefore not decoration: it is the reason the row exists, and a row carrying zero is a row
/// that should not have been sent.
///
/// Note 10 asks every row to carry BOTH numbers. One without the other leaves the member guessing
/// which fact the row is about: the member count alone makes the list read as a directory of
/// places, and the answer count alone makes it read as a log of their own activity.
public struct MemberContextEntry: Codable, Hashable, Sendable, Identifiable {

    /// The context's identifier.
    public let id: UUID

    /// The spelling to show.
    public let displayName: String

    /// The key uniqueness is enforced on.
    public let normalisedKey: String

    /// How many members are in this context.
    public let memberCount: Int

    /// How many questions THIS member has answered in it.
    ///
    /// Spelled out in full rather than as `answerCount`, because the row carries two counts and
    /// the only thing distinguishing them is whose they are.
    public let yourAnsweredQuestionCount: Int

    /// Whether the member participates in it. `D2`: off means they are not discoverable in it,
    /// not matched in it, and its questionnaires leave their feed.
    public let isParticipating: Bool

    /// Whether a member created it, which decides the chip's colour.
    public let isMemberCreated: Bool

    /// Memberwise, computing the key from the display name.
    ///
    /// - Parameters:
    ///   - id: the context's identifier.
    ///   - displayName: whatever spelling the catalog holds.
    ///   - memberCount: how many members are in it.
    ///   - yourAnsweredQuestionCount: how many questions this member answered in it.
    ///   - isParticipating: whether the member participates.
    ///   - isMemberCreated: whether a member created it.
    public init(
        id: UUID,
        displayName: String,
        memberCount: Int,
        yourAnsweredQuestionCount: Int,
        isParticipating: Bool,
        isMemberCreated: Bool
    ) {
        self.id = id
        self.displayName = ContextName.displayName(displayName)
        self.normalisedKey = ContextName.normalisedKey(displayName)
        self.memberCount = memberCount
        self.yourAnsweredQuestionCount = yourAnsweredQuestionCount
        self.isParticipating = isParticipating
        self.isMemberCreated = isMemberCreated
    }

    /// A count with a thousands separator, which is what the comp draws.
    ///
    /// `ContextListView.html` writes "10,240 members". The first version of this wrote "10240",
    /// and RULE D says the comp wins. The separator is the device's own, so a member whose region
    /// groups with a space or a point sees their own convention rather than an American one.
    ///
    /// NOTE ON A COMP TO COMP DISAGREEMENT. `ContextSearchView.html` writes the same number as
    /// "10240", without the separator. Two comps disagree about one string, and the row's own comp
    /// is the one followed, because the row is what this line belongs to. Recorded here rather
    /// than resolved silently.
    ///
    /// - Parameter count: a number of members or answers.
    /// - Returns: the number, grouped.
    static func grouped(_ count: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: count)) ?? "\(count)"
    }

    /// The row's second line, assembled once so three platforms cannot write it three ways.
    ///
    /// "412 members, 8 of your answers", with singular and plural spelled out rather than
    /// suffixed, per `design-coverage/specs/ContextListView.md`.
    public var secondLine: String {
        let members = memberCount == 1 ? "1 member" : "\(Self.grouped(memberCount)) members"
        let answers = yourAnsweredQuestionCount == 1
            ? "1 of your answers"
            : "\(Self.grouped(yourAnsweredQuestionCount)) of your answers"
        guard isParticipating == false else { return "\(members), \(answers)" }
        // Note 29 and `D9` rule 5. The clause names the context that is off and says nothing
        // about the others, because nothing about the others changed.
        //
        // THE NAME IS REPEATED, and that is the comp rather than an oversight.
        // `annotation-site/public/comps/ContextListView.html` draws "188 members, 4 of your
        // answers. Board games is off. You are not in Board games." RULE D: where the built screen
        // and the comp disagree, the comp wins. "You are not in it" reads cheaper and leaves "it"
        // to be resolved from a sentence away, which is the vagueness copy rule 4 is about.
        return "\(members), \(answers). \(displayName) is off. You are not in \(displayName)."
    }
}

/// The order a member's context list is drawn in.
///
/// Sorted here rather than in each client, because the spec's tie breaks are what make the order
/// the same between launches, and an unstable list is one a member cannot learn.
public extension Array where Element == MemberContextEntry {

    /// Descending by the member's own answer count, then by member count, then alphabetically.
    ///
    /// The member's own count first, so the context they have put the most into is at the top.
    /// The two tie breaks exist so that two rows with equal counts do not swap places between
    /// launches, which is what a sort with no total order does.
    func inContextListOrder() -> [MemberContextEntry] {
        sorted { left, right in
            if left.yourAnsweredQuestionCount != right.yourAnsweredQuestionCount {
                return left.yourAnsweredQuestionCount > right.yourAnsweredQuestionCount
            }
            if left.memberCount != right.memberCount {
                return left.memberCount > right.memberCount
            }
            return left.normalisedKey < right.normalisedKey
        }
    }
}
