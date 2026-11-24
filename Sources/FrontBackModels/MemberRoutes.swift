//
//  MemberRoutes.swift
//  AkinFrontBackModels
//
//  Contracts for the `api/user/:id/...` routes and the other JSON routes the server used to
//  register by string. Each keeps the method and path it already answers on, so installed builds
//  are unaffected. Fill the `:name` components with `filling(_:)` before sending.
//

import Foundation
import StrongContractClient

// MARK: - Responses that had no shared type

/// What `createQuestionnaire` answers with: the two fields that round trip.
public struct CreatedQuestionnaire: Codable, Hashable, Sendable, Identifiable {
    public let id: UUID
    public let title: String

    public init(id: UUID, title: String) {
        self.id = id
        self.title = title
    }
}

/// Another member's profile as the caller may see it. Counts only, never the content itself.
public struct MemberProfileDTO: Codable, Hashable, Sendable {
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

// MARK: - Requirements, preferences, algorithm

public typealias SetRequirementContract = Request<SetRequirementRequest, ExclusionCostResponse>
extension SetRequirementContract {
    /// POST. Sets one requirement and answers with what it now excludes.
    public static var setRequirement: Self {
        .init(path: "api/user/:id/requirements", method: .post)
    }
}

public typealias ExclusionCostContract = Request<Empty, ExclusionCostResponse>
extension ExclusionCostContract {
    /// GET. What the caller's current requirements exclude.
    public static var exclusionCost: Self {
        .init(path: "api/user/:id/requirements/exclusion-cost", method: .get)
    }
}

public typealias RedundancyExplanationContract = Request<Empty, RedundancyExplanationResponse>
extension RedundancyExplanationContract {
    /// GET. Why some of the caller's requirements are redundant.
    public static var redundancyExplanation: Self {
        .init(path: "api/user/:id/redundancy-explanation", method: .get)
    }
}

public typealias SetVenuePreferencesContract = Request<VenuePreferenceRequest, VenueExclusionWarning>
extension SetVenuePreferencesContract {
    /// POST. Saves venue preferences and warns when they exclude every venue.
    public static var setVenuePreferences: Self {
        .init(path: "api/user/:id/venue-preferences", method: .post)
    }
}

public typealias SetAlgorithmContract = Request<SetAlgorithmRequest, Data>
extension SetAlgorithmContract {
    /// POST. Chooses the matching algorithm for the caller.
    public static var setAlgorithm: Self {
        .init(path: "api/user/:id/algorithm", method: .post)
    }
}

// MARK: - Contexts

public typealias CreateContextContract = Request<CreateContextRequest, Data>
extension CreateContextContract {
    /// POST. Creates a context.
    public static var createContext: Self {
        .init(path: "api/user/:id/contexts", method: .post)
    }
}

public typealias BrowseContextsContract = Request<Empty, [BrowseContextDTO]>
extension BrowseContextsContract {
    /// GET. Contexts the caller can adopt.
    public static var browseContexts: Self {
        .init(path: "api/user/:id/contexts/browse", method: .get)
    }
}

// MARK: - Questionnaires

public typealias CreateQuestionnaireContract = Request<CreateQuestionnaireRequest, CreatedQuestionnaire>
extension CreateQuestionnaireContract {
    /// POST. Creates a questionnaire owned by the caller.
    public static var createQuestionnaire: Self {
        .init(path: "api/user/:id/questionnaires", method: .post)
    }
}

public typealias AddQuestionnaireQuestionContract = Request<AddQuestionnaireQuestionRequest, Data>
extension AddQuestionnaireQuestionContract {
    /// POST. Adds one of the caller's questions to their questionnaire.
    public static var addQuestionnaireQuestion: Self {
        .init(path: "api/user/:id/questionnaires/:questionnaireID/questions", method: .post)
    }
}

public typealias RenameQuestionnaireContract = Request<RenameQuestionnaireRequest, Data>
extension RenameQuestionnaireContract {
    /// PUT. Renames the caller's questionnaire.
    public static var renameQuestionnaire: Self {
        .init(path: "api/user/:id/questionnaires/:questionnaireID/title", method: .put)
    }
}

public typealias ReorderQuestionnaireContract = Request<ReorderQuestionnaireRequest, Data>
extension ReorderQuestionnaireContract {
    /// PUT. Sets the order of a questionnaire's questions.
    public static var reorderQuestionnaire: Self {
        .init(path: "api/user/:id/questionnaires/:questionnaireID/order", method: .put)
    }
}

public typealias QuestionnaireDetailContract = Request<Empty, QuestionnaireDetailDTO>
extension QuestionnaireDetailContract {
    /// GET. One questionnaire with its questions and counts.
    public static var questionnaireDetail: Self {
        .init(path: "api/user/:id/questionnaires/:questionnaireID/detail", method: .get)
    }
}

public typealias QuestionnaireContentsContract = Request<Empty, QuestionnaireWithQuestions>
extension QuestionnaireContentsContract {
    /// GET. One questionnaire with its question ids in order.
    public static var questionnaireContents: Self {
        .init(path: "api/user/:id/questionnaires/:questionnaireID", method: .get)
    }
}

public typealias MyQuestionnairesContract = Request<Empty, [MyQuestionnaireDTO]>
extension MyQuestionnairesContract {
    /// GET. The caller's own questionnaires.
    public static var myQuestionnaires: Self {
        .init(path: "api/user/:id/questionnaires", method: .get)
    }
}

public typealias BrowseQuestionnairesContract = Request<Empty, [BrowseQuestionnaireDTO]>
extension BrowseQuestionnairesContract {
    /// GET. A page of questionnaires. Query: `page`, `per`, optional `includeSwitchedOff`.
    public static var browseQuestionnaires: Self {
        .init(path: "api/user/:id/questionnaires/browse", method: .get)
    }
}

public typealias MyQuestionsContract = Request<Empty, [QuestionSummaryDTO]>
extension MyQuestionsContract {
    /// GET. The questions the caller wrote. Query: `page`, `per`.
    public static var myQuestions: Self {
        .init(path: "api/user/:id/questions", method: .get)
    }
}

// MARK: - Subscriptions and author visibility

public typealias MemberSubscriptionsContract = Request<Empty, [SubscriptionListEntry]>
extension MemberSubscriptionsContract {
    /// GET. Everything the caller subscribes to.
    public static var memberSubscriptions: Self {
        .init(path: "api/user/:id/subscriptions", method: .get)
    }
}

extension SetMemberSubscriptionMutedRequest {
    /// PUT. Mutes or unmutes the caller's subscription to a questionnaire.
    public static var setQuestionnaireSubscriptionMuted: Self {
        .init(path: "api/user/:id/questionnaires/:questionnaireID/subscription/muted", method: .put)
    }
}

public typealias SetAuthorVisibilityContract = Request<SetAuthorVisibilityRequest, Data>
extension SetAuthorVisibilityContract {
    /// PUT. Whether the caller's question names them.
    public static var setQuestionAuthorVisibility: Self {
        .init(path: "api/user/:id/questions/:questionID/authorVisibility", method: .put)
    }
}

public typealias AuthorVisibilityHistoryContract = Request<Empty, [AuthorVisibilityAuditDTO]>
extension AuthorVisibilityHistoryContract {
    /// GET. Every change to a question's author visibility.
    public static var questionAuthorVisibilityHistory: Self {
        .init(path: "api/user/:id/questions/:questionID/authorVisibility/history", method: .get)
    }
}

public typealias MemberProfileContract = Request<Empty, MemberProfileDTO>
extension MemberProfileContract {
    /// GET. Another member's profile as the caller may see it.
    public static var memberProfile: Self {
        .init(path: "api/user/:id/members/:memberID/profile", method: .get)
    }
}

// MARK: - Matchmaking profiles

public typealias MatchmakingProfilesContract = Request<Empty, [MatchmakingProfileSummary]>
extension MatchmakingProfilesContract {
    /// GET. The caller's profiles in one context.
    public static var matchmakingProfiles: Self {
        .init(path: "api/user/:id/contexts/:contextID/profiles", method: .get)
    }
}

public typealias NamedMatchmakingProfileContract = Request<NameProfileRequest, MatchmakingProfileSummary>
extension NamedMatchmakingProfileContract {
    /// POST. Creates a profile in a context.
    public static var createMatchmakingProfile: Self {
        .init(path: "api/user/:id/contexts/:contextID/profiles", method: .post)
    }

    /// POST. Copies a profile under a new name.
    public static var duplicateMatchmakingProfile: Self {
        .init(path: "api/user/:id/profiles/:profileID/duplicate", method: .post)
    }
}

public typealias RenameMatchmakingProfileContract = Request<NameProfileRequest, Data>
extension RenameMatchmakingProfileContract {
    /// PUT. Renames a profile.
    public static var renameMatchmakingProfile: Self {
        .init(path: "api/user/:id/profiles/:profileID/name", method: .put)
    }
}

// MARK: - Routes with no body that answer with a status

extension PathOnlyRequest {
    /// POST. The caller adopts a context.
    public static var adoptContext: Self {
        .init(path: "api/user/:id/contexts/:contextID/adopt", method: .post)
    }

    /// DELETE. Removes a question from the caller's questionnaire.
    public static var removeQuestionnaireQuestion: Self {
        .init(path: "api/user/:id/questionnaires/:questionnaireID/questions/:questionID", method: .delete)
    }

    /// DELETE. Deletes or withdraws the caller's questionnaire.
    public static var deleteQuestionnaire: Self {
        .init(path: "api/user/:id/questionnaires/:questionnaireID", method: .delete)
    }

    /// POST. The caller subscribes to a questionnaire.
    public static var subscribeToQuestionnaire: Self {
        .init(path: "api/user/:id/questionnaires/:questionnaireID/subscription", method: .post)
    }

    /// DELETE. The caller unsubscribes from a questionnaire.
    public static var unsubscribeFromQuestionnaire: Self {
        .init(path: "api/user/:id/questionnaires/:questionnaireID/subscription", method: .delete)
    }

    /// DELETE. Deletes a profile.
    public static var deleteMatchmakingProfile: Self {
        .init(path: "api/user/:id/profiles/:profileID", method: .delete)
    }

    /// PUT. Makes a profile the active one in its context.
    public static var activateMatchmakingProfile: Self {
        .init(path: "api/user/:id/profiles/:profileID/active", method: .put)
    }

    /// DELETE. Stops a profile being the active one.
    public static var deactivateMatchmakingProfile: Self {
        .init(path: "api/user/:id/profiles/:profileID/active", method: .delete)
    }
}

// MARK: - Diagnostics

public typealias ReportDecodeFailureContract = Request<DecodeFailureReport, Data>
extension ReportDecodeFailureContract {
    /// POST. The app reports a reply it could not decode.
    public static var reportDecodeFailure: Self {
        .init(path: "api/diagnostics/decode-failure", method: .post)
    }
}

public typealias DecodeFailureReportsContract = Request<Empty, Data>
extension DecodeFailureReportsContract {
    /// GET. Admin only: the stored decode failure reports, as the server's stored rows.
    public static var decodeFailureReports: Self {
        .init(path: "api/diagnostics/decode-failure", method: .get)
    }
}
