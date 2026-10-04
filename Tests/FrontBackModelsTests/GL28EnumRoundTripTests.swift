//
//  GL28EnumRoundTripTests.swift
//  FrontBackModelsTests
//
//  GOAL_LOOP28 item 1.7, the half that can be proved exhaustively rather than by sample.
//
//  A Codable enum with CaseIterable has no construction problem: every value it can ever hold
//  is enumerable, so the round trip covers ALL of them rather than one chosen by hand. For a
//  wire enum that is the guarantee that matters, because the failure mode is one case whose
//  raw value disagrees across the two sides and which nobody happened to pick as the sample.
//
//  Top level declarations only. A first version of this list was generated with a regular
//  expression that also matched enums nested inside other types, which produced names like
//  `Category` and `Method` that either do not resolve at file scope or resolve to something
//  else entirely, in one case to `OpaquePointer`. The compiler caught it, which is the point
//  of generating a list and then building it rather than trusting the generator.
//

import XCTest
@testable import AkinFrontBackModels

final class GL28EnumRoundTripTests: XCTestCase {

    private func roundTripAllCases<T>(_ type: T.Type, _ label: String) throws
    where T: Codable & Equatable & CaseIterable {
        XCTAssertFalse(T.allCases.isEmpty, "\(label) has no cases, so this asserts nothing")
        for value in T.allCases {
            let wire = try JSONEncoder.akinWire.encode(value)
            XCTAssertGreaterThan(wire.count, 0, "\(label) encoded \(value) to nothing")
            let back = try JSONDecoder.akinWire.decode(T.self, from: wire)
            XCTAssertEqual(back, value, "\(label) case \(value) did not survive the round trip")
        }
    }

    // One case per enum rather than one case walking all thirty one.
    //
    // The loop that stood here failed as a single name, `everyCaseIterableCodableEnumRoundTrips`,
    // which says that SOMETHING in the package stopped round tripping and makes the reader bisect
    // thirty one types to find out what. It also could not satisfy item 1.7's coverage gate, which
    // asks for a passing case naming each type, and was right to: a walk that stops at the first
    // failure proves nothing about the twenty types after it.

    func testGL28_1_7_everyCaseOfAccountDeletionErrorRoundTrips() throws {
        try roundTripAllCases(AccountDeletionError.self, "AccountDeletionError")
    }

    func testGL28_1_7_everyCaseOfAdDisclosureLabelRoundTrips() throws {
        try roundTripAllCases(AdDisclosureLabel.self, "AdDisclosureLabel")
    }

    func testGL28_1_7_everyCaseOfAuthorVisibilityRoundTrips() throws {
        try roundTripAllCases(AuthorVisibility.self, "AuthorVisibility")
    }

    func testGL28_1_7_everyCaseOfAuthoredContentKindRoundTrips() throws {
        try roundTripAllCases(AuthoredContentKind.self, "AuthoredContentKind")
    }

    func testGL28_1_7_everyCaseOfAutomaticGreetCooldownChoiceRoundTrips() throws {
        try roundTripAllCases(AutomaticGreetCooldownChoice.self, "AutomaticGreetCooldownChoice")
    }

    func testGL28_1_7_everyCaseOfAutomaticGreetOutcomeRoundTrips() throws {
        try roundTripAllCases(AutomaticGreetOutcome.self, "AutomaticGreetOutcome")
    }

    func testGL28_1_7_everyCaseOfBuildSourceRoundTrips() throws {
        try roundTripAllCases(BuildSource.self, "BuildSource")
    }

    func testGL28_1_7_everyCaseOfCallTypeRoundTrips() throws {
        try roundTripAllCases(CallType.self, "CallType")
    }

    func testGL28_1_7_everyCaseOfCapabilityRoundTrips() throws {
        try roundTripAllCases(Capability.self, "Capability")
    }

    func testGL28_1_7_everyCaseOfGreetActionActorKindRoundTrips() throws {
        try roundTripAllCases(GreetActionActorKind.self, "GreetActionActorKind")
    }

    func testGL28_1_7_everyCaseOfGreetActionChannelRoundTrips() throws {
        try roundTripAllCases(GreetActionChannel.self, "GreetActionChannel")
    }

    func testGL28_1_7_everyCaseOfGreetDemoPhaseRoundTrips() throws {
        try roundTripAllCases(GreetDemoPhase.self, "GreetDemoPhase")
    }

    func testGL28_1_7_everyCaseOfHideStatusRoundTrips() throws {
        try roundTripAllCases(HideStatus.self, "HideStatus")
    }

    func testGL28_1_7_everyCaseOfLanguageCodeEnumRoundTrips() throws {
        try roundTripAllCases(LanguageCodeEnum.self, "LanguageCodeEnum")
    }

    func testGL28_1_7_everyCaseOfMatchingAlgorithmChoiceRoundTrips() throws {
        try roundTripAllCases(MatchingAlgorithmChoice.self, "MatchingAlgorithmChoice")
    }

    func testGL28_1_7_everyCaseOfModerationTreatmentRoundTrips() throws {
        try roundTripAllCases(ModerationTreatment.self, "ModerationTreatment")
    }

    func testGL28_1_7_everyCaseOfNearbyAvailabilityRoundTrips() throws {
        try roundTripAllCases(NearbyAvailability.self, "NearbyAvailability")
    }

    func testGL28_1_7_everyCaseOfNotificationFrequencyRoundTrips() throws {
        try roundTripAllCases(NotificationFrequency.self, "NotificationFrequency")
    }

    func testGL28_1_7_everyCaseOfNotificationReasonRoundTrips() throws {
        try roundTripAllCases(NotificationReason.self, "NotificationReason")
    }

    func testGL28_1_7_everyCaseOfProfileSelectionSideRoundTrips() throws {
        try roundTripAllCases(ProfileSelectionSide.self, "ProfileSelectionSide")
    }

    func testGL28_1_7_everyCaseOfReportFlagRoundTrips() throws {
        try roundTripAllCases(ReportFlag.self, "ReportFlag")
    }

    func testGL28_1_7_everyCaseOfServerEnvironmentRoundTrips() throws {
        try roundTripAllCases(ServerEnvironment.self, "ServerEnvironment")
    }

    func testGL28_1_7_everyCaseOfSubscriptionTierRoundTrips() throws {
        try roundTripAllCases(SubscriptionTier.self, "SubscriptionTier")
    }

    func testGL28_1_7_everyCaseOfSupportedLanguageCodeRoundTrips() throws {
        try roundTripAllCases(SupportedLanguageCode.self, "SupportedLanguageCode")
    }

    func testGL28_1_7_everyCaseOfVenueAskOutcomeRoundTrips() throws {
        try roundTripAllCases(VenueAskOutcome.self, "VenueAskOutcome")
    }

    func testGL28_1_7_everyCaseOfVenueAudienceRoundTrips() throws {
        try roundTripAllCases(VenueAudience.self, "VenueAudience")
    }

    func testGL28_1_7_everyCaseOfVenueAwarenessStateRoundTrips() throws {
        try roundTripAllCases(VenueAwarenessState.self, "VenueAwarenessState")
    }

    func testGL28_1_7_everyCaseOfVenueMotivationArmRoundTrips() throws {
        try roundTripAllCases(VenueMotivationArm.self, "VenueMotivationArm")
    }

    func testGL28_1_7_everyCaseOfVenueOutcomeSourceRoundTrips() throws {
        try roundTripAllCases(VenueOutcomeSource.self, "VenueOutcomeSource")
    }

    func testGL28_1_7_everyCaseOfVenueScanRoleRoundTrips() throws {
        try roundTripAllCases(VenueScanRole.self, "VenueScanRole")
    }

    func testGL28_1_7_everyCaseOfVenueShiftBucketRoundTrips() throws {
        try roundTripAllCases(VenueShiftBucket.self, "VenueShiftBucket")
    }
}
