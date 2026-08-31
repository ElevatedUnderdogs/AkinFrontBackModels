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
    /// A member you follow assembled a questionnaire.
    case questionnaireAddedByFollowedMember
    /// A member you follow answered something.
    case responseAddedByFollowedMember

    /// One sentence, addressed to the member, explaining why they are being told.
    ///
    /// Lives in the contract rather than in each client so the three platforms cannot drift into
    /// three different explanations of the same event.
    ///
    /// None of these sentences names the author, and that is deliberate rather than incidental.
    /// GOAL_LOOP13 R21.12 forbids naming a creator whose visibility is `.unattributedAnnounced` or
    /// `.silent`, on every surface including this one, and a sentence that names the member only
    /// sometimes is a sentence each caller has to remember to redact. Saying "someone you follow"
    /// in all cases means the redaction cannot be forgotten, because there is nothing to forget.
    public var explanation: String {
        switch self {
        case .questionAddedToFollowedQuestionnaire:
            return "A questionnaire you follow has a new question."
        case .questionAddedByFollowedMember:
            return "Someone you follow wrote a new question."
        case .questionnaireAddedByFollowedMember:
            return "Someone you follow made a new questionnaire."
        case .responseAddedByFollowedMember:
            return "Someone you follow added a new response."
        }
    }

    /// The content kind this reason is about.
    ///
    /// Exhaustive and `default`-less, so a fifth reason cannot compile until it says what kind of
    /// content it concerns.
    public var contentKind: AuthoredContentKind {
        switch self {
        case .questionAddedToFollowedQuestionnaire: return .question
        case .questionAddedByFollowedMember: return .question
        case .questionnaireAddedByFollowedMember: return .questionnaire
        case .responseAddedByFollowedMember: return .response
        }
    }

    /// Whether this reason is news about a person rather than about a set.
    ///
    /// A questionnaire gaining a question is news about the questionnaire and names nobody. The
    /// other three exist only because a particular member acted, which is what makes them subject
    /// to the author visibility rules.
    public var isAboutTheAuthor: Bool {
        switch self {
        case .questionAddedToFollowedQuestionnaire: return false
        case .questionAddedByFollowedMember: return true
        case .questionnaireAddedByFollowedMember: return true
        case .responseAddedByFollowedMember: return true
        }
    }
}

/// An author id that has already been through the disclosure decision.
///
/// GOAL_LOOP13 R22.3. The redaction rule, that content created under `.unattributedAnnounced`
/// or `.silent` must never leave the server carrying an author id, was previously enforced by
/// each fan-out site remembering to check. A rule held in place by memory is one that a sixth
/// call site breaks, silently, in the direction nobody notices, because a payload that names
/// someone looks exactly as correct as one that does not.
///
/// This type removes the option. Its only initializer takes the content's visibility alongside
/// the author, and yields nothing for the two hiding states, so a site that forgets to redact
/// cannot construct the value it needs in order to name anybody. `FollowNotificationPayload`
/// accepts this rather than a bare `UUID?`, which means the check is not something a caller
/// performs, it is something the type performs on the caller's behalf.
///
/// Not `Codable`, deliberately. It is a gate, not a wire type; what crosses the wire is the
/// `UUID?` it yields.
public struct DisclosedAuthor: Hashable, Sendable {

    /// The id, present only when the author chose to be named.
    public let id: UUID?

    /// Decide, once, whether this author may be named.
    ///
    /// - Parameters:
    ///   - author: who wrote the content.
    ///   - visibility: what they chose.
    public init(author: UUID, visibility: AuthorVisibility) {
        switch visibility {
        case .attributed:
            self.id = author
        case .anonymized:
            self.id = nil
        }
        // Exhaustive and without a `default`, so a third visibility added later cannot inherit
        // "disclose" by accident: it stops the build here and has to say what it means.
    }

    /// The absence of an author, for notifications that are not about a person at all.
    ///
    /// A questionnaire gaining a question is news about the set. It names nobody by
    /// construction, so there is no visibility to consult and nothing to redact.
    public static let none = DisclosedAuthor()

    private init() { self.id = nil }
}

/// The thing a notification is about.
///
/// A sum type rather than four optional fields on the payload. With optionals, a payload naming
/// nothing at all is representable, and every consumer has to re-derive which of the four it is
/// holding by testing which fields happen to be populated. R21.10 requires that an empty subject be
/// unrepresentable, and the way to make a state unrepresentable is to give it no case.
///
/// Every case carries an id and the text to show, because a notification that cannot say what it is
/// about is a notification that reads "new activity", which is the thing this type exists to avoid.
public enum NotificationSubject: Codable, Hashable, Sendable {

    /// A question, and its text.
    case question(id: UUID, text: String)

    /// A response, and its text.
    case response(id: UUID, text: String)

    /// A questionnaire, and its title.
    case questionnaire(id: UUID, title: String)

    /// The subject's id, without unwrapping the case.
    public var id: UUID {
        switch self {
        case .question(let id, _): return id
        case .response(let id, _): return id
        case .questionnaire(let id, _): return id
        }
    }

    /// The text to show for the subject, without unwrapping the case.
    public var text: String {
        switch self {
        case .question(_, let text): return text
        case .response(_, let text): return text
        case .questionnaire(_, let title): return title
        }
    }

    /// Which kind of content this is, so a caller can match it against a reason's `contentKind`.
    public var kind: AuthoredContentKind {
        switch self {
        case .question: return .question
        case .response: return .response
        case .questionnaire: return .questionnaire
        }
    }
}

/// What the client renders when a followed thing gains content.
///
/// The identifier properties end `Id`, not `ID`, and that is load bearing rather than a style
/// choice. This app installs `.convertToSnakeCase` and `.convertFromSnakeCase` process wide in
/// `configure.swift`, and Foundation's conversion is not its own inverse when a name ends in an
/// acronym: the encoder writes `question_id` and the decoder reads it back as `questionId`, so a
/// property spelled with the capitalised acronym encodes fine and then fails to decode. Spelling
/// the property the way the round trip lands is the whole fix, and GOAL_LOOP13 R22.1 turns the
/// rule into a check rather than a comment.
public struct FollowNotificationPayload: Codable, Hashable, Sendable {

    /// Why this arrived.
    public let reason: NotificationReason

    /// What it is about. Never absent, by construction.
    public let subject: NotificationSubject

    /// The questionnaire involved, when the reason is a followed questionnaire.
    public let questionnaireId: UUID?

    /// The member who wrote it, and ONLY when their visibility permits naming them.
    ///
    /// Optional for two different reasons, and both matter.
    ///
    /// First, not every notification is about an author: a questionnaire you follow gaining a
    /// question is news about the set, so those carry no author at all.
    ///
    /// Second, and this is the reason that changed: GOAL_LOOP13 R21.12 requires that content
    /// created under `.unattributedAnnounced` or `.silent` leave the server carrying no author id,
    /// even to a recipient who follows that member. This field previously documented the opposite
    /// for `.unattributedAnnounced`, on the reasoning that a follower already knows who they
    /// follow. The loop rejects that reasoning: the follower knowing WHO they follow is not the
    /// same as being told THIS item was written by them, and with a small following the second
    /// fact identifies the author of a specific piece of content. So `.attributed` is now the only
    /// value that ever populates this field.
    ///
    /// The redaction is enforced on the server before the payload is built, never in the client,
    /// and since R22.3 it is enforced by the type rather than by the caller: this field can only
    /// be populated from a ``DisclosedAuthor``, whose initializer takes the visibility.
    public let authorId: UUID?

    /// Memberwise initializer.
    /// - Parameters:
    ///   - reason: why the notification was sent.
    ///   - subject: the content the notification is about.
    ///   - questionnaireId: the questionnaire involved, when applicable.
    ///   - author: the author, already through the disclosure decision. Build it with
    ///     `DisclosedAuthor(author:visibility:)`, or use `.none` for a notification about a set
    ///     rather than a person.
    public init(
        reason: NotificationReason,
        subject: NotificationSubject,
        questionnaireId: UUID?,
        author: DisclosedAuthor
    ) {
        self.reason = reason
        self.subject = subject
        self.questionnaireId = questionnaireId
        self.authorId = author.id
    }
}
