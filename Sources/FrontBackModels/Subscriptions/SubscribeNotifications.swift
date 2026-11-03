import Foundation

// Swath N2 contracts (item 5.1): subscribing to a questionnaire or a member, and what
// arrives when something you subscribe to gains a question.
//
// Two targets rather than one general "subscription", because they answer different questions.
// Subscribing to a questionnaire says "tell me when THIS SET grows". Subscribing to a member
// says "tell me what THIS PERSON writes, wherever they put it". Collapsing them into one target with a nullable
// id would make every consumer re-derive which kind it is holding, and would let a row exist that
// points at neither.

/// What a member subscribes to.
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

    /// The subscribed thing's id, for storage and comparison.
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
/// notification arrives for a question added by a member you subscribe to, to a questionnaire
/// you also subscribe to, which is one event and two plausible reasons.
public enum NotificationReason: String, Codable, CaseIterable, Sendable {

    /// A questionnaire you subscribe to gained a question.
    case questionAddedToSubscribedQuestionnaire = "questionAddedToFollowedQuestionnaire"

    /// A member you subscribe to wrote a question.
    case questionAddedBySubscribedMember = "questionAddedByFollowedMember"

    /// A member you subscribe to assembled a questionnaire.
    case questionnaireAddedBySubscribedMember = "questionnaireAddedByFollowedMember"

    /// A member you subscribe to answered something.
    case responseAddedBySubscribedMember = "responseAddedByFollowedMember"

    // THE RAW VALUES ABOVE ARE WRITTEN OUT, AND THEY ARE THE RETIRED FOLLOW SPELLINGS.
    //
    // GOAL_LOOP37 decision D5. The Swift cases were renamed from follow to subscribe; the raw
    // values were not, and this is the one place in the rename where the OLD spelling is still
    // what gets written. A reason travels in both directions: the server encodes it into every
    // push payload and into `SubscribeNotificationPreferences.disabledReasons`, and the shipped
    // App Store app DECODES it. A build that wrote the subscribe spelling would hand that
    // binary a value it has no case for, so its notification preferences screen and its push
    // router would start throwing, and the rows already stored against the old spelling would
    // stop matching as well. Spelled out rather than derived, so a later rename of a case
    // cannot move a value that is already in the field and in the database.
    //
    // `init(from:)` reads the subscribe spelling TOO, so a sender that has already moved is
    // understood. Flipping which spelling is WRITTEN is a separate decision, to be taken when
    // no build in the field still reads the old one.

    /// The subscribe spelling of this case, which ``init(from:)`` also accepts.
    ///
    /// Written out for the same reason the raw values are: a derived spelling is one that
    /// changes silently when a case is renamed.
    public var subscribeSpelling: String {
        switch self {
        case .questionAddedToSubscribedQuestionnaire:
            return "questionAddedToSubscribedQuestionnaire"
        case .questionAddedBySubscribedMember: return "questionAddedBySubscribedMember"
        case .questionnaireAddedBySubscribedMember:
            return "questionnaireAddedBySubscribedMember"
        case .responseAddedBySubscribedMember: return "responseAddedBySubscribedMember"
        }
    }

    /// Decodes either spelling of the reason.
    ///
    /// A value carrying NEITHER still throws, so this is a widened contract rather than a
    /// silent default: a reason this package does not know about must not quietly become one
    /// it does.
    public init(from decoder: any Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        if let reason = NotificationReason(rawValue: raw) {
            self = reason
            return
        }
        if let reason = NotificationReason.allCases.first(where: { $0.subscribeSpelling == raw }) {
            self = reason
            return
        }
        throw DecodingError.dataCorrupted(
            .init(
                codingPath: decoder.codingPath,
                debugDescription: "\(raw) is neither a follow nor a subscribe spelling of a "
                    + "notification reason"
            )
        )
    }

    /// The notification category this reason is delivered under.
    ///
    /// GL34 B5. gl29.html's notification centre draws three things iOS can only draw from a
    /// CATEGORY: the summary line a collapsed stack carries ("8 more questions in this
    /// questionnaire", "11 more responses in this group"), the action that opens the screen
    /// where a member chooses what arrives, and the grouping that puts a run of one kind in one
    /// stack. A push with no category is drawn as a bare alert and stacks under the app's name
    /// with iOS's own wording, which is what the capture of that state showed.
    ///
    /// IN THE CONTRACT because both ends need the same string: the server sets it on the push
    /// and the client registers the category under it, and a mismatch is a notification that
    /// silently loses its summary and its action.
    public var notificationCategoryIdentifier: String {
        switch self {
        // THESE FOUR STRINGS DO NOT MOVE WITH THE RENAME. The shipped App Store app registers
        // its `UNNotificationCategory` objects under them and the server sets them on the push;
        // the doc comment above already says a mismatch is a notification that silently loses
        // its summary and its action, and renaming one end of a pair is how that mismatch
        // happens. GOAL_LOOP37 decision D5 keeps them, as it keeps the route paths.
        case .questionAddedToSubscribedQuestionnaire: return "follow.questionnaire.questions"
        case .questionAddedBySubscribedMember, .questionnaireAddedBySubscribedMember:
            // ONE CATEGORY FOR THE TWO, because iOS summarises a stack with one line and
            // gl29.html's line for this stack names both: "4 more questions and questionnaires
            // in this group". Two categories would draw two stacks and neither line.
            return "follow.member.content"
        case .responseAddedBySubscribedMember: return "follow.member.responses"
        }
    }

    /// The summary a COLLAPSED stack of this kind carries, with `%u` standing for the others.
    ///
    /// gl29.html's own three lines. `%u` is the placeholder `UNNotificationCategory` fills with
    /// the number of notifications the stack is hiding.
    public var notificationSummaryFormat: String {
        switch self {
        case .questionAddedToSubscribedQuestionnaire:
            return "%u more questions in this questionnaire"
        case .questionAddedBySubscribedMember, .questionnaireAddedBySubscribedMember:
            return "%u more questions and questionnaires in this group"
        case .responseAddedBySubscribedMember:
            return "%u more responses in this group"
        }
    }

    /// What the action on one of these notifications is called.
    ///
    /// gl29.html draws it in the notification centre, and it is the one thing a member can do
    /// with a notification about somebody else's content other than open it: decide what arrives
    /// next. It opens `SubscribeNotificationPreferencesView`, which is B4's screen.
    public static let notificationActionTitle = "Choose what arrives"

    /// The identifier that action is delivered back under.
    ///
    /// Unchanged by the GOAL_LOOP37 rename, for the reason given on
    /// ``notificationCategoryIdentifier``: the shipped app registers its action under this
    /// exact string.
    public static let notificationActionIdentifier = "follow.choose-what-arrives"

    /// The thread a notification of this reason joins, which is what iOS stacks by.
    ///
    /// - Parameter subjectID: the question, questionnaire or response the notification is about.
    /// - Returns: the thread identifier.
    public func notificationThreadIdentifier(subjectID: UUID) -> String {
        switch self {
        case .questionAddedToSubscribedQuestionnaire:
            // THE QUESTIONNAIRE'S OWN THREAD, because the summary line names it: a run of
            // questions added to one questionnaire is one stack, and the subject of this reason
            // IS the questionnaire's question, whose questionnaire the payload carries.
            return "\(notificationCategoryIdentifier).\(subjectID.uuidString)"
        case .questionAddedBySubscribedMember, .questionnaireAddedBySubscribedMember,
             .responseAddedBySubscribedMember:
            return notificationCategoryIdentifier
        }
    }

    /// One sentence, addressed to the member, explaining why they are being told.
    ///
    /// Lives in the contract rather than in each client so the three platforms cannot drift into
    /// three different explanations of the same event.
    ///
    /// None of these sentences names the author, and that is deliberate rather than incidental.
    /// GOAL_LOOP13 R21.12 forbids naming a creator whose visibility is anything but
    /// ``AuthorVisibility/attributed``, on every surface including this one. The rule was written
    /// when the enum had four cases; the two that are not `attributed` are now the single
    /// `anonymized` case, which their old raw values decode into. A sentence that names the member
    /// only
    /// sometimes is a sentence each caller has to remember to redact. Saying "someone you
    /// subscribe to" in all cases means the redaction cannot be forgotten, because there is nothing to forget.
    public var explanation: String {
        switch self {
        case .questionAddedToSubscribedQuestionnaire:
            return "A questionnaire you subscribe to has a new question."
        case .questionAddedBySubscribedMember:
            return "Someone you subscribe to wrote a new question."
        case .questionnaireAddedBySubscribedMember:
            return "Someone you subscribe to made a new questionnaire."
        case .responseAddedBySubscribedMember:
            return "Someone you subscribe to added a new response."
        }
    }

    /// The content kind this reason is about.
    ///
    /// Exhaustive and `default`-less, so a fifth reason cannot compile until it says what kind of
    /// content it concerns.
    public var contentKind: AuthoredContentKind {
        switch self {
        case .questionAddedToSubscribedQuestionnaire: return .question
        case .questionAddedBySubscribedMember: return .question
        case .questionnaireAddedBySubscribedMember: return .questionnaire
        case .responseAddedBySubscribedMember: return .response
        }
    }

    /// Whether this reason is news about a person rather than about a set.
    ///
    /// A questionnaire gaining a question is news about the questionnaire and names nobody. The
    /// other three exist only because a particular member acted, which is what makes them subject
    /// to the author visibility rules.
    public var isAboutTheAuthor: Bool {
        switch self {
        case .questionAddedToSubscribedQuestionnaire: return false
        case .questionAddedBySubscribedMember: return true
        case .questionnaireAddedBySubscribedMember: return true
        case .responseAddedBySubscribedMember: return true
        }
    }
}

/// An author id that has already been through the disclosure decision.
///
/// GOAL_LOOP13 R22.3. The redaction rule, that content created under any visibility other than
/// ``AuthorVisibility/attributed`` must never leave the server carrying an author id, was
/// previously enforced by
/// each fan-out site remembering to check. A rule held in place by memory is one that a sixth
/// call site breaks, silently, in the direction nobody notices, because a payload that names
/// someone looks exactly as correct as one that does not.
///
/// This type removes the option. Its only initializer takes the content's visibility alongside
/// the author, and yields nothing for the two hiding states, so a site that forgets to redact
/// cannot construct the value it needs in order to name anybody. `SubscribeNotificationPayload`
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

/// What the client renders when a subscribed thing gains content.
///
/// The identifier properties end `Id`, not `ID`, and that is load bearing rather than a style
/// choice. This app installs `.convertToSnakeCase` and `.convertFromSnakeCase` process wide in
/// `configure.swift`, and Foundation's conversion is not its own inverse when a name ends in an
/// acronym: the encoder writes `question_id` and the decoder reads it back as `questionId`, so a
/// property spelled with the capitalised acronym encodes fine and then fails to decode. Spelling
/// the property the way the round trip lands is the whole fix, and GOAL_LOOP13 R22.1 turns the
/// rule into a check rather than a comment.
public struct SubscribeNotificationPayload: Codable, Hashable, Sendable {

    /// Why this arrived.
    public let reason: NotificationReason

    /// What it is about. Never absent, by construction.
    public let subject: NotificationSubject

    /// The questionnaire involved, when the reason is a subscribed questionnaire.
    public let questionnaireId: UUID?

    /// The question a RESPONSE answers, so a tap on a response notification can land on it.
    ///
    /// GOAL_LOOP31, the slice B adversarial review's finding 2. ``NotificationSubject`` carries a
    /// response's id and its text and nothing about the question it answers, and every client that
    /// reads a response reads it on its question's screen. The router that turns this payload into
    /// a destination recorded the gap in prose and handed it to its implementer, and the
    /// implementer had nowhere to go: there is no route anywhere that resolves a response to its
    /// question, so a member who tapped "someone you subscribe to added a new response" landed
    /// whatever screen was already there. One optional id closes it.
    ///
    /// ADDITIVE AND OPTIONAL, deliberately. A payload written before this field decodes with it
    /// nil, which is what the three reasons that are not about a response send anyway, so no
    /// deployed sender has to change in step with a client that reads it. The memberwise
    /// initializer defaults it for the same reason: the three sites that build a payload about a
    /// question or a questionnaire say nothing about it and mean nothing by the silence.
    ///
    /// NOT A SECOND SPELLING OF THE SUBJECT. For the two question shaped reasons the subject IS
    /// the question, and this field stays nil there rather than repeating it, so a reader cannot
    /// find two ids for one question and have to decide which is authoritative.
    public let questionId: UUID?

    /// The member who wrote it, and ONLY when their visibility permits naming them.
    ///
    /// Optional for two different reasons, and both matter.
    ///
    /// First, not every notification is about an author: a questionnaire you subscribe to
    /// gaining a question is news about the set, so those carry no author at all.
    ///
    /// Second, and this is the reason that changed: GOAL_LOOP13 R21.12 requires that content
    /// created under a non attributed visibility leave the server carrying no author id,
    /// even to a recipient who subscribes to that member. This field previously documented the
    /// opposite for the announced but unattributed case, on the reasoning that a subscriber
    /// already knows who they subscribe to. The loop rejects that reasoning: the subscriber
    /// knowing WHO they subscribe to is not the same as being told THIS item was written by
    /// them, and with a short subscriber list the second fact identifies the author of a
    /// specific piece of content. So `.attributed` is now the only
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
    ///   - questionId: the question a response answers. Defaulted to nil, because only the
    ///     response reason has one and the other three mean nothing by leaving it out.
    public init(
        reason: NotificationReason,
        subject: NotificationSubject,
        questionnaireId: UUID?,
        author: DisclosedAuthor,
        questionId: UUID? = nil
    ) {
        self.reason = reason
        self.subject = subject
        self.questionnaireId = questionnaireId
        self.authorId = author.id
        self.questionId = questionId
    }
}
