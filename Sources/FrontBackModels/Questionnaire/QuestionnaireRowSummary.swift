//
//  QuestionnaireRowSummary.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP31 items 4.1, 4.2 and 4.5. What a questionnaire row carries.
//

import Foundation

/// How a questionnaire's title is folded for comparison.
///
/// Note 34: a questionnaire's identity is the PAIR, creator and normalised title. One member may
/// not hold two questionnaires with the same normalised title. Two members each may, and those are
/// two different questionnaires holding different questions, which is why the creator's name is
/// what disambiguates them wherever both appear.
///
/// Shares ``NormalisedName`` with context names, so "Understanding Yourself" and
/// "understanding  yourself" are one title here for exactly the reasons they are one context name
/// there.
public enum QuestionnaireTitle {

    /// The longest title a questionnaire may carry, in characters.
    public static let maximumLength: Int = 64

    /// The spelling to store and show.
    ///
    /// - Parameter raw: whatever the creator typed.
    /// - Returns: the spelling to keep.
    public static func displayTitle(_ raw: String) -> String {
        NormalisedName.display(raw)
    }

    /// The key the database's uniqueness constraint is built on.
    ///
    /// - Parameter raw: whatever the creator typed.
    /// - Returns: the comparison key.
    public static func normalisedKey(_ raw: String) -> String {
        NormalisedName.key(raw)
    }

    /// Whether a title is long enough and short enough to be a questionnaire's.
    ///
    /// - Parameter raw: whatever the creator typed.
    /// - Returns: `true` when the display title is between one and ``maximumLength`` characters.
    public static func isAcceptableLength(_ raw: String) -> Bool {
        let title = displayTitle(raw)
        return title.isEmpty == false && title.count <= maximumLength
    }
}

/// Who made a questionnaire, as a row is allowed to say it.
///
/// A sum type rather than an optional name, because "made by nobody" is not a state a
/// questionnaire can be in and an optional would let one be represented. The two cases are the two
/// sentences note 33 asks a row to be able to say.
public enum QuestionnaireCreator: Codable, Hashable, Sendable {

    /// The member reading the row made it.
    case you

    /// Another member made it, and their visibility permits naming them.
    case member(id: UUID, name: String)

    /// Another member made it and chose not to be named.
    ///
    /// A separate case rather than `.member` with an empty name, because a row that must not name
    /// anybody and a row whose author's name failed to load are different facts and only one of
    /// them is a defect.
    case anonymous

    /// The row's "made by" line, written once so three platforms cannot write it three ways.
    public var attribution: String {
        switch self {
        case .you: return "Made by you"
        case .member(_, let name): return "Made by \(name)"
        case .anonymous: return "Made anonymously"
        }
    }

    /// Whether a follow control may be offered for this creator.
    ///
    /// Item 3.7: the control is ABSENT on an anonymous author, not disabled. A disabled button
    /// tells the reader there is a specific person behind the questionnaire, which is the
    /// disclosure ``DisclosedAuthor`` exists to make impossible.
    public var isFollowable: Bool {
        switch self {
        case .you, .anonymous: return false
        case .member: return true
        }
    }

    /// The member to follow, when there is one to follow.
    public var followableMemberId: UUID? {
        switch self {
        case .member(let id, _): return id
        case .you, .anonymous: return nil
        }
    }
}

/// One questionnaire, as a row shows it.
///
/// Note 33: a row carries THREE facts, not one. Who made it, how many members answered SOME of its
/// questions, and how many answered ALL of them.
///
/// The two counts are two different numbers and both are computed rather than estimated. They
/// answer different questions: "some" is how many people this questionnaire has reached at all,
/// which is its popularity, and "all" is how many finished it, which is how answerable it is. A
/// single number cannot say both, and a questionnaire that eighty people started and two finished
/// is a questionnaire with a problem that one number hides.
public struct QuestionnaireRowSummary: Codable, Hashable, Sendable, Identifiable {

    /// The questionnaire's identifier.
    public let id: UUID

    /// Its title, as its creator spelled it.
    public let title: String

    /// The key uniqueness is enforced on, alongside the creator.
    public let normalisedTitleKey: String

    /// Who made it.
    public let creator: QuestionnaireCreator

    /// How many questions it holds. Needed for the two counts to mean anything: "answered all" of
    /// a questionnaire with no questions is every member.
    public let questionCount: Int

    /// How many members have answered at least one of its questions.
    public let answeredSomeCount: Int

    /// How many members have answered every one of its questions.
    ///
    /// Always less than or equal to ``answeredSomeCount``, by construction: answering all of
    /// something is a way of answering some of it.
    public let answeredAllCount: Int

    /// Memberwise, computing the title key so a caller cannot pass one that disagrees.
    ///
    /// - Parameters:
    ///   - id: the questionnaire's identifier.
    ///   - title: its title.
    ///   - creator: who made it.
    ///   - questionCount: how many questions it holds.
    ///   - answeredSomeCount: members who answered at least one.
    ///   - answeredAllCount: members who answered every one.
    public init(
        id: UUID,
        title: String,
        creator: QuestionnaireCreator,
        questionCount: Int,
        answeredSomeCount: Int,
        answeredAllCount: Int
    ) {
        self.id = id
        self.title = QuestionnaireTitle.displayTitle(title)
        self.normalisedTitleKey = QuestionnaireTitle.normalisedKey(title)
        self.creator = creator
        self.questionCount = questionCount
        self.answeredSomeCount = answeredSomeCount
        self.answeredAllCount = answeredAllCount
    }

    /// The row's counts line, assembled once.
    ///
    /// Both numbers, labelled by what they mean rather than by the field they came from, because
    /// "80, 2" on a row says nothing at all.
    public var countsLine: String {
        let some = answeredSomeCount == 1 ? "1 member answered some" : "\(answeredSomeCount) answered some"
        let all = answeredAllCount == 1 ? "1 answered all" : "\(answeredAllCount) answered all"
        return "\(some), \(all)"
    }
}

/// Whether a questionnaire counts towards compatibility in one context.
///
/// `D4`: disabling a questionnaire in a context WITHDRAWS the member's answers from compatibility
/// in that context. The responses stay stored, so re enabling is lossless. `D2` beats it: a
/// context the member switched off takes everything in it with it, whatever a questionnaire's own
/// switch says, because the member can create that contradiction in two taps and the server has to
/// settle it rather than leaving each client to guess.
public struct QuestionnaireContextParticipation: Codable, Hashable, Sendable {

    /// The questionnaire.
    public let questionnaireId: UUID

    /// The context it is being enabled or disabled in.
    public let contextId: UUID

    /// Whether the member has the questionnaire switched on in that context.
    public let isEnabledByMember: Bool

    /// Whether the member participates in the context at all.
    public let isContextParticipating: Bool

    /// Memberwise.
    ///
    /// - Parameters:
    ///   - questionnaireId: the questionnaire.
    ///   - contextId: the context.
    ///   - isEnabledByMember: the questionnaire's own switch.
    ///   - isContextParticipating: the context's switch.
    public init(
        questionnaireId: UUID,
        contextId: UUID,
        isEnabledByMember: Bool,
        isContextParticipating: Bool
    ) {
        self.questionnaireId = questionnaireId
        self.contextId = contextId
        self.isEnabledByMember = isEnabledByMember
        self.isContextParticipating = isContextParticipating
    }

    /// Whether this questionnaire's answers count in this context.
    ///
    /// The conflict `D2` settles, resolved in ONE place so three clients cannot each guess. A
    /// context switched off wins: the member is not in that context at all, so there is nothing
    /// there for a questionnaire to count towards.
    public var countsTowardsCompatibility: Bool {
        isContextParticipating && isEnabledByMember
    }
}
