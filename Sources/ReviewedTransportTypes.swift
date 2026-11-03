//
//  ReviewedTransportTypes.swift
//  AkinFrontBackModels
//
//  Payload and response types for the endpoints the iOS client calls.
//
//  WHY THEY MOVED HERE. Each was declared on the server as a Vapor `Content`
//  type, which the client cannot import, so every one of these endpoints was
//  reachable only by building its path and its body by hand on the client. Two
//  definitions of every field lived in two repositories with nothing comparing
//  them. A contract cannot exist until both sides can name the same type.
//
//  `Content` conformance stays on the server, in ReviewedFeatureContent.swift,
//  because it is a Vapor protocol and this package does not depend on Vapor.
//

import Foundation

public struct AddQuestionnaireQuestionRequest: Codable {
    public let questionId: UUID

    public init(questionId: UUID) {
        self.questionId = questionId
    }
}

public struct AuthorVisibilityAuditDTO: Codable {
    public let questionId: UUID
    public let oldVisibility: AuthorVisibility
    public let newVisibility: AuthorVisibility
    public let actorId: UUID
    public let changedAt: Date

    public init(
        questionId: UUID,
        oldVisibility: AuthorVisibility,
        newVisibility: AuthorVisibility,
        actorId: UUID,
        changedAt: Date
    ) {
        self.questionId = questionId
        self.oldVisibility = oldVisibility
        self.newVisibility = newVisibility
        self.actorId = actorId
        self.changedAt = changedAt
    }
}

public struct BrowseContextDTO: Codable {
    public let contextId: UUID
    public let adoptionCount: Int

    public init(contextId: UUID, adoptionCount: Int) {
        self.contextId = contextId
        self.adoptionCount = adoptionCount
    }
}

public struct BrowseQuestionnaireDTO: Codable {
    public let questionnaireId: UUID
    public let title: String
    /// Null when the author is not disclosed to this reader (swath N3 item 6.5).
    ///
    /// Optional on purpose. Two of these three DTOs are served only to the creator, where the
    /// value is always present, and it would be easy to argue they do not need it. They do: the
    /// grep in item 6.5 exists because "this endpoint is creator only" is a fact about today's
    /// route table, and the type is what keeps it true after somebody adds tomorrow's.
    public let creatorId: UUID?
    /// The author's name, present exactly when `creatorId` is.
    ///
    /// Both go through the same disclosure decision, so a payload can never name
    /// someone it declined to identify, or identify someone it declined to name.
    /// Without this the row said "Shown by its author" and showed no author.
    public let creatorName: String?
    public let isRated: Bool
    public let derivedImportance: Double?

    /// How many members have answered at least one of its questions.
    ///
    /// GL34 C2. `HomeQuestionnairesFiltered.html` draws both counts on every row of this feed,
    /// in the same words the preferences screen uses: "<N> answered some · <M> answered all".
    /// This route served neither, so the browse row had nothing to draw and the comp's line was
    /// missing from the app entirely.
    ///
    /// OPTIONAL AND ADDITIVE, so a client reading an older server gets nil and draws no line
    /// rather than a confident zero.
    public let answeredSomeCount: Int?

    /// How many members have answered every one of its questions.
    ///
    /// Always less than or equal to ``answeredSomeCount`` by construction, for the reason
    /// `QuestionnaireRowSummary` gives: answering all of something is a way of answering some.
    public let answeredAllCount: Int?

    public init(
        questionnaireId: UUID,
        title: String,
        creatorId: UUID?,
        creatorName: String?,
        isRated: Bool,
        derivedImportance: Double?,
        answeredSomeCount: Int? = nil,
        answeredAllCount: Int? = nil
    ) {
        self.questionnaireId = questionnaireId
        self.title = title
        self.creatorId = creatorId
        self.creatorName = creatorName
        self.isRated = isRated
        self.derivedImportance = derivedImportance
        self.answeredSomeCount = answeredSomeCount
        self.answeredAllCount = answeredAllCount
    }
}

public struct CreateContextRequest: Codable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

public struct CreateQuestionnaireRequest: Codable {
    public let title: String
    public let contextId: UUID
    public let questionIds: [UUID]?
    public let authorVisibility: String?

    public init(title: String, contextId: UUID, questionIds: [UUID]?, authorVisibility: String?) {
        self.title = title
        self.contextId = contextId
        self.questionIds = questionIds
        self.authorVisibility = authorVisibility
    }
}

public struct DiscountedPair: Codable, Equatable {
    public let question: UUID
    public let duplicateOf: UUID
    public let cosine: Double

    public init(question: UUID, duplicateOf: UUID, cosine: Double) {
        self.question = question; self.duplicateOf = duplicateOf; self.cosine = cosine
    }
}

public struct ExclusionCostResponse: Codable {
    public let excludedCount: Int
    public let totalCandidates: Int
    public let excludedFraction: Double

    public init(excludedCount: Int, totalCandidates: Int, excludedFraction: Double) {
        self.excludedCount = excludedCount
        self.totalCandidates = totalCandidates
        self.excludedFraction = excludedFraction
    }
}

public struct MyQuestionnaireDTO: Codable {
    public let questionnaireId: UUID
    public let title: String
    public let contextId: UUID
    /// The stored raw value, so the author's own list can report what readers will see
    /// without a second call per row.
    public let authorVisibility: String
    /// How many questions it holds. Zero is a real and expected value: item 4.4 exists so a
    /// member can name a questionnaire first and fill it afterwards.
    public let questionCount: Int

    public init(
        questionnaireId: UUID,
        title: String,
        contextId: UUID,
        authorVisibility: String,
        questionCount: Int
    ) {
        self.questionnaireId = questionnaireId
        self.title = title
        self.contextId = contextId
        self.authorVisibility = authorVisibility
        self.questionCount = questionCount
    }
}

public struct NameProfileRequest: Codable {
    /// What the member wants it called.
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

public struct QuestionImportanceDTO: Codable {
    public let questionId: UUID
    public let ownMean: Double
    public let raterCount: Int
    public let shrunk: Double

    public init(questionId: UUID, ownMean: Double, raterCount: Int, shrunk: Double) {
        self.questionId = questionId
        self.ownMean = ownMean
        self.raterCount = raterCount
        self.shrunk = shrunk
    }
}

public struct QuestionSummaryDTO: Codable {
    public let questionId: UUID
    public let text: String

    public init(questionId: UUID, text: String) {
        self.questionId = questionId
        self.text = text
    }
}

public struct QuestionnaireDetailDTO: Codable {
    public let questionnaireId: UUID
    public let title: String
    /// Null when the author is not disclosed to this reader (swath N3 item 6.5).
    ///
    /// Optional on purpose. Two of these three DTOs are served only to the creator, where the
    /// value is always present, and it would be easy to argue they do not need it. They do: the
    /// grep in item 6.5 exists because "this endpoint is creator only" is a fact about today's
    /// route table, and the type is what keeps it true after somebody adds tomorrow's.
    public let creatorId: UUID?
    public let authorVisibility: String
    public let questionIds: [UUID]
    /// The same questions, with their text. `questionIds` stays for callers that
    /// only need the order.
    public let questions: [QuestionSummaryDTO]
    /// The working behind the importance figure. Empty when nothing is rated.
    public let importanceBreakdown: [QuestionImportanceDTO]
    public let creatorName: String?
    public let respondentCount: Int
    public let completionCount: Int
    /// Null when unrated. Paired with `isRated` so absence is explicit rather than inferred.
    public let derivedImportance: Double?
    public let isRated: Bool

    public init(
        questionnaireId: UUID,
        title: String,
        creatorId: UUID?,
        authorVisibility: String,
        questionIds: [UUID],
        questions: [QuestionSummaryDTO],
        importanceBreakdown: [QuestionImportanceDTO],
        creatorName: String?,
        respondentCount: Int,
        completionCount: Int,
        derivedImportance: Double?,
        isRated: Bool
    ) {
        self.questionnaireId = questionnaireId
        self.title = title
        self.creatorId = creatorId
        self.authorVisibility = authorVisibility
        self.questionIds = questionIds
        self.questions = questions
        self.importanceBreakdown = importanceBreakdown
        self.creatorName = creatorName
        self.respondentCount = respondentCount
        self.completionCount = completionCount
        self.derivedImportance = derivedImportance
        self.isRated = isRated
    }
}

public struct QuestionnaireWithQuestions: Codable {
    public let id: UUID
    public let title: String
    /// Null when the author is not disclosed to this reader (swath N3 item 6.5).
    ///
    /// Optional on purpose. Two of these three DTOs are served only to the creator, where the
    /// value is always present, and it would be easy to argue they do not need it. They do: the
    /// grep in item 6.5 exists because "this endpoint is creator only" is a fact about today's
    /// route table, and the type is what keeps it true after somebody adds tomorrow's.
    public let creatorId: UUID?
    public let contextId: UUID
    public let authorVisibility: String
    public let questionIds: [UUID]

    public init(
        id: UUID,
        title: String,
        creatorId: UUID?,
        contextId: UUID,
        authorVisibility: String,
        questionIds: [UUID]
    ) {
        self.id = id
        self.title = title
        self.creatorId = creatorId
        self.contextId = contextId
        self.authorVisibility = authorVisibility
        self.questionIds = questionIds
    }
}

public struct RedundancyExplanationResponse: Codable, Equatable {
    public let discountedPairs: [DiscountedPair]

    public init(discountedPairs: [DiscountedPair]) {
        self.discountedPairs = discountedPairs
    }
}

public struct RenameQuestionnaireRequest: Codable {
    public let title: String

    public init(title: String) {
        self.title = title
    }
}

public struct ReorderQuestionnaireRequest: Codable {
    public let questionIds: [UUID]

    public init(questionIds: [UUID]) {
        self.questionIds = questionIds
    }
}

public enum RequirementFlavor: String, Codable, CaseIterable {
    case mustHaveAnswered = "must_have_answered"
    case mustNotHaveChosen = "must_not_have_chosen"
    case mustHaveChosenOneOf = "must_have_chosen_one_of"
}

public struct SetAlgorithmRequest: Codable {
    public let algorithm: String

    public init(algorithm: String) {
        self.algorithm = algorithm
    }
}

public struct SetAuthorVisibilityRequest: Codable {

    /// The value the creator is choosing.
    public let authorVisibility: AuthorVisibility

    public init(authorVisibility: AuthorVisibility) {
        self.authorVisibility = authorVisibility
    }

    private enum CodingKeys: String, CodingKey {
        case authorVisibility
    }

    /// Rejects an unknown value instead of decoding it into a default.
    ///
    /// A `DecodingError` rather than Vapor's `Abort`, because this package has no Vapor and the
    /// rule belongs to the contract: a client that sends a value outside the known set is wrong on
    /// both sides, not just at the server's door. The accepted set travels in the message.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let raw = try container.decode(String.self, forKey: .authorVisibility)
        do {
            self.authorVisibility = try AuthorVisibility.requireKnown(raw)
        } catch let unknown as AuthorVisibility.UnknownValue {
            throw DecodingError.dataCorruptedError(
                forKey: .authorVisibility, in: container, debugDescription: unknown.description
            )
        }
    }
}

public struct SetMutedRequest: Codable {
    /// True to silence the subscription, false to hear it again.
    public let muted: Bool

    public init(muted: Bool) {
        self.muted = muted
    }
}

public struct SetRequirementRequest: Codable {
    public let contextId: UUID
    public let questionId: UUID
    public let flavor: RequirementFlavor
    public let responseIds: [UUID]

    public init(contextId: UUID, questionId: UUID, flavor: RequirementFlavor, responseIds: [UUID]) {
        self.contextId = contextId
        self.questionId = questionId
        self.flavor = flavor
        self.responseIds = responseIds
    }
}

public struct SubscriptionListEntry: Codable {
    public let target: SubscriptionTarget
    /// What the member subscribes to, as they would name it: a questionnaire's
    /// title, or a member's full name.
    ///
    /// Added after item 8.13 drove the running app: the list rendered three rows
    /// reading "Questionnaire", "Questionnaire" and "Member", so a member could
    /// not tell two of their own subscriptions apart, let alone know what they
    /// were about to mute. The payload had a target and no name for it.
    public let title: String
    public let muted: Bool

    /// The subscribed member's profile picture, when there is one.
    ///
    /// GOAL_LOOP13 R21.16. The row carried a target, a title and a mute state, which is not
    /// enough to recognise a PERSON: two members with similar names render as two lines of text
    /// that a member has to read carefully to tell apart, and the whole point of this screen is
    /// deciding which of them to silence.
    ///
    /// Nil for a questionnaire, which has no face, and nil for a member with no profile image.
    ///
    /// **Spelled `imageUrl`, not `imageURL`, and that is load bearing here specifically.** This is
    /// a body the SERVER encodes, which is the direction where the trailing acronym breaks: the
    /// encoder's `.convertToSnakeCase` writes `image_url`, and the client's
    /// `.convertFromSnakeCase` reads that back as `imageUrl`. A property spelled with the
    /// capitalised acronym would encode fine and then fail to decode, silently, on the client
    /// only. `IdentifierSpellingGuardTests` in the models package now fails the build for the
    /// `...ID` form for this reason.
    public let imageUrl: String?

    /// Whether the member this row points at is gone.
    ///
    /// GOAL_LOOP34 item B3. `FollowingListView.html`'s `member-anonymous-or-left` state draws
    /// that row differently from every other: no bell, because there is nothing left to be told
    /// about, and the caption "Nothing more will arrive" in place of the notification state. The
    /// server has always titled the row "A member who has left"; a client reading the title to
    /// decide how to draw it would be matching on a sentence, which is the thing the title
    /// exists to be rather than a flag.
    ///
    /// Optional rather than defaulted so a server that predates the field still decodes, which
    /// is the same reason `imageUrl` is optional. Absent means present: a row from an older
    /// server is drawn the way it always was.
    public let departed: Bool?

    /// Not every caller has an image to supply, and a questionnaire never does.
    public init(
        target: SubscriptionTarget,
        title: String,
        muted: Bool,
        imageUrl: String? = nil,
        departed: Bool? = nil
    ) {
        self.target = target
        self.title = title
        self.muted = muted
        self.imageUrl = imageUrl
        self.departed = departed
    }
}

public struct VenueExclusionWarning: Codable, Equatable {
    public let excludedCount: Int
    public let otherMemberCount: Int
    public let excludedFraction: Double
    public let candidateCount: Int

    public init(
        excludedCount: Int,
        otherMemberCount: Int,
        excludedFraction: Double,
        candidateCount: Int
    ) {
        self.excludedCount = excludedCount
        self.otherMemberCount = otherMemberCount
        self.excludedFraction = excludedFraction
        self.candidateCount = candidateCount
    }
}

public struct VenuePreferenceRequest: Codable {
    public let venueId: UUID
    public let stance: VenueStance

    public init(venueId: UUID, stance: VenueStance) {
        self.venueId = venueId
        self.stance = stance
    }
}

public enum VenueStance: String, Codable, CaseIterable {
    case preferred
    case blocked
}
