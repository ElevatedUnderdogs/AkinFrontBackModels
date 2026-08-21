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
public struct FollowNotificationPayload: Codable, Hashable, Sendable {
    /// Why this arrived.
    public let reason: NotificationReason
    /// The question that was added.
    public let questionID: UUID
    /// The question's text, so the notification can say something rather than "new activity".
    public let questionText: String
    /// The questionnaire the question joined, when the reason is a followed questionnaire.
    public let questionnaireID: UUID?
    /// The member who wrote it, subject to their author visibility.
    ///
    /// Optional because a question written under `.silent` or `.unattributedAnnounced` must not
    /// disclose an author here. A notification is exactly the surface where an author who chose
    /// not to be named would otherwise be named anyway.
    public let authorID: UUID?

    /// Memberwise initializer.
    /// - Parameters:
    ///   - reason: why the notification was sent.
    ///   - questionID: the question that was added.
    ///   - questionText: the question's text.
    ///   - questionnaireID: the questionnaire joined, when applicable.
    ///   - authorID: the author, only when their visibility permits naming them.
    public init(
        reason: NotificationReason,
        questionID: UUID,
        questionText: String,
        questionnaireID: UUID?,
        authorID: UUID?
    ) {
        self.reason = reason
        self.questionID = questionID
        self.questionText = questionText
        self.questionnaireID = questionnaireID
        self.authorID = authorID
    }
}
