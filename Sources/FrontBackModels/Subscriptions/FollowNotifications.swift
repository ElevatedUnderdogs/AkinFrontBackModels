import Foundation

// Swath N2 contracts (item 5.1): following a questionnaire or a member, and what arrives when
// something you follow gains a question.
//
// Two targets rather than one general "subscription", because they answer different questions.
// Following a questionnaire says "tell me when THIS SET grows". Following a member says "tell me
// what THIS PERSON writes, wherever they put it". Collapsing them into one target with a nullable
// id would make every consumer re-derive which kind it is holding, and would let a row exist that
// points at neither.

/// What a member is following.
///
/// Deliberately without a `default`-able "other" case. Item 5.1 requires every switch over this to
/// be exhaustive with no default anywhere, so that adding a third target later fails to compile at
/// each site that must decide what to do, rather than silently falling into a branch written before
/// the third kind existed.
public enum SubscriptionTarget: Codable, Hashable, Sendable {
    /// A specific questionnaire, by id.
    case questionnaire(UUID)
    /// A specific member, by id.
    case member(UUID)

    /// The followed thing's id, for storage and comparison.
    ///
    /// Available without unwrapping the case, because callers persisting a row need the id far
    /// more often than they need to branch on which kind it is.
    public var targetID: UUID {
        switch self {
        case .questionnaire(let id): return id
        case .member(let id): return id
        }
    }

    /// A stable string for the column that records which kind of target a row points at.
    ///
    /// Spelled out rather than derived from the case name, so renaming a Swift case cannot silently
    /// orphan every row already written under the old spelling.
    public var kind: String {
        switch self {
        case .questionnaire: return "questionnaire"
        case .member: return "member"
        }
    }
}

/// Why a notification was sent.
///
/// The reason travels with the notification rather than being inferred by the client from which
/// fields happen to be populated. A client inferring it will get it wrong the first time a
/// notification arrives for a question added by a member you follow, to a questionnaire you also
/// follow, which is one event and two plausible reasons.
public enum NotificationReason: String, Codable, CaseIterable, Sendable {
    /// A questionnaire you follow gained a question.
    case questionAddedToFollowedQuestionnaire
    /// A member you follow wrote a question.
    case questionAddedByFollowedMember

    /// One sentence, addressed to the member, explaining why they are being told.
    ///
    /// Lives in the contract rather than in each client so the three platforms cannot drift into
    /// three different explanations of the same event.
    public var explanation: String {
        switch self {
        case .questionAddedToFollowedQuestionnaire:
            return "A questionnaire you follow has a new question."
        case .questionAddedByFollowedMember:
            return "Someone you follow wrote a new question."
        }
    }
}

/// What the client renders when a followed thing gains a question.
///
/// The identifier properties end `Id`, not `ID`, and that is load bearing rather than a style
/// choice. This app installs `.convertToSnakeCase` and `.convertFromSnakeCase` process wide in
/// `configure.swift`, and Foundation's conversion is not its own inverse when a name ends in an
/// acronym: the encoder writes `question_id` and the decoder reads it back as `questionId`, so a
/// property spelled with the capitalised acronym encodes fine and then fails to decode. Spelling
/// the property the way the round trip lands is the whole fix.
public struct FollowNotificationPayload: Codable, Hashable, Sendable {
    /// Why this arrived.
    public let reason: NotificationReason
    /// The question that was added.
    public let questionId: UUID
    /// The question's text, so the notification can say something rather than "new activity".
    public let questionText: String
    /// The questionnaire the question joined, when the reason is a followed questionnaire.
    public let questionnaireId: UUID?
    /// The member who wrote it, subject to their author visibility.
    ///
    /// Optional because not every notification is about an author. A questionnaire you follow
    /// gaining a question is news about the set, not about who wrote it, and those carry no author
    /// at all.
    ///
    /// When the notification IS about an author, both announcing values name them, including
    /// `.unattributedAnnounced`. That reads backwards until you notice the two audiences are
    /// different: a follower already chose to follow this member, and withholding the name from
    /// them would leave a notification whose only reason for existing cannot be stated.
    /// `.unattributedAnnounced` withholds the name from everyone who did NOT follow them, which is
    /// the public question view, not this. `.silent` produces no notification in the first place.
    public let authorId: UUID?

    /// Memberwise initializer.
    /// - Parameters:
    ///   - reason: why the notification was sent.
    ///   - questionId: the question that was added.
    ///   - questionText: the question's text.
    ///   - questionnaireId: the questionnaire joined, when applicable.
    ///   - authorId: the author, only when their visibility permits naming them.
    public init(
        reason: NotificationReason,
        questionId: UUID,
        questionText: String,
        questionnaireId: UUID?,
        authorId: UUID?
    ) {
        self.reason = reason
        self.questionId = questionId
        self.questionText = questionText
        self.questionnaireId = questionnaireId
        self.authorId = authorId
    }
}
