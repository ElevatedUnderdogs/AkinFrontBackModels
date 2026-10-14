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
    ///
    /// THE TWO NUMBERS AND NOTHING ELSE. The off clause is NOT here, and the first version of this
    /// property had it: it appended "<Name> is off. You are not in <Name>." whenever
    /// `isParticipating` was false. That made the clause a property of the MODEL, and the clause is
    /// a property of one ROW TREATMENT on one screen, which is where ``offClause`` now lives and
    /// where `ContextListView` appends it. Two things went wrong while it was here, both reported
    /// by a reviewer reading the comps rather than the code:
    ///
    /// 1. In the all off state every row repeated it, so a member with three contexts off read six
    ///    sentences saying the same thing and then a card saying it a seventh time.
    ///    `ContextListView.html` section `data-state="all-off"` draws three rows whose second lines
    ///    are the two numbers alone, and carries the single card.
    /// 2. It leaked onto `ContextSearchView`'s "Yours" rows, whose comp shows only the two numbers,
    ///    because that screen draws this same property.
    ///
    /// A reader who only ever needs the full line for one row, which is the single off context
    /// case, composes it from this and ``offClause``.
    public var secondLine: String {
        let members = memberCount == 1 ? "1 member" : "\(Self.grouped(memberCount)) members"
        return "\(members), \(Self.yourAnswersLine(yourAnsweredQuestionCount))"
    }

    /// How many questions the member has answered, as the row and the questions screen both say it.
    ///
    /// Shared between the two rather than written twice, because the caption under the context's
    /// own questions screen is the same clause as the second half of this row's second line, and
    /// two implementations of one string is how "8 of your answers" becomes "8 answers" on one
    /// screen. Singular and plural spelled out rather than suffixed, per
    /// `design-coverage/specs/ContextListView.md`.
    ///
    /// - Parameter count: how many questions the member answered.
    /// - Returns: "8 of your answers", or "1 of your answers".
    public static func yourAnswersLine(_ count: Int) -> String {
        count == 1 ? "1 of your answers" : "\(grouped(count)) of your answers"
    }

    /// The clause a row adds when THIS context is off and the others are not.
    ///
    /// Note 29 and `D9` rule 5. The clause names the context that is off and says nothing about the
    /// others, because nothing about the others changed. Empty while the member is participating,
    /// so a caller cannot show it for a context that is on.
    ///
    /// THE NAME IS REPEATED, and that is the comp rather than an oversight.
    /// `annotation-site/public/comps/ContextListView.html` draws "188 members, 4 of your answers.
    /// Board games is off. You are not in Board games." RULE D: where the built screen and the comp
    /// disagree, the comp wins. "You are not in it" reads cheaper and leaves "it" to be resolved
    /// from a sentence away, which is the vagueness copy rule 4 is about.
    ///
    /// WHO DECIDES WHETHER TO SHOW IT. The row, not this type, and that is the whole reason it is
    /// separate: the clause is suppressed in the all off state, and an entry cannot know whether
    /// every OTHER entry is off.
    public var offClause: String {
        guard isParticipating == false else { return "" }
        return "\(displayName) is off. You are not in \(displayName)."
    }
}

/// One question the member has answered in one context, with the selection they made.
///
/// WHAT IT IS FOR. The row of `ContextListView` pushes to the questions the member answered in
/// that context, and `design-coverage/specs/ContextListView.md` makes that destination the whole
/// answer to "how do I get this context off my list": there is no remove control, so the member
/// changes the answers and the row leaves when the last one does. The screen cannot be built
/// without the list, and the list is this.
///
/// IT IS PER CONTEXT AND THE QUESTION IS NOT. `D7`: a question is context independent, and the
/// same question can carry different selections in two contexts. So the context is in the REQUEST
/// and not in this type, and ``selection`` is the selection in the context that was asked about.
///
/// ``selection`` IS OPTIONAL rather than defaulted to an empty string. A member can answer a
/// question in a context and have the option they chose deleted by its author afterwards, and a
/// row that renders an empty second line is indistinguishable from one whose answer is still
/// there. The screen says what is true in each case rather than drawing a blank.
public struct ContextAnsweredQuestion: Codable, Hashable, Sendable, Identifiable {

    /// The question's identifier, which is what the row opens.
    public let id: UUID

    /// The question, as it is written.
    public let text: String

    /// What the member chose in the context that was asked about, when the option is still there.
    public let selection: String?

    /// Memberwise.
    ///
    /// - Parameters:
    ///   - id: the question's identifier.
    ///   - text: the question text.
    ///   - selection: the member's selection in the context asked about.
    public init(id: UUID, text: String, selection: String?) {
        self.id = id
        self.text = text
        self.selection = selection
    }
}

/// The order a member's context list is drawn in.
///
/// Sorted here rather than in each client, because the spec's tie breaks are what make the order
/// the same between launches, and an unstable list is one a member cannot learn.
// `public` ON THE MEMBER AND NOT ON THE EXTENSION. A public extension makes every member
// public by default, including any added later by somebody who did not mean to widen the
// package's surface. Spelling it on the one function keeps the decision at the declaration.
extension Array where Element == MemberContextEntry {

    /// Descending by the member's own answer count, then by member count, then alphabetically.
    ///
    /// The member's own count first, so the context they have put the most into is at the top.
    /// The two tie breaks exist so that two rows with equal counts do not swap places between
    /// launches, which is what a sort with no total order does.
    public func inContextListOrder() -> [MemberContextEntry] {
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
