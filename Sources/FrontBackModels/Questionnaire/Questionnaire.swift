import Foundation

// Swath N1 contracts (item 4.1): a questionnaire is an ordered membership over existing
// `Question` rows, per T8.
//
// It does NOT copy questions, and that is the whole design. Responses and importance ratings
// already collected against a question carry over the moment it joins a questionnaire, because it
// is the same question. Copying would fork the answers: the same text would accumulate two
// separate response histories, and every compatibility score computed from them would silently
// depend on which copy a member happened to answer.

/// An ordered selection of existing questions, published by a member.
///
/// The order is the author's, and it is carried in `questionIDs` rather than derived, because "the
/// order the author chose" and "the order the ids happen to sort in" are different facts and only
/// one of them is worth showing to a respondent.
public struct Questionnaire: Codable, Hashable, Sendable {
    /// The questionnaire's own identifier.
    public let id: UUID

    /// What the author called it. Shown to respondents, so it is theirs rather than generated.
    public let title: String

    /// The member who published it.
    public let creatorID: UUID

    /// The context this questionnaire belongs to, so a member sees questionnaires for the context
    /// they are actually in rather than every questionnaire on the platform.
    public let contextID: UUID

    /// When it was published.
    public let createdAt: Date

    /// The questions, in the author's order.
    ///
    /// These are references to existing questions, never copies. A question may appear in many
    /// questionnaires at once and keeps one set of responses across all of them.
    public let questionIDs: [UUID]

    /// Whether the author is disclosed, and how. Defaults to `silent` everywhere else in the
    /// system, and is carried here so a respondent's view can be rendered without a second lookup.
    public let authorVisibility: AuthorVisibility

    /// Memberwise initializer.
    /// - Parameters:
    ///   - id: the questionnaire's own identifier.
    ///   - title: the author's title for it.
    ///   - creatorID: the member who published it.
    ///   - contextID: the context it belongs to.
    ///   - createdAt: when it was published.
    ///   - questionIDs: references to existing questions, in the author's order.
    ///   - authorVisibility: whether and how the author is disclosed.
    public init(
        id: UUID,
        title: String,
        creatorID: UUID,
        contextID: UUID,
        createdAt: Date,
        questionIDs: [UUID],
        authorVisibility: AuthorVisibility
    ) {
        self.id = id
        self.title = title
        self.creatorID = creatorID
        self.contextID = contextID
        self.createdAt = createdAt
        self.questionIDs = questionIDs
        self.authorVisibility = authorVisibility
    }
}

/// What a questionnaire's responses add up to.
///
/// Two counts rather than one, because "started" and "finished" are different questions about a
/// questionnaire and reporting only the larger of them flatters it.
public struct QuestionnaireStats: Codable, Hashable, Sendable {
    /// How many members answered at least one question in it.
    public let respondentCount: Int

    /// How many members answered every question in it. Never greater than `respondentCount`.
    public let completionCount: Int

    /// The importance the respondents' own ratings imply, per question.
    ///
    /// Derived rather than declared: the author does not set it, and it is keyed by question id so
    /// a question appearing in several questionnaires can carry a different derived importance in
    /// each without its own record changing.
    public let derivedImportance: [UUID: Double]

    /// Memberwise initializer.
    /// - Parameters:
    ///   - respondentCount: members who answered at least one question.
    ///   - completionCount: members who answered every question.
    ///   - derivedImportance: importance implied by respondents' ratings, keyed by question id.
    public init(respondentCount: Int, completionCount: Int, derivedImportance: [UUID: Double]) {
        self.respondentCount = respondentCount
        self.completionCount = completionCount
        self.derivedImportance = derivedImportance
    }
}
