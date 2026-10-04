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

    func testGL28_1_7_everyCaseIterableCodableEnumRoundTripsEveryCase() throws {
        try roundTripAllCases(AccountDeletionError.self, "AccountDeletionError")
        try roundTripAllCases(AdDisclosureLabel.self, "AdDisclosureLabel")
        try roundTripAllCases(AuthorVisibility.self, "AuthorVisibility")
        try roundTripAllCases(AuthoredContentKind.self, "AuthoredContentKind")
        try roundTripAllCases(AutomaticGreetCooldownChoice.self, "AutomaticGreetCooldownChoice")
        try roundTripAllCases(AutomaticGreetOutcome.self, "AutomaticGreetOutcome")
        try roundTripAllCases(BuildSource.self, "BuildSource")
        try roundTripAllCases(CallType.self, "CallType")
        try roundTripAllCases(Capability.self, "Capability")
        try roundTripAllCases(GreetActionActorKind.self, "GreetActionActorKind")
        try roundTripAllCases(GreetActionChannel.self, "GreetActionChannel")
        try roundTripAllCases(GreetDemoPhase.self, "GreetDemoPhase")
        try roundTripAllCases(HideStatus.self, "HideStatus")
        try roundTripAllCases(LanguageCodeEnum.self, "LanguageCodeEnum")
        try roundTripAllCases(MatchingAlgorithmChoice.self, "MatchingAlgorithmChoice")
        try roundTripAllCases(ModerationTreatment.self, "ModerationTreatment")
        try roundTripAllCases(NearbyAvailability.self, "NearbyAvailability")
        try roundTripAllCases(NotificationFrequency.self, "NotificationFrequency")
        try roundTripAllCases(NotificationReason.self, "NotificationReason")
        try roundTripAllCases(ProfileSelectionSide.self, "ProfileSelectionSide")
        try roundTripAllCases(ReportFlag.self, "ReportFlag")
        try roundTripAllCases(ServerEnvironment.self, "ServerEnvironment")
        try roundTripAllCases(SubscriptionTier.self, "SubscriptionTier")
        try roundTripAllCases(SupportedLanguageCode.self, "SupportedLanguageCode")
        try roundTripAllCases(VenueAskOutcome.self, "VenueAskOutcome")
        try roundTripAllCases(VenueAudience.self, "VenueAudience")
        try roundTripAllCases(VenueAwarenessState.self, "VenueAwarenessState")
        try roundTripAllCases(VenueMotivationArm.self, "VenueMotivationArm")
        try roundTripAllCases(VenueOutcomeSource.self, "VenueOutcomeSource")
        try roundTripAllCases(VenueScanRole.self, "VenueScanRole")
        try roundTripAllCases(VenueShiftBucket.self, "VenueShiftBucket")
    }
}
