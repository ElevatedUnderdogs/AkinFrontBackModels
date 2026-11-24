//
//  MemberRoutesTests.swift
//  Each contract's path is its static var's name and carries no arguments.
//

import XCTest
import StrongContractClient
@testable import AkinFrontBackModels

final class MemberRoutesTests: XCTestCase {

    func testEachPathIsTheStaticVarNameWithNoArguments() {
        let pinned: [(expected: String, actual: String)] = [
            ("setRequirement", SetRequirementRequest.setRequirement.path), // literal-ok: the wire format fixes this string
            ("exclusionCost", ExclusionCostRequest.exclusionCost.path), // literal-ok: the wire format fixes this string
            ("redundancyExplanation", RedundancyExplanationRequest.redundancyExplanation.path), // literal-ok: the wire format fixes this string
            ("setVenuePreferences", SetVenuePreferencesRequest.setVenuePreferences.path), // literal-ok: the wire format fixes this string
            ("setAlgorithm", SetAlgorithmRequest.setAlgorithm.path), // literal-ok: the wire format fixes this string
            ("createContext", CreateContextRequest.createContext.path), // literal-ok: the wire format fixes this string
            ("adoptContext", AdoptContextRequest.adoptContext.path), // literal-ok: the wire format fixes this string
            ("browseContexts", BrowseContextsRequest.browseContexts.path), // literal-ok: the wire format fixes this string
            ("createQuestionnaire", CreateQuestionnaireRequest.createQuestionnaire.path), // literal-ok: the wire format fixes this string
            ("addQuestionnaireQuestion", AddQuestionnaireQuestionRequest.addQuestionnaireQuestion.path), // literal-ok: the wire format fixes this string
            ("removeQuestionnaireQuestion", RemoveQuestionnaireQuestionRequest.removeQuestionnaireQuestion.path), // literal-ok: the wire format fixes this string
            ("renameQuestionnaire", RenameQuestionnaireRequest.renameQuestionnaire.path), // literal-ok: the wire format fixes this string
            ("reorderQuestionnaire", ReorderQuestionnaireRequest.reorderQuestionnaire.path), // literal-ok: the wire format fixes this string
            ("deleteQuestionnaire", DeleteQuestionnaireRequest.deleteQuestionnaire.path), // literal-ok: the wire format fixes this string
            ("deleteMyQuestionnaireAnswers", DeleteMyQuestionnaireAnswersRequest.deleteMyQuestionnaireAnswers.path), // literal-ok: the wire format fixes this string
            ("questionnaireDetail", QuestionnaireDetailRequest.questionnaireDetail.path), // literal-ok: the wire format fixes this string
            ("questionnaireContents", QuestionnaireContentsRequest.questionnaireContents.path), // literal-ok: the wire format fixes this string
            ("myQuestionnaires", MyQuestionnairesRequest.myQuestionnaires.path), // literal-ok: the wire format fixes this string
            ("browseQuestionnaires", BrowseQuestionnairesRequest.browseQuestionnaires.path), // literal-ok: the wire format fixes this string
            ("myQuestions", MyQuestionsRequest.myQuestions.path), // literal-ok: the wire format fixes this string
            ("memberSubscriptions", MemberSubscriptionsRequest.memberSubscriptions.path), // literal-ok: the wire format fixes this string
            ("subscribeToQuestionnaire", SubscribeToQuestionnaireRequest.subscribeToQuestionnaire.path), // literal-ok: the wire format fixes this string
            ("unsubscribeFromQuestionnaire", UnsubscribeFromQuestionnaireRequest.unsubscribeFromQuestionnaire.path), // literal-ok: the wire format fixes this string
            ("setQuestionnaireSubscriptionMuted", SetQuestionnaireSubscriptionMutedRequest.setQuestionnaireSubscriptionMuted.path), // literal-ok: the wire format fixes this string
            ("subscribeToMember", SubscribeToMemberRequest.subscribeToMember.path), // literal-ok: the wire format fixes this string
            ("unsubscribeFromMember", UnsubscribeFromMemberRequest.unsubscribeFromMember.path), // literal-ok: the wire format fixes this string
            ("setMemberSubscriptionMuted", SetMemberSubscriptionMutedRequest.setMemberSubscriptionMuted.path), // literal-ok: the wire format fixes this string
            ("memberProfile", MemberProfileRequest.memberProfile.path), // literal-ok: the wire format fixes this string
            ("setQuestionAuthorVisibility", SetQuestionAuthorVisibilityRequest.setQuestionAuthorVisibility.path), // literal-ok: the wire format fixes this string
            ("questionAuthorVisibilityHistory", QuestionAuthorVisibilityHistoryRequest.questionAuthorVisibilityHistory.path), // literal-ok: the wire format fixes this string
            ("matchmakingProfiles", MatchmakingProfilesRequest.matchmakingProfiles.path), // literal-ok: the wire format fixes this string
            ("createMatchmakingProfile", CreateMatchmakingProfileRequest.createMatchmakingProfile.path), // literal-ok: the wire format fixes this string
            ("duplicateMatchmakingProfile", DuplicateMatchmakingProfileRequest.duplicateMatchmakingProfile.path), // literal-ok: the wire format fixes this string
            ("renameMatchmakingProfile", RenameMatchmakingProfileRequest.renameMatchmakingProfile.path), // literal-ok: the wire format fixes this string
            ("deleteMatchmakingProfile", DeleteMatchmakingProfileRequest.deleteMatchmakingProfile.path), // literal-ok: the wire format fixes this string
            ("activateMatchmakingProfile", ActivateMatchmakingProfileRequest.activateMatchmakingProfile.path), // literal-ok: the wire format fixes this string
            ("deactivateMatchmakingProfile", DeactivateMatchmakingProfileRequest.deactivateMatchmakingProfile.path), // literal-ok: the wire format fixes this string
            ("reportDecodeFailure", ReportDecodeFailureRequest.reportDecodeFailure.path), // literal-ok: the wire format fixes this string
            ("decodeFailureReports", DecodeFailureReportsRequest.decodeFailureReports.path), // literal-ok: the wire format fixes this string
            ("verifyEmailCode", VerifyEmailCodeRequest.verifyEmailCode.path), // literal-ok: the wire format fixes this string
            ("subscriptionDebugSetTier", SubscriptionDebugSetTierRequest.subscriptionDebugSetTier.path), // literal-ok: the wire format fixes this string
            ("subscriptionDebugState", SubscriptionDebugStateRequest.subscriptionDebugState.path), // literal-ok: the wire format fixes this string
            ("uploadPublicFile", UploadPublicFileRequest.uploadPublicFile.path), // literal-ok: the wire format fixes this string
            ("uploadTermsOfService", UploadTermsOfServiceRequest.uploadTermsOfService.path), // literal-ok: the wire format fixes this string
            ("uploadContactInfo", UploadContactInfoRequest.uploadContactInfo.path), // literal-ok: the wire format fixes this string
            ("testPushRequest", TestPushRequest.testPushRequest.path), // literal-ok: the wire format fixes this string
            ("testPushKitRequest", TestPushKitRequest.testPushKitRequest.path), // literal-ok: the wire format fixes this string
            ("advertiserLogin", AdvertiserLoginRequest.advertiserLogin.path), // literal-ok: the wire format fixes this string
            ("advertiserMe", AdvertiserMeRequest.advertiserMe.path), // literal-ok: the wire format fixes this string
        ]
        for pair in pinned {
            XCTAssertEqual(pair.actual, pair.expected)
            XCTAssertFalse(pair.actual.contains(":"), pair.actual)
            XCTAssertFalse(pair.actual.contains("?"), pair.actual)
        }
    }
}
