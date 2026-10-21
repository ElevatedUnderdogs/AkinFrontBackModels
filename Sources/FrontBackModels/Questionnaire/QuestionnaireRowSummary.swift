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

    /// The creator's picture, when the row is allowed to show one.
    ///
    /// GOAL_LOOP34, Q15, Scott 2026-10-20 10:40 PDT: "this should show the user's picture in the
    /// profile circle". The circle beside the attribution drew the first letter of the name and
    /// nothing else, because a row carried no way to find a picture: the creator case is an id
    /// and a name.
    ///
    /// NIL FOR AN ANONYMOUS CREATOR, and that is the whole reason this is a field on the ROW
    /// rather than on ``QuestionnaireCreator/member(id:name:)``. A picture names somebody as
    /// surely as a name does, so the case that refuses to name them has nowhere to put one and
    /// the server sends nothing here. R21.12's rule, applied to a face.
    ///
    /// OPTIONAL AND ADDITIVE. A server that predates it sends no key and this decodes as nil,
    /// which is what a member with no picture sends anyway, so the letter stays the fallback
    /// rather than becoming an error state.
    public let creatorImageURL: String?

    /// How many of this questionnaire's questions the member READING the row has answered.
    ///
    /// GL34 C1: gl29.html splits the list into three sections, "Yours", "Answered" and "Not
    /// answered yet", and it says a different thing under an off row in each of the last two. The
    /// off row of something answered reads "Your answers are kept and they do not count toward
    /// matching anywhere"; the off row of something never answered reads "You have not answered
    /// this, so there is nothing to withdraw". A row carried the two counts for EVERYBODY and
    /// nothing at all about the one member looking at it, so the client could not tell those two
    /// rows apart and drew the first sentence over both. Telling a member their answers are kept
    /// when they have never answered is a sentence about somebody else.
    ///
    /// NOT A BOOL, because the number is the fact and the bool is one reading of it. A row that
    /// says 3 of 10 can say "answered" today and could say "3 of 10 answered" tomorrow without
    /// another contract move; a row that says `true` has thrown the rest away.
    ///
    /// OPTIONAL AND ADDITIVE. A server that predates it sends no key, this decodes as nil, and
    /// `viewerHasAnswered` is then nil as well, which is how a client distinguishes "has not
    /// answered" from "was not told".
    public let viewerAnsweredCount: Int?

    /// Whether the member reading the row has answered any of its questions, or nil when the
    /// server did not say.
    ///
    /// Nil and false are DIFFERENT and the distinction is load bearing: nil means an older server
    /// sent no count, and a client that treated it as false would file every row under "Not
    /// answered yet" the moment it talked to one.
    public var viewerHasAnswered: Bool? {
        guard let viewerAnsweredCount else { return nil }
        return viewerAnsweredCount > 0
    }

    /// Memberwise, computing the title key so a caller cannot pass one that disagrees.
    ///
    /// - Parameters:
    ///   - id: the questionnaire's identifier.
    ///   - title: its title.
    ///   - creator: who made it.
    ///   - questionCount: how many questions it holds.
    ///   - answeredSomeCount: members who answered at least one.
    ///   - answeredAllCount: members who answered every one.
    ///   - creatorImageURL: their picture, or nil when there is none or they are not named.
    ///   - viewerAnsweredCount: how many of its questions the reader has answered, or nil when
    ///     the server does not say.
    public init(
        id: UUID,
        title: String,
        creator: QuestionnaireCreator,
        questionCount: Int,
        answeredSomeCount: Int,
        answeredAllCount: Int,
        creatorImageURL: String? = nil,
        viewerAnsweredCount: Int? = nil
    ) {
        self.id = id
        self.title = QuestionnaireTitle.displayTitle(title)
        self.normalisedTitleKey = QuestionnaireTitle.normalisedKey(title)
        self.creator = creator
        self.questionCount = questionCount
        self.answeredSomeCount = answeredSomeCount
        self.answeredAllCount = answeredAllCount
        // NEVER FOR AN ANONYMOUS CREATOR, here rather than only at the call site: a second caller
        // that forgets is the leak this type can prevent and a comment cannot.
        if case .anonymous = creator {
            self.creatorImageURL = nil
        } else {
            self.creatorImageURL = creatorImageURL
        }
        self.viewerAnsweredCount = viewerAnsweredCount
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
