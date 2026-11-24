//
//  MemberRoutesTests.swift
//  These contracts replace string routes on the server, so a changed path or method is a 404 or
//  405 for every installed build. Pin both.
//

import XCTest
import StrongContractClient
@testable import AkinFrontBackModels

final class MemberRoutesTests: XCTestCase {

    func testPathsAndMethodsMatchTheRoutesTheyReplaced() {
        let pinned: [(expected: String, actual: String)] = [
            ("POST api/user/:id/requirements", "\(SetRequirementContract.setRequirement.method.rawValue) \(SetRequirementContract.setRequirement.path)"), // literal-ok: the wire format fixes this string
            ("GET api/user/:id/requirements/exclusion-cost", "\(ExclusionCostContract.exclusionCost.method.rawValue) \(ExclusionCostContract.exclusionCost.path)"), // literal-ok: the wire format fixes this string
            ("GET api/user/:id/redundancy-explanation", "\(RedundancyExplanationContract.redundancyExplanation.method.rawValue) \(RedundancyExplanationContract.redundancyExplanation.path)"), // literal-ok: the wire format fixes this string
            ("POST api/user/:id/venue-preferences", "\(SetVenuePreferencesContract.setVenuePreferences.method.rawValue) \(SetVenuePreferencesContract.setVenuePreferences.path)"), // literal-ok: the wire format fixes this string
            ("POST api/user/:id/algorithm", "\(SetAlgorithmContract.setAlgorithm.method.rawValue) \(SetAlgorithmContract.setAlgorithm.path)"), // literal-ok: the wire format fixes this string
            ("POST api/user/:id/contexts", "\(CreateContextContract.createContext.method.rawValue) \(CreateContextContract.createContext.path)"), // literal-ok: the wire format fixes this string
            ("GET api/user/:id/contexts/browse", "\(BrowseContextsContract.browseContexts.method.rawValue) \(BrowseContextsContract.browseContexts.path)"), // literal-ok: the wire format fixes this string
            ("POST api/user/:id/questionnaires", "\(CreateQuestionnaireContract.createQuestionnaire.method.rawValue) \(CreateQuestionnaireContract.createQuestionnaire.path)"), // literal-ok: the wire format fixes this string
            ("POST api/user/:id/questionnaires/:questionnaireID/questions", "\(AddQuestionnaireQuestionContract.addQuestionnaireQuestion.method.rawValue) \(AddQuestionnaireQuestionContract.addQuestionnaireQuestion.path)"), // literal-ok: the wire format fixes this string
            ("PUT api/user/:id/questionnaires/:questionnaireID/title", "\(RenameQuestionnaireContract.renameQuestionnaire.method.rawValue) \(RenameQuestionnaireContract.renameQuestionnaire.path)"), // literal-ok: the wire format fixes this string
            ("PUT api/user/:id/questionnaires/:questionnaireID/order", "\(ReorderQuestionnaireContract.reorderQuestionnaire.method.rawValue) \(ReorderQuestionnaireContract.reorderQuestionnaire.path)"), // literal-ok: the wire format fixes this string
            ("GET api/user/:id/questionnaires/:questionnaireID/detail", "\(QuestionnaireDetailContract.questionnaireDetail.method.rawValue) \(QuestionnaireDetailContract.questionnaireDetail.path)"), // literal-ok: the wire format fixes this string
            ("GET api/user/:id/questionnaires/:questionnaireID", "\(QuestionnaireContentsContract.questionnaireContents.method.rawValue) \(QuestionnaireContentsContract.questionnaireContents.path)"), // literal-ok: the wire format fixes this string
            ("GET api/user/:id/questionnaires", "\(MyQuestionnairesContract.myQuestionnaires.method.rawValue) \(MyQuestionnairesContract.myQuestionnaires.path)"), // literal-ok: the wire format fixes this string
            ("GET api/user/:id/questionnaires/browse", "\(BrowseQuestionnairesContract.browseQuestionnaires.method.rawValue) \(BrowseQuestionnairesContract.browseQuestionnaires.path)"), // literal-ok: the wire format fixes this string
            ("GET api/user/:id/questions", "\(MyQuestionsContract.myQuestions.method.rawValue) \(MyQuestionsContract.myQuestions.path)"), // literal-ok: the wire format fixes this string
            ("GET api/user/:id/subscriptions", "\(MemberSubscriptionsContract.memberSubscriptions.method.rawValue) \(MemberSubscriptionsContract.memberSubscriptions.path)"), // literal-ok: the wire format fixes this string
            ("PUT api/user/:id/questionnaires/:questionnaireID/subscription/muted", "\(SetMemberSubscriptionMutedRequest.setQuestionnaireSubscriptionMuted.method.rawValue) \(SetMemberSubscriptionMutedRequest.setQuestionnaireSubscriptionMuted.path)"), // literal-ok: the wire format fixes this string
            ("PUT api/user/:id/questions/:questionID/authorVisibility", "\(SetAuthorVisibilityContract.setQuestionAuthorVisibility.method.rawValue) \(SetAuthorVisibilityContract.setQuestionAuthorVisibility.path)"), // literal-ok: the wire format fixes this string
            ("GET api/user/:id/questions/:questionID/authorVisibility/history", "\(AuthorVisibilityHistoryContract.questionAuthorVisibilityHistory.method.rawValue) \(AuthorVisibilityHistoryContract.questionAuthorVisibilityHistory.path)"), // literal-ok: the wire format fixes this string
            ("GET api/user/:id/members/:memberID/profile", "\(MemberProfileContract.memberProfile.method.rawValue) \(MemberProfileContract.memberProfile.path)"), // literal-ok: the wire format fixes this string
            ("GET api/user/:id/contexts/:contextID/profiles", "\(MatchmakingProfilesContract.matchmakingProfiles.method.rawValue) \(MatchmakingProfilesContract.matchmakingProfiles.path)"), // literal-ok: the wire format fixes this string
            ("POST api/user/:id/contexts/:contextID/profiles", "\(NamedMatchmakingProfileContract.createMatchmakingProfile.method.rawValue) \(NamedMatchmakingProfileContract.createMatchmakingProfile.path)"), // literal-ok: the wire format fixes this string
            ("POST api/user/:id/profiles/:profileID/duplicate", "\(NamedMatchmakingProfileContract.duplicateMatchmakingProfile.method.rawValue) \(NamedMatchmakingProfileContract.duplicateMatchmakingProfile.path)"), // literal-ok: the wire format fixes this string
            ("PUT api/user/:id/profiles/:profileID/name", "\(RenameMatchmakingProfileContract.renameMatchmakingProfile.method.rawValue) \(RenameMatchmakingProfileContract.renameMatchmakingProfile.path)"), // literal-ok: the wire format fixes this string
            ("POST api/user/:id/contexts/:contextID/adopt", "\(PathOnlyRequest.adoptContext.method.rawValue) \(PathOnlyRequest.adoptContext.path)"), // literal-ok: the wire format fixes this string
            ("DELETE api/user/:id/questionnaires/:questionnaireID/questions/:questionID", "\(PathOnlyRequest.removeQuestionnaireQuestion.method.rawValue) \(PathOnlyRequest.removeQuestionnaireQuestion.path)"), // literal-ok: the wire format fixes this string
            ("DELETE api/user/:id/questionnaires/:questionnaireID", "\(PathOnlyRequest.deleteQuestionnaire.method.rawValue) \(PathOnlyRequest.deleteQuestionnaire.path)"), // literal-ok: the wire format fixes this string
            ("POST api/user/:id/questionnaires/:questionnaireID/subscription", "\(PathOnlyRequest.subscribeToQuestionnaire.method.rawValue) \(PathOnlyRequest.subscribeToQuestionnaire.path)"), // literal-ok: the wire format fixes this string
            ("DELETE api/user/:id/questionnaires/:questionnaireID/subscription", "\(PathOnlyRequest.unsubscribeFromQuestionnaire.method.rawValue) \(PathOnlyRequest.unsubscribeFromQuestionnaire.path)"), // literal-ok: the wire format fixes this string
            ("DELETE api/user/:id/profiles/:profileID", "\(PathOnlyRequest.deleteMatchmakingProfile.method.rawValue) \(PathOnlyRequest.deleteMatchmakingProfile.path)"), // literal-ok: the wire format fixes this string
            ("PUT api/user/:id/profiles/:profileID/active", "\(PathOnlyRequest.activateMatchmakingProfile.method.rawValue) \(PathOnlyRequest.activateMatchmakingProfile.path)"), // literal-ok: the wire format fixes this string
            ("DELETE api/user/:id/profiles/:profileID/active", "\(PathOnlyRequest.deactivateMatchmakingProfile.method.rawValue) \(PathOnlyRequest.deactivateMatchmakingProfile.path)"), // literal-ok: the wire format fixes this string
            ("POST api/diagnostics/decode-failure", "\(ReportDecodeFailureContract.reportDecodeFailure.method.rawValue) \(ReportDecodeFailureContract.reportDecodeFailure.path)"), // literal-ok: the wire format fixes this string
            ("GET api/diagnostics/decode-failure", "\(DecodeFailureReportsContract.decodeFailureReports.method.rawValue) \(DecodeFailureReportsContract.decodeFailureReports.path)"), // literal-ok: the wire format fixes this string
            ("POST testPushRequest", "\(TestPushRequest.testPushRequest.method.rawValue) \(TestPushRequest.testPushRequest.path)"), // literal-ok: the wire format fixes this string
            ("POST testPushKitRequest", "\(TestPushKitRequest.testPushKitRequest.method.rawValue) \(TestPushKitRequest.testPushKitRequest.path)"), // literal-ok: the wire format fixes this string
            ("POST api/advertiser/login", "\(AdvertiserLoginContract.advertiserLogin.method.rawValue) \(AdvertiserLoginContract.advertiserLogin.path)"), // literal-ok: the wire format fixes this string
            ("GET api/advertiser/me", "\(AdvertiserMeContract.advertiserMe.method.rawValue) \(AdvertiserMeContract.advertiserMe.path)"), // literal-ok: the wire format fixes this string
        ]
        for pair in pinned {
            XCTAssertEqual(pair.actual, pair.expected)
        }
    }

    func testFillingReplacesOnlyNamedParameters() {
        let filled = PathOnlyRequest.removeQuestionnaireQuestion.filling(["id": "A", "questionnaireID": "B"])
        XCTAssertEqual(filled.path, "api/user/A/questionnaires/B/questions/:questionID") // literal-ok: the wire format fixes this string
        XCTAssertEqual(filled.method, PathOnlyRequest.removeQuestionnaireQuestion.method)
    }

    func testQueryingKeepsThePath() {
        let paged = BrowseQuestionnairesContract.browseQuestionnaires
            .filling(["id": "A"])
            .querying([URLQueryItem(name: "page", value: "1")])
        XCTAssertEqual(paged.path, "api/user/A/questionnaires/browse") // literal-ok: the wire format fixes this string
        XCTAssertEqual(paged.baseComponents.queryItems, [URLQueryItem(name: "page", value: "1")])
    }
}
