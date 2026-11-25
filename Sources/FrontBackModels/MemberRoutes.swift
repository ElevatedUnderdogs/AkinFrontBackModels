//
//  MemberRoutes.swift
//  AkinFrontBackModels
//
//  Contracts for the member routes the server used to register by string.
//  Every argument travels in the payload. The path is the static var's name.
//

import Foundation
import StrongContractClient

// MARK: - Payloads

/// Names one questionnaire.
public struct QuestionnaireIdPayload: Codable, Hashable, Sendable {
    public let questionnaireId: UUID

    public init(questionnaireId: UUID) {
        self.questionnaireId = questionnaireId
    }
}

/// Names one question inside one questionnaire.
public struct QuestionnaireQuestionPayload: Codable, Hashable, Sendable {
    public let questionnaireId: UUID
    public let questionId: UUID

    public init(questionnaireId: UUID, questionId: UUID) {
        self.questionnaireId = questionnaireId
        self.questionId = questionId
    }
}

/// Names one question.
public struct QuestionIdPayload: Codable, Hashable, Sendable {
    public let questionId: UUID

    public init(questionId: UUID) {
        self.questionId = questionId
    }
}

/// Names another member.
public struct MemberIdPayload: Codable, Hashable, Sendable {
    public let memberId: UUID

    public init(memberId: UUID) {
        self.memberId = memberId
    }
}

/// Names one context.
public struct ContextIdPayload: Codable, Hashable, Sendable {
    public let contextId: UUID

    public init(contextId: UUID) {
        self.contextId = contextId
    }
}

/// Names one of the caller's matchmaking profiles.
public struct MatchmakingProfileIdPayload: Codable, Hashable, Sendable {
    public let profileId: UUID

    public init(profileId: UUID) {
        self.profileId = profileId
    }
}

/// - Parameters:
///   - questionnaireId: The questionnaire whose subscription changes.
///   - muted: True to silence it, false to hear it again.
public struct SetQuestionnaireSubscriptionMutedPayload: Codable, Hashable, Sendable {
    public let questionnaireId: UUID
    public let muted: Bool

    public init(questionnaireId: UUID, muted: Bool) {
        self.questionnaireId = questionnaireId
        self.muted = muted
    }
}

/// - Parameters:
///   - memberId: The member whose subscription changes.
///   - muted: True to silence it, false to hear it again.
public struct SetMemberSubscriptionMutedPayload: Codable, Hashable, Sendable {
    public let memberId: UUID
    public let muted: Bool

    public init(memberId: UUID, muted: Bool) {
        self.memberId = memberId
        self.muted = muted
    }
}

/// - Parameters:
///   - contextId: The context the new profile belongs to.
///   - name: What the member calls it.
public struct CreateMatchmakingProfilePayload: Codable, Hashable, Sendable {
    public let contextId: UUID
    public let name: String

    public init(contextId: UUID, name: String) {
        self.contextId = contextId
        self.name = name
    }
}

/// - Parameters:
///   - profileId: The profile to copy or rename.
///   - name: The name for the copy, or the new name.
public struct MatchmakingProfileNamePayload: Codable, Hashable, Sendable {
    public let profileId: UUID
    public let name: String

    public init(profileId: UUID, name: String) {
        self.profileId = profileId
        self.name = name
    }
}

/// - Parameters:
///   - page: 1 based page. Nil answers the whole list.
///   - per: Page size, 1 to 100. Defaults to 20.
public struct MyQuestionsPayload: Codable, Hashable, Sendable {
    public let page: Int?
    public let per: Int?

    public init(page: Int? = nil, per: Int? = nil) {
        self.page = page
        self.per = per
    }
}

/// - Parameters:
///   - page: 1 based page. Defaults to 1.
///   - per: Page size, 1 to 100. Defaults to 20.
///   - includeSwitchedOff: True to include contexts the member turned off.
public struct BrowseQuestionnairesPayload: Codable, Hashable, Sendable {
    public let page: Int?
    public let per: Int?
    public let includeSwitchedOff: Bool?

    public init(page: Int? = nil, per: Int? = nil, includeSwitchedOff: Bool? = nil) {
        self.page = page
        self.per = per
        self.includeSwitchedOff = includeSwitchedOff
    }
}

/// - Parameters:
///   - email: The address the code was sent to.
///   - code: The code the member typed.
public struct VerifyEmailCodePayload: Codable, Hashable, Sendable {
    public let email: String
    public let code: String

    public init(email: String, code: String) {
        self.email = email
        self.code = code
    }
}

/// - Parameters:
///   - userId: The member whose tier changes.
///   - tier: "free" or a product name.
///   - expiresAt: When the paid tier ends. Nil means no end.
public struct SubscriptionDebugSetTierPayload: Codable, Hashable, Sendable {
    public let userId: UUID
    public let tier: String
    public let expiresAt: Date?

    public init(userId: UUID, tier: String, expiresAt: Date? = nil) {
        self.userId = userId
        self.tier = tier
        self.expiresAt = expiresAt
    }
}

/// - Parameter userId: The member whose subscriptions to list.
public struct SubscriptionDebugStatePayload: Codable, Hashable, Sendable {
    public let userId: UUID

    public init(userId: UUID) {
        self.userId = userId
    }
}

/// - Parameters:
///   - filename: The name to save it under in the public directory.
///   - contents: The file's bytes.
public struct UploadPublicFilePayload: Codable, Hashable, Sendable {
    public let filename: String
    public let contents: Data

    public init(filename: String, contents: Data) {
        self.filename = filename
        self.contents = contents
    }
}

// MARK: - Responses

/// The questionnaire `createQuestionnaire` made.
public struct CreatedQuestionnaire: Codable, Hashable, Sendable, Identifiable {
    public let id: UUID
    public let title: String

    public init(id: UUID, title: String) {
        self.id = id
        self.title = title
    }
}

/// Another member's profile as the caller may see it. Counts only, never the content itself.
public struct MemberProfile: Codable, Hashable, Sendable, Identifiable {
    public let id: UUID
    public let displayName: String
    public let profileImageURL: String?
    public let attributedQuestionCount: Int
    public let attributedResponseCount: Int
    public let attributedQuestionnaireCount: Int

    public init(
        id: UUID,
        displayName: String,
        profileImageURL: String?,
        attributedQuestionCount: Int,
        attributedResponseCount: Int,
        attributedQuestionnaireCount: Int
    ) {
        self.id = id
        self.displayName = displayName
        self.profileImageURL = profileImageURL
        self.attributedQuestionCount = attributedQuestionCount
        self.attributedResponseCount = attributedResponseCount
        self.attributedQuestionnaireCount = attributedQuestionnaireCount
    }
}

/// One stored decode failure, as an operator reads it back.
public struct DecodeFailureReportEntry: Codable, Hashable, Sendable {
    public let id: UUID
    public let createdAt: Date?
    public let endpoint: String
    public let codingKey: String?
    public let expectedType: String
    public let appBuild: String
    public let excerpt: String
    public let bodyBytes: Int

    public init(
        id: UUID,
        createdAt: Date?,
        endpoint: String,
        codingKey: String?,
        expectedType: String,
        appBuild: String,
        excerpt: String,
        bodyBytes: Int
    ) {
        self.id = id
        self.createdAt = createdAt
        self.endpoint = endpoint
        self.codingKey = codingKey
        self.expectedType = expectedType
        self.appBuild = appBuild
        self.excerpt = excerpt
        self.bodyBytes = bodyBytes
    }
}

/// One subscription row, for the debug state route.
public struct SubscriptionDebugStateEntry: Codable, Hashable, Sendable {
    public let id: UUID
    public let userId: UUID
    public let platform: String
    public let productId: String
    public let originalTransactionId: String
    public let expiresAt: Date?
    public let environment: String
    public let revokedAt: Date?

    public init(
        id: UUID,
        userId: UUID,
        platform: String,
        productId: String,
        originalTransactionId: String,
        expiresAt: Date?,
        environment: String,
        revokedAt: Date?
    ) {
        self.id = id
        self.userId = userId
        self.platform = platform
        self.productId = productId
        self.originalTransactionId = originalTransactionId
        self.expiresAt = expiresAt
        self.environment = environment
        self.revokedAt = revokedAt
    }
}

// MARK: - Requirements, venues, algorithm

public typealias SetRequirementRequest = Request<SetRequirementPayload, ExclusionCostResponse>
extension SetRequirementRequest {
    public static var setRequirement: Self { .init(method: .post) }
}

public typealias ExclusionCostRequest = Request<Empty, ExclusionCostResponse>
extension ExclusionCostRequest {
    public static var exclusionCost: Self { .init(method: .get) }
}

public typealias RedundancyExplanationRequest = Request<Empty, RedundancyExplanationResponse>
extension RedundancyExplanationRequest {
    public static var redundancyExplanation: Self { .init(method: .get) }
}

public typealias SetVenuePreferencesRequest = Request<SetVenuePreferencesPayload, VenueExclusionWarning>
extension SetVenuePreferencesRequest {
    public static var setVenuePreferences: Self { .init(method: .post) }
}

public typealias SetAlgorithmRequest = Request<SetAlgorithmPayload, StandardPostResponse>
extension SetAlgorithmRequest {
    public static var setAlgorithm: Self { .init(method: .post) }
}

// MARK: - Contexts

public typealias CreateContextRequest = Request<CreateContextPayload, StandardPostResponse>
extension CreateContextRequest {
    public static var createContext: Self { .init(method: .post) }
}

public typealias AdoptContextRequest = Request<ContextIdPayload, StandardPostResponse>
extension AdoptContextRequest {
    public static var adoptContext: Self { .init(method: .post) }
}

public typealias BrowseContextsRequest = Request<Empty, [BrowseContext]>
extension BrowseContextsRequest {
    public static var browseContexts: Self { .init(method: .get) }
}

// MARK: - Questionnaires

public typealias CreateQuestionnaireRequest = Request<CreateQuestionnairePayload, CreatedQuestionnaire>
extension CreateQuestionnaireRequest {
    public static var createQuestionnaire: Self { .init(method: .post) }
}

public typealias AddQuestionnaireQuestionRequest = Request<QuestionnaireQuestionPayload, StandardPostResponse>
extension AddQuestionnaireQuestionRequest {
    public static var addQuestionnaireQuestion: Self { .init(method: .post) }
}

public typealias RemoveQuestionnaireQuestionRequest = Request<QuestionnaireQuestionPayload, StandardPostResponse>
extension RemoveQuestionnaireQuestionRequest {
    public static var removeQuestionnaireQuestion: Self { .init(method: .delete) }
}

public typealias RenameQuestionnaireRequest = Request<RenameQuestionnairePayload, StandardPostResponse>
extension RenameQuestionnaireRequest {
    public static var renameQuestionnaire: Self { .init(method: .put) }
}

public typealias ReorderQuestionnaireRequest = Request<ReorderQuestionnairePayload, StandardPostResponse>
extension ReorderQuestionnaireRequest {
    public static var reorderQuestionnaire: Self { .init(method: .put) }
}

public typealias DeleteQuestionnaireRequest = Request<QuestionnaireIdPayload, StandardPostResponse>
extension DeleteQuestionnaireRequest {
    public static var deleteQuestionnaire: Self { .init(method: .delete) }
}

public typealias DeleteMyQuestionnaireAnswersRequest = Request<QuestionnaireIdPayload, StandardPostResponse>
extension DeleteMyQuestionnaireAnswersRequest {
    public static var deleteMyQuestionnaireAnswers: Self { .init(method: .delete) }
}

/// POST because the questionnaire id travels in the body.
public typealias QuestionnaireDetailRequest = Request<QuestionnaireIdPayload, QuestionnaireDetail>
extension QuestionnaireDetailRequest {
    public static var questionnaireDetail: Self { .init(method: .post) }
}

/// POST because the questionnaire id travels in the body.
public typealias QuestionnaireContentsRequest = Request<QuestionnaireIdPayload, QuestionnaireWithQuestions>
extension QuestionnaireContentsRequest {
    public static var questionnaireContents: Self { .init(method: .post) }
}

public typealias MyQuestionnairesRequest = Request<Empty, [MyQuestionnaire]>
extension MyQuestionnairesRequest {
    public static var myQuestionnaires: Self { .init(method: .get) }
}

/// POST because the paging travels in the body.
public typealias BrowseQuestionnairesRequest = Request<BrowseQuestionnairesPayload, [BrowseQuestionnaire]>
extension BrowseQuestionnairesRequest {
    public static var browseQuestionnaires: Self { .init(method: .post) }
}

/// POST because the paging travels in the body.
public typealias MyQuestionsRequest = Request<MyQuestionsPayload, [QuestionSummary]>
extension MyQuestionsRequest {
    public static var myQuestions: Self { .init(method: .post) }
}

// MARK: - Subscriptions

public typealias MemberSubscriptionsRequest = Request<Empty, [SubscriptionListEntry]>
extension MemberSubscriptionsRequest {
    public static var memberSubscriptions: Self { .init(method: .get) }
}

public typealias SubscribeToQuestionnaireRequest = Request<QuestionnaireIdPayload, StandardPostResponse>
extension SubscribeToQuestionnaireRequest {
    public static var subscribeToQuestionnaire: Self { .init(method: .post) }
}

public typealias UnsubscribeFromQuestionnaireRequest = Request<QuestionnaireIdPayload, StandardPostResponse>
extension UnsubscribeFromQuestionnaireRequest {
    public static var unsubscribeFromQuestionnaire: Self { .init(method: .delete) }
}

public typealias SetQuestionnaireSubscriptionMutedRequest = Request<
    SetQuestionnaireSubscriptionMutedPayload,
    StandardPostResponse
>
extension SetQuestionnaireSubscriptionMutedRequest {
    public static var setQuestionnaireSubscriptionMuted: Self { .init(method: .put) }
}

public typealias SubscribeToMemberRequest = Request<MemberIdPayload, StandardPostResponse>
extension SubscribeToMemberRequest {
    public static var subscribeToMember: Self { .init(method: .post) }
}

public typealias UnsubscribeFromMemberRequest = Request<MemberIdPayload, StandardPostResponse>
extension UnsubscribeFromMemberRequest {
    public static var unsubscribeFromMember: Self { .init(method: .delete) }
}

public typealias SetMemberSubscriptionMutedRequest = Request<SetMemberSubscriptionMutedPayload, StandardPostResponse>
extension SetMemberSubscriptionMutedRequest {
    public static var setMemberSubscriptionMuted: Self { .init(method: .put) }
}

// MARK: - Members and author visibility

/// POST because the member id travels in the body.
public typealias MemberProfileRequest = Request<MemberIdPayload, MemberProfile>
extension MemberProfileRequest {
    public static var memberProfile: Self { .init(method: .post) }
}

public typealias SetQuestionAuthorVisibilityRequest = Request<SetQuestionAuthorVisibilityPayload, StandardPostResponse>
extension SetQuestionAuthorVisibilityRequest {
    public static var setQuestionAuthorVisibility: Self { .init(method: .put) }
}

/// POST because the question id travels in the body.
public typealias QuestionAuthorVisibilityHistoryRequest = Request<QuestionIdPayload, [AuthorVisibilityAudit]>
extension QuestionAuthorVisibilityHistoryRequest {
    public static var questionAuthorVisibilityHistory: Self { .init(method: .post) }
}

// MARK: - Matchmaking profiles

/// POST because the context id travels in the body.
public typealias MatchmakingProfilesRequest = Request<ContextIdPayload, [MatchmakingProfileSummary]>
extension MatchmakingProfilesRequest {
    public static var matchmakingProfiles: Self { .init(method: .post) }
}

public typealias CreateMatchmakingProfileRequest = Request<CreateMatchmakingProfilePayload, MatchmakingProfileSummary>
extension CreateMatchmakingProfileRequest {
    public static var createMatchmakingProfile: Self { .init(method: .post) }
}

public typealias DuplicateMatchmakingProfileRequest = Request<MatchmakingProfileNamePayload, MatchmakingProfileSummary>
extension DuplicateMatchmakingProfileRequest {
    public static var duplicateMatchmakingProfile: Self { .init(method: .post) }
}

public typealias RenameMatchmakingProfileRequest = Request<MatchmakingProfileNamePayload, StandardPostResponse>
extension RenameMatchmakingProfileRequest {
    public static var renameMatchmakingProfile: Self { .init(method: .put) }
}

public typealias DeleteMatchmakingProfileRequest = Request<MatchmakingProfileIdPayload, StandardPostResponse>
extension DeleteMatchmakingProfileRequest {
    public static var deleteMatchmakingProfile: Self { .init(method: .delete) }
}

public typealias ActivateMatchmakingProfileRequest = Request<MatchmakingProfileIdPayload, StandardPostResponse>
extension ActivateMatchmakingProfileRequest {
    public static var activateMatchmakingProfile: Self { .init(method: .put) }
}

public typealias DeactivateMatchmakingProfileRequest = Request<MatchmakingProfileIdPayload, StandardPostResponse>
extension DeactivateMatchmakingProfileRequest {
    public static var deactivateMatchmakingProfile: Self { .init(method: .put) }
}

// MARK: - Diagnostics

/// No token: a decode failure often happens on the call that would have signed the member in.
public typealias ReportDecodeFailureRequest = Request<DecodeFailureReport, StandardPostResponse>
extension ReportDecodeFailureRequest {
    public static var reportDecodeFailure: Self { .init(method: .post, assertHasAccessToken: false) }
}

/// Operator only.
public typealias DecodeFailureReportsRequest = Request<Empty, [DecodeFailureReportEntry]>
extension DecodeFailureReportsRequest {
    public static var decodeFailureReports: Self { .init(method: .get) }
}

// MARK: - Email verification

public typealias VerifyEmailCodeRequest = Request<VerifyEmailCodePayload, StandardPostResponse>
extension VerifyEmailCodeRequest {
    public static var verifyEmailCode: Self { .init(method: .post, assertHasAccessToken: false) }
}

// MARK: - Subscription debug (non production deployments only)

public typealias SubscriptionDebugSetTierRequest = Request<SubscriptionDebugSetTierPayload, StandardPostResponse>
extension SubscriptionDebugSetTierRequest {
    public static var subscriptionDebugSetTier: Self { .init(method: .post) }
}

/// POST because the user id travels in the body.
public typealias SubscriptionDebugStateRequest = Request<SubscriptionDebugStatePayload, [SubscriptionDebugStateEntry]>
extension SubscriptionDebugStateRequest {
    public static var subscriptionDebugState: Self { .init(method: .post) }
}

// MARK: - Public file uploads

public typealias UploadPublicFileRequest = Request<UploadPublicFilePayload, StandardPostResponse>
extension UploadPublicFileRequest {
    public static var uploadPublicFile: Self { .init(method: .post) }
}

/// The body is the file's raw bytes.
public typealias UploadTermsOfServiceRequest = Request<Data, StandardPostResponse>
extension UploadTermsOfServiceRequest {
    public static var uploadTermsOfService: Self { .init(method: .post) }
}

/// The body is the file's raw bytes.
public typealias UploadContactInfoRequest = Request<Data, StandardPostResponse>
extension UploadContactInfoRequest {
    public static var uploadContactInfo: Self { .init(method: .post) }
}
