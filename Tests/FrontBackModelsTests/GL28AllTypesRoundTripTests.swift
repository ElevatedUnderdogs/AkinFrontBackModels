//
//  GL28AllTypesRoundTripTests.swift
//  FrontBackModelsTests
//
//  GOAL_LOOP28 item 1.7. The types that round trip through the SAME coders both ends now use.
//  93 cases, one per type, generated from the package source so a type added later arrives
//  here absent and the coverage gate fails rather than the coverage quietly shrinking.
//
//  This file is NOT the whole of item 1.7 and an earlier version of this header said it was,
//  claiming "269 types, one case each" over a file of 93. The package has 265 Codable types.
//  The ones missing from here are the ones `GL28SynthDecoder` cannot build a value for, almost
//  all of them raw value enums and the types that contain one, and they are covered by
//  `GL28EnumRoundTripTests` and `GL28RemainingTypesRoundTripTests`. The coverage gate counts
//  across all three.
//
//  Names are FULLY QUALIFIED, 6 of them nested. Getting that right took two corrections and
//  both are worth knowing. Bare names do not resolve for a nested type, and one of them,
//  `Method`, resolved to something else entirely, `OpaquePointer`. Then `extension Greet.Update`
//  had to be read as naming a nested type rather than just `Greet`, or `Status` was qualified as
//  `Greet.Status`, which does not exist. The compiler found both, which is the argument for
//  generating a list and then BUILDING it rather than trusting the generator.
//
//  The instance is built by GL28SynthDecoder rather than by hand. Writing a sample for each of the
//  package's 265 Codable types by hand is 265 chances to write a sample that does not look like
//  the wire, and it is why "round trip every shared model" usually degrades into "round trip the
//  handful somebody got to".
//
//  The assertion compares encode(decode(encode(x))) against encode(x) as PARSED JSON rather than
//  using Equatable, for two reasons: not every type here is Equatable, and wire stability is the
//  property that matters. A field dropped on the way out, or renamed on the way in, changes it.
//
//  Parsed JSON and not BYTES, which this header claimed for a while and the body never did.
//  `JSONEncoder` makes no promise about key order, so a byte comparison reports a difference
//  between two encodings carrying identical content. The first version did compare bytes and
//  produced a run of failures reading `("89 bytes") is not equal to ("89 bytes")`.
//

import XCTest
@testable import AkinFrontBackModels

final class GL28AllTypesRoundTripTests: XCTestCase {

    private func assertRoundTrips<T: Codable>(_ type: T.Type, _ label: String) throws {
        let synthesized = try T(from: GL28SynthDecoder())
        let first = try JSONEncoder.akinWire.encode(GL28Envelope(value: synthesized))
        let decoded = try JSONDecoder.akinWire.decode(GL28Envelope<T>.self, from: first)
        let second = try JSONEncoder.akinWire.encode(decoded)
        // Compared as PARSED JSON, not as bytes. `JSONEncoder` does not promise key order, so a
        // byte comparison reports a difference between two encodings that carry exactly the
        // same content, which is noise rather than a contract failure. The first version of
        // this did compare bytes and produced a run of failures reading
        // `("89 bytes") is not equal to ("89 bytes")`, which is the shape of a test measuring
        // the wrong thing.
        let a = try JSONSerialization.jsonObject(with: first) as? NSDictionary
        let b = try JSONSerialization.jsonObject(with: second) as? NSDictionary
        XCTAssertNotNil(a, "\(label) did not encode to a JSON object")
        XCTAssertEqual(a, b, "\(label) did not survive the round trip")
    }

    func testGL28_1_7_roundTripsAcceptTermsRequest() throws { try assertRoundTrips(AcceptTermsRequest.self, "AcceptTermsRequest") }

    func testGL28_1_7_roundTripsAccountDeletionRequest() throws { try assertRoundTrips(AccountDeletionRequest.self, "AccountDeletionRequest") }

    func testGL28_1_7_roundTripsAdPlacement() throws { try assertRoundTrips(AdPlacement.self, "AdPlacement") }

    func testGL28_1_7_roundTripsAddDisplayPictureResponse() throws { try assertRoundTrips(AddDisplayPictureResponse.self, "AddDisplayPictureResponse") }

    func testGL28_1_7_roundTripsAddResponseResponse() throws { try assertRoundTrips(AddResponseResponse.self, "AddResponseResponse") }

    func testGL28_1_7_roundTripsAssertion() throws { try assertRoundTrips(Assertion.self, "Assertion") }

    func testGL28_1_7_roundTripsAuthorVisibility() throws { try assertRoundTrips(AuthorVisibility.self, "AuthorVisibility") }

    func testGL28_1_7_roundTripsAutomaticGreetCooldownSettings() throws { try assertRoundTrips(AutomaticGreetCooldownSettings.self, "AutomaticGreetCooldownSettings") }

    func testGL28_1_7_roundTripsAutomaticGreetStatus() throws { try assertRoundTrips(AutomaticGreetStatus.self, "AutomaticGreetStatus") }

    func testGL28_1_7_roundTripsAvailabilityPausePayload() throws { try assertRoundTrips(AvailabilityPausePayload.self, "AvailabilityPausePayload") }

    func testGL28_1_7_roundTripsAvailabilityPauseResponse() throws { try assertRoundTrips(AvailabilityPauseResponse.self, "AvailabilityPauseResponse") }

    func testGL28_1_7_roundTripsBlockUserResponse() throws { try assertRoundTrips(BlockUserResponse.self, "BlockUserResponse") }

    func testGL28_1_7_roundTripsCallKitConsentPayload() throws { try assertRoundTrips(CallKitConsentPayload.self, "CallKitConsentPayload") }

    func testGL28_1_7_roundTripsCallKitConsentResponse() throws { try assertRoundTrips(CallKitConsentResponse.self, "CallKitConsentResponse") }

    func testGL28_1_7_roundTripsCategory() throws { try assertRoundTrips(Category.self, "Category") }

    func testGL28_1_7_roundTripsChangeEmailResponse() throws { try assertRoundTrips(ChangeEmailResponse.self, "ChangeEmailResponse") }

    func testGL28_1_7_roundTripsChooseForMePayload() throws { try assertRoundTrips(ChooseForMePayload.self, "ChooseForMePayload") }

    func testGL28_1_7_roundTripsContents() throws { try assertRoundTrips(Contents.self, "Contents") }

    func testGL28_1_7_roundTripsContext() throws { try assertRoundTrips(Context.self, "Context") }

    func testGL28_1_7_roundTripsContext_Case() throws { try assertRoundTrips(Context.Case.self, "Context.Case") }

    func testGL28_1_7_roundTripsCoordinates() throws { try assertRoundTrips(Coordinates.self, "Coordinates") }

    func testGL28_1_7_roundTripsCredentialUpdate() throws { try assertRoundTrips(CredentialUpdate.self, "CredentialUpdate") }

    func testGL28_1_7_roundTripsDecodeFailureReport() throws { try assertRoundTrips(DecodeFailureReport.self, "DecodeFailureReport") }

    func testGL28_1_7_roundTripsEmailChange() throws { try assertRoundTrips(EmailChange.self, "EmailChange") }

    func testGL28_1_7_roundTripsExclusionWarning() throws { try assertRoundTrips(ExclusionWarning.self, "ExclusionWarning") }

    func testGL28_1_7_roundTripsGetQuestionsRequestPayload() throws { try assertRoundTrips(GetQuestionsRequestPayload.self, "GetQuestionsRequestPayload") }

    func testGL28_1_7_roundTripsGetUserInformationResponse() throws { try assertRoundTrips(GetUserInformationResponse.self, "GetUserInformationResponse") }

    func testGL28_1_7_roundTripsGreet_UserLocationCoordinate() throws { try assertRoundTrips(Greet.UserLocationCoordinate.self, "Greet.UserLocationCoordinate") }

    func testGL28_1_7_roundTripsGreet_UserLocationCoordinate_User() throws { try assertRoundTrips(Greet.UserLocationCoordinate.User.self, "Greet.UserLocationCoordinate.User") }

    func testGL28_1_7_roundTripsHideMeResponse() throws { try assertRoundTrips(HideMeResponse.self, "HideMeResponse") }

    func testGL28_1_7_roundTripsIceServer() throws { try assertRoundTrips(IceServer.self, "IceServer") }

    func testGL28_1_7_roundTripsIceServersResponse() throws { try assertRoundTrips(IceServersResponse.self, "IceServersResponse") }

    func testGL28_1_7_roundTripsImpactEmployeeSummary() throws { try assertRoundTrips(ImpactEmployeeSummary.self, "ImpactEmployeeSummary") }

    func testGL28_1_7_roundTripsImpactVenue() throws { try assertRoundTrips(ImpactVenue.self, "ImpactVenue") }

    func testGL28_1_7_roundTripsLanguageCodeEnum() throws { try assertRoundTrips(LanguageCodeEnum.self, "LanguageCodeEnum") }

    func testGL28_1_7_roundTripsLocationPayload() throws { try assertRoundTrips(LocationPayload.self, "LocationPayload") }

    func testGL28_1_7_roundTripsLocationUpdateResponse() throws { try assertRoundTrips(LocationUpdateResponse.self, "LocationUpdateResponse") }

    func testGL28_1_7_roundTripsLoginPayload() throws { try assertRoundTrips(LoginPayload.self, "LoginPayload") }

    func testGL28_1_7_roundTripsLogoutResponse() throws { try assertRoundTrips(LogoutResponse.self, "LogoutResponse") }

    func testGL28_1_7_roundTripsMakeResponseResponse() throws { try assertRoundTrips(MakeResponseResponse.self, "MakeResponseResponse") }

    func testGL28_1_7_roundTripsMarketAnswer() throws { try assertRoundTrips(MarketAnswer.self, "MarketAnswer") }

    func testGL28_1_7_roundTripsMarketQuery() throws { try assertRoundTrips(MarketQuery.self, "MarketQuery") }

    func testGL28_1_7_roundTripsMatchmakingProfile() throws { try assertRoundTrips(MatchmakingProfile.self, "MatchmakingProfile") }

    func testGL28_1_7_roundTripsMatchmakingProfileSummary() throws { try assertRoundTrips(MatchmakingProfileSummary.self, "MatchmakingProfileSummary") }

    func testGL28_1_7_roundTripsNearbyEmptyStateResponse() throws { try assertRoundTrips(NearbyEmptyStateResponse.self, "NearbyEmptyStateResponse") }

    func testGL28_1_7_roundTripsNearbyEmptyStateSubmitPayload() throws { try assertRoundTrips(NearbyEmptyStateSubmitPayload.self, "NearbyEmptyStateSubmitPayload") }

    func testGL28_1_7_roundTripsNearbySelfStatus() throws { try assertRoundTrips(NearbySelfStatus.self, "NearbySelfStatus") }

    func testGL28_1_7_roundTripsNearbyUserRequest() throws { try assertRoundTrips(NearbyUserRequest.self, "NearbyUserRequest") }

    func testGL28_1_7_roundTripsNearbyUsersResponse() throws { try assertRoundTrips(NearbyUsersResponse.self, "NearbyUsersResponse") }

    func testGL28_1_7_roundTripsNegotiationProposal() throws { try assertRoundTrips(NegotiationProposal.self, "NegotiationProposal") }

    func testGL28_1_7_roundTripsPasscodePayload() throws { try assertRoundTrips(PasscodePayload.self, "PasscodePayload") }

    func testGL28_1_7_roundTripsPasswordUpdate() throws { try assertRoundTrips(PasswordUpdate.self, "PasswordUpdate") }

    func testGL28_1_7_roundTripsPrefetchUserForResponse() throws { try assertRoundTrips(PrefetchUserForResponse.self, "PrefetchUserForResponse") }

    func testGL28_1_7_roundTripsPrefetchUserForResponse_UserDetail() throws { try assertRoundTrips(PrefetchUserForResponse.UserDetail.self, "PrefetchUserForResponse.UserDetail") }

    func testGL28_1_7_roundTripsPrivateDetails() throws { try assertRoundTrips(PrivateDetails.self, "PrivateDetails") }

    func testGL28_1_7_roundTripsQueryBudget() throws { try assertRoundTrips(QueryBudget.self, "QueryBudget") }

    func testGL28_1_7_roundTripsQuestionResponsesResponse() throws { try assertRoundTrips(QuestionResponsesResponse.self, "QuestionResponsesResponse") }

    func testGL28_1_7_roundTripsQuestionResponsesResponse_QuestionResponse() throws { try assertRoundTrips(QuestionResponsesResponse.QuestionResponse.self, "QuestionResponsesResponse.QuestionResponse") }

    func testGL28_1_7_roundTripsQuestionSimilarity() throws { try assertRoundTrips(QuestionSimilarity.self, "QuestionSimilarity") }

    func testGL28_1_7_roundTripsQuestionsSpecifications() throws { try assertRoundTrips(QuestionsSpecifications.self, "QuestionsSpecifications") }

    func testGL28_1_7_roundTripsRateResponse() throws { try assertRoundTrips(RateResponse.self, "RateResponse") }

    func testGL28_1_7_roundTripsRating() throws { try assertRoundTrips(Rating.self, "Rating") }

    func testGL28_1_7_roundTripsReferralSelection() throws { try assertRoundTrips(ReferralSelection.self, "ReferralSelection") }

    func testGL28_1_7_roundTripsRefreshTokenRequestPayload() throws { try assertRoundTrips(RefreshTokenRequestPayload.self, "RefreshTokenRequestPayload") }

    func testGL28_1_7_roundTripsRegisterBasicInfoResponse() throws { try assertRoundTrips(RegisterBasicInfoResponse.self, "RegisterBasicInfoResponse") }

    func testGL28_1_7_roundTripsRegisterDeviceTokenResponse() throws { try assertRoundTrips(RegisterDeviceTokenResponse.self, "RegisterDeviceTokenResponse") }

    func testGL28_1_7_roundTripsRegisterPushKitDeviceTokenResponse() throws { try assertRoundTrips(RegisterPushKitDeviceTokenResponse.self, "RegisterPushKitDeviceTokenResponse") }

    func testGL28_1_7_roundTripsRegisterResponse() throws { try assertRoundTrips(RegisterResponse.self, "RegisterResponse") }

    func testGL28_1_7_roundTripsReportFlagsResponse() throws { try assertRoundTrips(ReportFlagsResponse.self, "ReportFlagsResponse") }

    func testGL28_1_7_roundTripsResetPasswordRequest() throws { try assertRoundTrips(ResetPasswordRequest.self, "ResetPasswordRequest") }

    func testGL28_1_7_roundTripsResetPasswordResponse() throws { try assertRoundTrips(ResetPasswordResponse.self, "ResetPasswordResponse") }

    func testGL28_1_7_roundTripsSemanticFamily() throws { try assertRoundTrips(SemanticFamily.self, "SemanticFamily") }

    func testGL28_1_7_roundTripsStandardPostResponse() throws { try assertRoundTrips(StandardPostResponse.self, "StandardPostResponse") }

    func testGL28_1_7_roundTripsTermsOfService() throws { try assertRoundTrips(TermsOfService.self, "TermsOfService") }

    func testGL28_1_7_roundTripsTokenResponse() throws { try assertRoundTrips(TokenResponse.self, "TokenResponse") }

    func testGL28_1_7_roundTripsTrackEventsResponse() throws { try assertRoundTrips(TrackEventsResponse.self, "TrackEventsResponse") }

    func testGL28_1_7_roundTripsTriggerTwoPersonGreetResponse() throws { try assertRoundTrips(TriggerTwoPersonGreetResponse.self, "TriggerTwoPersonGreetResponse") }

    func testGL28_1_7_roundTripsTwoPersonGreetResponse() throws { try assertRoundTrips(TwoPersonGreetResponse.self, "TwoPersonGreetResponse") }

    func testGL28_1_7_roundTripsUpdateEmailResponse() throws { try assertRoundTrips(UpdateEmailResponse.self, "UpdateEmailResponse") }

    func testGL28_1_7_roundTripsUpdateSettingsResponse() throws { try assertRoundTrips(UpdateSettingsResponse.self, "UpdateSettingsResponse") }

    func testGL28_1_7_roundTripsUploadPicResponse() throws { try assertRoundTrips(UploadPicResponse.self, "UploadPicResponse") }

    func testGL28_1_7_roundTripsUser_SignUp() throws { try assertRoundTrips(User.SignUp.self, "User.SignUp") }

    func testGL28_1_7_roundTripsUserImage() throws { try assertRoundTrips(UserImage.self, "UserImage") }

    func testGL28_1_7_roundTripsUserInformation() throws { try assertRoundTrips(UserInformation.self, "UserInformation") }

    func testGL28_1_7_roundTripsVenue() throws { try assertRoundTrips(Venue.self, "Venue") }

    func testGL28_1_7_roundTripsVenueEligibilityRequest() throws { try assertRoundTrips(VenueEligibilityRequest.self, "VenueEligibilityRequest") }

    func testGL28_1_7_roundTripsVenueImpactSummary() throws { try assertRoundTrips(VenueImpactSummary.self, "VenueImpactSummary") }

    func testGL28_1_7_roundTripsVenueInfo() throws { try assertRoundTrips(VenueInfo.self, "VenueInfo") }

    func testGL28_1_7_roundTripsVenueJoinReport() throws { try assertRoundTrips(VenueJoinReport.self, "VenueJoinReport") }

    func testGL28_1_7_roundTripsVenuePreference() throws { try assertRoundTrips(VenuePreference.self, "VenuePreference") }

    func testGL28_1_7_roundTripsVenueScanStateRequest() throws { try assertRoundTrips(VenueScanStateRequest.self, "VenueScanStateRequest") }

    func testGL28_1_7_roundTripsVenueScanStateResponse() throws { try assertRoundTrips(VenueScanStateResponse.self, "VenueScanStateResponse") }

    func testGL28_1_7_roundTripsVenueStaffSummary() throws { try assertRoundTrips(VenueStaffSummary.self, "VenueStaffSummary") }
}

/// Wraps the value so a type whose encoded form is a JSON fragment, which every raw value enum
/// is, still has a top level object to live in. Without it those types fail on the encoder
/// rather than on anything about the contract.
private struct GL28Envelope<T: Codable>: Codable {
    let value: T
}
