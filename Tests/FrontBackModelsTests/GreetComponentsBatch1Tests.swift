import XCTest
@testable import AkinFrontBackModels

private func encodeDecode<T: Codable>(_ value: T) throws -> T {
    let data = try JSONEncoder().encode(value)
    return try JSONDecoder().decode(T.self, from: data)
}

final class GreetComponentsBatch1Tests: XCTestCase {

    // MARK: - Requirement

    func testRequirementEquatable() {
        XCTAssertEqual(Requirement.birthday, Requirement.birthday)
        XCTAssertEqual(Requirement.profilePic, Requirement.profilePic)
        XCTAssertEqual(Requirement.callKitConsent, Requirement.callKitConsent)
        XCTAssertEqual(Requirement.location(.regular), Requirement.location(.regular))
        XCTAssertNotEqual(Requirement.location(.regular), Requirement.location(.requiresDeeplinkToSettings))
        XCTAssertEqual(Requirement.pushNotification(.regular), Requirement.pushNotification(.regular))
        XCTAssertNotEqual(Requirement.pushNotification(.regular), Requirement.pushNotification(.requiresDeeplinkToSettings))
        XCTAssertNotEqual(Requirement.birthday, Requirement.profilePic)
        XCTAssertNotEqual(Requirement.birthday, Requirement.location(.regular))
    }

    func testRequirementCodableRoundTrip() throws {
        XCTAssertEqual(try encodeDecode(Requirement.birthday), .birthday)
        XCTAssertEqual(try encodeDecode(Requirement.profilePic), .profilePic)
        XCTAssertEqual(try encodeDecode(Requirement.callKitConsent), .callKitConsent)
        XCTAssertEqual(try encodeDecode(Requirement.location(.shouldUpgradeToAlways)), .location(.shouldUpgradeToAlways))
        XCTAssertEqual(try encodeDecode(Requirement.pushNotification(.requiresDeeplinkToSettings)), .pushNotification(.requiresDeeplinkToSettings))
    }

    func testRequirementFromLocationAuthorizationStatus() {
        XCTAssertEqual(Requirement(from: LocationAuthorizationStatus.notDetermined), .location(.regular))
        XCTAssertEqual(Requirement(from: LocationAuthorizationStatus.restricted), .location(.requiresDeeplinkToSettings))
        XCTAssertEqual(Requirement(from: LocationAuthorizationStatus.denied), .location(.requiresDeeplinkToSettings))
        XCTAssertNil(Requirement(from: LocationAuthorizationStatus.authorizedAlways))
        XCTAssertEqual(Requirement(from: LocationAuthorizationStatus.authorizedWhenInUse), .location(.shouldUpgradeToAlways))
    }

    func testRequirementFromNotificationAuthorizationStatus() {
        XCTAssertEqual(Requirement(from: NotificationAuthorizationStatus.notDetermined), .pushNotification(.regular))
        XCTAssertEqual(Requirement(from: NotificationAuthorizationStatus.denied), .pushNotification(.requiresDeeplinkToSettings))
        XCTAssertNil(Requirement(from: NotificationAuthorizationStatus.authorized))
        XCTAssertNil(Requirement(from: NotificationAuthorizationStatus.ephemeral))
        XCTAssertEqual(Requirement(from: NotificationAuthorizationStatus.provisional), .pushNotification(.requiresDeeplinkToSettings))
    }

    func testRequirementFromProfilePicString() {
        let nilString: String? = nil
        XCTAssertEqual(Requirement(from: nilString), .profilePic)

        let presentString: String? = "https://example.com/pic.jpg"
        XCTAssertNil(Requirement(from: presentString))

        let emptyString: String? = ""
        XCTAssertNil(Requirement(from: emptyString))
    }

    // MARK: - Selections

    func testSelectionsDefaultInit() {
        let selections = Question.Response.Selections()
        XCTAssertEqual(selections.my, .empty)
        XCTAssertEqual(selections.their, .empty)
    }

    func testSelectionsCustomInit() {
        let selections = Question.Response.Selections(my: .YES, their: .NO)
        XCTAssertEqual(selections.my, .YES)
        XCTAssertEqual(selections.their, .NO)
    }

    func testSelectionsPartialInit() {
        let onlyMy = Question.Response.Selections(my: .NEUTRAL)
        XCTAssertEqual(onlyMy.my, .NEUTRAL)
        XCTAssertEqual(onlyMy.their, .empty)

        let onlyTheir = Question.Response.Selections(their: .YES)
        XCTAssertEqual(onlyTheir.my, .empty)
        XCTAssertEqual(onlyTheir.their, .YES)
    }

    func testSelectionsCodableRoundTrip() throws {
        let selections = Question.Response.Selections(my: .YES, their: .NEUTRAL)
        let decoded = try encodeDecode(selections)
        XCTAssertEqual(decoded.my, .YES)
        XCTAssertEqual(decoded.their, .NEUTRAL)
    }

    func testChoiceWeightMultiplier() {
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice.YES.weightMultiplier, 1)
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice.NO.weightMultiplier, -1)
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice.empty.weightMultiplier, 0)
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice.NEUTRAL.weightMultiplier, 0)
    }

    func testChoiceRawValues() {
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice.YES.rawValue, "YES")
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice.NO.rawValue, "NO")
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice.empty.rawValue, " ")
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice.NEUTRAL.rawValue, "NEUTRAL")
        XCTAssertEqual(Question.Response.Selections.MyTheir.Choice.allCases.count, 4)
    }

    func testMyTheirRawValues() {
        XCTAssertEqual(Question.Response.Selections.MyTheir.my.rawValue, "my")
        XCTAssertEqual(Question.Response.Selections.MyTheir.their.rawValue, "their")
        XCTAssertEqual(Question.Response.Selections.MyTheir.allCases.count, 2)
    }

    // MARK: - Method

    func testMethodRawValues() {
        XCTAssertEqual(Greet.Method.handShake.rawValue, "Hand shake")
        XCTAssertEqual(Greet.Method.hug.rawValue, "hug")
        XCTAssertEqual(Greet.Method.kiss.rawValue, "kiss")
        XCTAssertEqual(Greet.Method.plur.rawValue, "plur")
        XCTAssertEqual(Greet.Method.highFive.rawValue, "High Five")
        XCTAssertEqual(Greet.Method.wave.rawValue, "wave")
        XCTAssertEqual(Greet.Method.hook_up.rawValue, "Hook up")
        XCTAssertEqual(Greet.Method.wetWilly.rawValue, "Wet Willy")
    }

    func testMethodDisplayStr() {
        XCTAssertEqual(Greet.Method.hug.displayStr, "Hug 🤗")
        XCTAssertEqual(Greet.Method.kiss.displayStr, "Kiss 😘")
        XCTAssertEqual(Greet.Method.handShake.displayStr, "Hand Shake 🤝")
        XCTAssertEqual(Greet.Method.wave.displayStr, "Wave 👋")
        XCTAssertEqual(Greet.Method.hook_up.displayStr, "Hook up 👉👌")
        XCTAssertEqual(Greet.Method.plur.displayStr, "P.L.U.R. ✌️❤️✊🫡")
        XCTAssertEqual(Greet.Method.highFive.displayStr, "High Five 🙏")
        XCTAssertEqual(Greet.Method.wetWilly.displayStr, "Wet Willy 👉💦👂")
    }

    func testMethodCaseIterable() {
        XCTAssertEqual(Greet.Method.allCases.count, 8)
        XCTAssertTrue(Greet.Method.allCases.contains(.handShake))
        XCTAssertTrue(Greet.Method.allCases.contains(.wetWilly))
    }

    func testMethodCodableRoundTrip() throws {
        XCTAssertEqual(try encodeDecode(Greet.Method.hook_up), .hook_up)
        XCTAssertEqual(try encodeDecode(Greet.Method.wetWilly), .wetWilly)
    }

    // MARK: - TravelMethod

    func testTravelMethodRawValues() {
        XCTAssertEqual(TravelMethod.bike.rawValue, "bike")
        XCTAssertEqual(TravelMethod.car.rawValue, "car")
        XCTAssertEqual(TravelMethod.none.rawValue, "none")
        XCTAssertEqual(TravelMethod.walk.rawValue, "walk")
        XCTAssertEqual(TravelMethod.motorcycle.rawValue, "motorcycle")
        XCTAssertEqual(TravelMethod.transit.rawValue, "transit")
    }

    func testTravelMethodEmoji() {
        XCTAssertEqual(TravelMethod.bike.emoji, "🚲")
        XCTAssertEqual(TravelMethod.car.emoji, "🚗")
        XCTAssertEqual(TravelMethod.none.emoji, "👣")
        XCTAssertEqual(TravelMethod.walk.emoji, "👣")
        XCTAssertEqual(TravelMethod.motorcycle.emoji, "🏍️")
        XCTAssertEqual(TravelMethod.transit.emoji, "🚇")
    }

    func testTravelMethodCodableRoundTrip() throws {
        for method in [TravelMethod.bike, .car, .none, .walk, .motorcycle, .transit] {
            XCTAssertEqual(try encodeDecode(method), method)
        }
    }

    func testTravelMethodGooglePlacesBike() {
        guard case .bicycle = TravelMethod.bike.googlePlaces else {
            return XCTFail("expected .bicycle")
        }
    }

    func testTravelMethodGooglePlacesCar() {
        guard case .drive(let pref) = TravelMethod.car.googlePlaces else {
            return XCTFail("expected .drive")
        }
        XCTAssertEqual(pref, .trafficAware)
    }

    func testTravelMethodGooglePlacesNoneAndWalk() {
        guard case .walk = TravelMethod.none.googlePlaces else {
            return XCTFail("expected .walk for .none")
        }
        guard case .walk = TravelMethod.walk.googlePlaces else {
            return XCTFail("expected .walk for .walk")
        }
    }

    func testTravelMethodGooglePlacesMotorcycle() {
        guard case .twoWheeler(let pref) = TravelMethod.motorcycle.googlePlaces else {
            return XCTFail("expected .twoWheeler")
        }
        XCTAssertEqual(pref, .trafficAware)
    }

    func testTravelMethodGooglePlacesTransit() {
        guard case .transit = TravelMethod.transit.googlePlaces else {
            return XCTFail("expected .transit")
        }
    }

    func testSafeTravelModeApiValue() {
        XCTAssertEqual(SafeTravelMode.drive(routingPreference: .trafficAware).apiValue, "DRIVE")
        XCTAssertEqual(SafeTravelMode.twoWheeler(routingPreference: .trafficAware).apiValue, "TWO_WHEELER")
        XCTAssertEqual(SafeTravelMode.walk.apiValue, "WALK")
        XCTAssertEqual(SafeTravelMode.bicycle.apiValue, "BICYCLE")
        XCTAssertEqual(SafeTravelMode.transit.apiValue, "TRANSIT")
    }

    func testSafeTravelModeRoutingPreference() {
        XCTAssertEqual(SafeTravelMode.drive(routingPreference: .trafficAwareOptimal).routingPreference, .trafficAwareOptimal)
        XCTAssertNil(SafeTravelMode.drive(routingPreference: nil).routingPreference)
        XCTAssertEqual(SafeTravelMode.twoWheeler(routingPreference: .trafficUnaware).routingPreference, .trafficUnaware)
        XCTAssertNil(SafeTravelMode.twoWheeler(routingPreference: nil).routingPreference)
        XCTAssertNil(SafeTravelMode.walk.routingPreference)
        XCTAssertNil(SafeTravelMode.bicycle.routingPreference)
        XCTAssertNil(SafeTravelMode.transit.routingPreference)
    }

    func testRoutingPreferenceApiValue() {
        XCTAssertEqual(SafeTravelMode.RoutingPreference.trafficUnaware.apiValue, "TRAFFIC_UNAWARE")
        XCTAssertEqual(SafeTravelMode.RoutingPreference.trafficAware.apiValue, "TRAFFIC_AWARE")
        XCTAssertEqual(SafeTravelMode.RoutingPreference.trafficAwareOptimal.apiValue, "TRAFFIC_AWARE_OPTIMAL")
    }

    // MARK: - ViewSetting

    func testViewSettingEqualitySameCaseIgnoringPayload() {
        XCTAssertEqual(ViewSetting.start, .start)
        XCTAssertEqual(ViewSetting.thisUserAgreed, .thisUserAgreed)
        XCTAssertEqual(ViewSetting.inGreet, .inGreet)
        XCTAssertEqual(ViewSetting.rejected, .rejected)
        // Custom == ignores the associated Int payload entirely.
        XCTAssertEqual(ViewSetting.otherAskedIfCanMeetLater(10), .otherAskedIfCanMeetLater(999))
    }

    func testViewSettingInGreetConfirmedMetNeverEqual() {
        // inGreetConfirmedMet is not handled in the custom == switch, so it
        // always falls through to the `default: false` branch, even for
        // identical payloads. This documents that (surprising) behavior.
        XCTAssertNotEqual(ViewSetting.inGreetConfirmedMet(.nearby), .inGreetConfirmedMet(.nearby))
        XCTAssertNotEqual(ViewSetting.inGreetConfirmedMet(.theyConfirmed), .inGreetConfirmedMet(.theyConfirmed))
    }

    func testViewSettingCrossCaseInequality() {
        XCTAssertNotEqual(ViewSetting.start, .thisUserAgreed)
        XCTAssertNotEqual(ViewSetting.start, .inGreet)
        XCTAssertNotEqual(ViewSetting.rejected, .inGreet)
        XCTAssertNotEqual(ViewSetting.otherAskedIfCanMeetLater(10), .start)
    }

    func testViewSettingCellTypesStart() {
        XCTAssertEqual(ViewSetting.start.cellTypes, [
            .ProfilePicCell, .MeetDecisionCell, .OpenersCell, .DismissCell,
        ])
    }

    func testViewSettingCellTypesThisUserAgreed() {
        XCTAssertEqual(ViewSetting.thisUserAgreed.cellTypes, [
            .ProfilePicCell, .MeetDecisionCell, .OpenersCell, .DismissCell,
        ])
    }

    func testViewSettingCellTypesOtherAskedIfCanMeetLater() {
        XCTAssertEqual(ViewSetting.otherAskedIfCanMeetLater(30).cellTypes, [
            .ProfilePicCell, .AlternateDecisionCell, .OpenersCell, .DismissCell,
        ])
    }

    func testViewSettingCellTypesInGreet() {
        XCTAssertEqual(ViewSetting.inGreet.cellTypes, [
            .InstructionCell, .TravelProgressCell, .DismissCell, .GreetMapCell,
            .GreetAddressCell, .ProfilePicCell, .OtherGreeterSettingsCell,
            .OpenersCell, .BackToTopCell,
        ])
    }

    func testViewSettingCellTypesRejected() {
        XCTAssertEqual(ViewSetting.rejected.cellTypes, [])
    }

    func testViewSettingCellTypesInGreetConfirmedMet() {
        XCTAssertEqual(ViewSetting.inGreetConfirmedMet(.nearby).cellTypes, [
            .InstructionCell, .TravelProgressCell, .DismissCell, .GreetMapCell,
            .AlternateDecisionCell, .GreetAddressCell, .ProfilePicCell,
            .OtherGreeterSettingsCell, .OpenersCell, .BackToTopCell,
        ])
    }

    func testConifirmationReasonRawValues() {
        XCTAssertEqual(ViewSetting.ConifirmationReason.nearby.rawValue, "nearby")
        XCTAssertEqual(ViewSetting.ConifirmationReason.theyConfirmed.rawValue, "theyConfirmed")
    }

    func testConifirmationReasonCodableRoundTrip() throws {
        XCTAssertEqual(try encodeDecode(ViewSetting.ConifirmationReason.nearby), .nearby)
        XCTAssertEqual(try encodeDecode(ViewSetting.ConifirmationReason.theyConfirmed), .theyConfirmed)
    }

    func testViewSettingCodableRoundTrip() throws {
        XCTAssertEqual(try encodeDecode(ViewSetting.start), .start)

        let decodedProposal = try encodeDecode(ViewSetting.otherAskedIfCanMeetLater(45))
        guard case .otherAskedIfCanMeetLater(let minutes) = decodedProposal else {
            return XCTFail("expected .otherAskedIfCanMeetLater")
        }
        XCTAssertEqual(minutes, 45)

        let decoded = try encodeDecode(ViewSetting.inGreetConfirmedMet(.theyConfirmed))
        guard case .inGreetConfirmedMet(let reason) = decoded else {
            return XCTFail("expected .inGreetConfirmedMet")
        }
        XCTAssertEqual(reason, .theyConfirmed)
    }

    // MARK: - VoipSignal

    func testVoipSignalOfferEquatable() {
        XCTAssertEqual(VoipSignal.offer(sdp: "a"), VoipSignal.offer(sdp: "a"))
        XCTAssertNotEqual(VoipSignal.offer(sdp: "a"), VoipSignal.offer(sdp: "b"))
        XCTAssertNotEqual(VoipSignal.offer(sdp: "a"), VoipSignal.answer(sdp: "a"))
    }

    func testVoipSignalAnswerEquatable() {
        XCTAssertEqual(VoipSignal.answer(sdp: "x"), VoipSignal.answer(sdp: "x"))
        XCTAssertNotEqual(VoipSignal.answer(sdp: "x"), VoipSignal.answer(sdp: "y"))
    }

    func testVoipSignalIceCandidateEquatable() {
        let a = VoipSignal.iceCandidate(sdp: "s", sdpMLineIndex: 0, sdpMid: "audio")
        let b = VoipSignal.iceCandidate(sdp: "s", sdpMLineIndex: 0, sdpMid: "audio")
        let c = VoipSignal.iceCandidate(sdp: "s", sdpMLineIndex: 1, sdpMid: "audio")
        let d = VoipSignal.iceCandidate(sdp: "s", sdpMLineIndex: 0, sdpMid: nil)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
        XCTAssertNotEqual(a, d)
    }

    func testVoipSignalHashable() {
        let signals: Set<VoipSignal> = [
            .offer(sdp: "a"),
            .offer(sdp: "a"),
            .answer(sdp: "a"),
            .iceCandidate(sdp: "s", sdpMLineIndex: 0, sdpMid: nil),
        ]
        XCTAssertEqual(signals.count, 3)
    }

    func testVoipSignalCodableRoundTripOffer() throws {
        XCTAssertEqual(try encodeDecode(VoipSignal.offer(sdp: "offer-sdp")), .offer(sdp: "offer-sdp"))
    }

    func testVoipSignalCodableRoundTripAnswer() throws {
        XCTAssertEqual(try encodeDecode(VoipSignal.answer(sdp: "answer-sdp")), .answer(sdp: "answer-sdp"))
    }

    func testVoipSignalCodableRoundTripIceCandidateWithMid() throws {
        let signal = VoipSignal.iceCandidate(sdp: "ice-sdp", sdpMLineIndex: 2, sdpMid: "video")
        XCTAssertEqual(try encodeDecode(signal), signal)
    }

    func testVoipSignalCodableRoundTripIceCandidateWithoutMid() throws {
        let signal = VoipSignal.iceCandidate(sdp: "ice-sdp", sdpMLineIndex: 2, sdpMid: nil)
        let decoded = try encodeDecode(signal)
        XCTAssertEqual(decoded, signal)
        guard case .iceCandidate(_, _, let sdpMid) = decoded else {
            return XCTFail("expected .iceCandidate")
        }
        XCTAssertNil(sdpMid)
    }

    func testVoipSignalDecodeInvalidCaseTypeThrows() {
        let json = "{\"caseType\":\"bogus\",\"sdp\":\"x\"}".data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(VoipSignal.self, from: json))
    }

    func testVoipSignalDecodeMissingRequiredFieldThrows() {
        let json = "{\"caseType\":\"offer\"}".data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(VoipSignal.self, from: json))
    }

    func testVoipSignalPayloadEquatableAndCodable() throws {
        let greetID = UUID()
        let payload = VoipSignalPayload(greetID: greetID, callType: .ringToVoipEnroute, signal: .offer(sdp: "sdp"))
        let samePayload = VoipSignalPayload(greetID: greetID, callType: .ringToVoipEnroute, signal: .offer(sdp: "sdp"))
        XCTAssertEqual(payload, samePayload)

        let differentPayload = VoipSignalPayload(greetID: UUID(), callType: .ringToVoipEnroute, signal: .offer(sdp: "sdp"))
        XCTAssertNotEqual(payload, differentPayload)

        XCTAssertEqual(try encodeDecode(payload), payload)

        let payloadSet: Set<VoipSignalPayload> = [payload, samePayload, differentPayload]
        XCTAssertEqual(payloadSet.count, 2)
    }

    // MARK: - TypeAlternator

    func testTypeAlternatorBothNilReturnsNil() {
        let preferred: String? = nil
        let secondary: Int? = nil
        XCTAssertNil(TypeAlternator<String, Int>(preferred, secondary))
    }

    func testTypeAlternatorPreferredOnly() {
        let preferred: String? = "abc"
        let secondary: Int? = nil
        guard case .preferred(let value) = TypeAlternator(preferred, secondary) else {
            return XCTFail("expected .preferred")
        }
        XCTAssertEqual(value, "abc")
    }

    func testTypeAlternatorSecondaryOnly() {
        let preferred: String? = nil
        let secondary: Int? = 42
        guard case .secondary(let value) = TypeAlternator(preferred, secondary) else {
            return XCTFail("expected .secondary")
        }
        XCTAssertEqual(value, 42)
    }

    func testTypeAlternatorBothPresentPrefersPreferred() {
        let preferred: String? = "abc"
        let secondary: Int? = 42
        guard case .preferred(let value) = TypeAlternator(preferred, secondary) else {
            return XCTFail("expected .preferred to win when both are present")
        }
        XCTAssertEqual(value, "abc")
    }

    func testTypeAlternatorCodableRoundTripPreferred() throws {
        let alternator = TypeAlternator<String, Int>.preferred("hello")
        let decoded = try encodeDecode(alternator)
        guard case .preferred(let value) = decoded else {
            return XCTFail("expected .preferred")
        }
        XCTAssertEqual(value, "hello")
    }

    func testTypeAlternatorCodableRoundTripSecondary() throws {
        let alternator = TypeAlternator<String, Int>.secondary(7)
        let decoded = try encodeDecode(alternator)
        guard case .secondary(let value) = decoded else {
            return XCTFail("expected .secondary")
        }
        XCTAssertEqual(value, 7)
    }

    // MARK: - ExitReason

    func testExitReasonEqualitySameCaseSamePayload() {
        XCTAssertEqual(Greet.Update.ExitReason.exceededRange(.my), .exceededRange(.my))
        XCTAssertEqual(Greet.Update.ExitReason.rejected(.their), .rejected(.their))
        XCTAssertEqual(Greet.Update.ExitReason.thisConfirmedMet, .thisConfirmedMet)
    }

    func testExitReasonEqualityDifferentPayload() {
        XCTAssertNotEqual(Greet.Update.ExitReason.exceededRange(.my), .exceededRange(.their))
        XCTAssertNotEqual(Greet.Update.ExitReason.rejected(.my), .rejected(.their))
    }

    func testExitReasonEqualityCrossCase() {
        XCTAssertNotEqual(Greet.Update.ExitReason.exceededRange(.my), .rejected(.my))
        XCTAssertNotEqual(Greet.Update.ExitReason.exceededRange(.my), .thisConfirmedMet)
        XCTAssertNotEqual(Greet.Update.ExitReason.rejected(.my), .thisConfirmedMet)
    }

    func testExitReasonCodableRoundTrip() throws {
        XCTAssertEqual(try encodeDecode(Greet.Update.ExitReason.exceededRange(.my)), .exceededRange(.my))
        XCTAssertEqual(try encodeDecode(Greet.Update.ExitReason.rejected(.their)), .rejected(.their))
        XCTAssertEqual(try encodeDecode(Greet.Update.ExitReason.thisConfirmedMet), .thisConfirmedMet)
    }

    // MARK: - Greet.Settings (MidGreetSettings)

    func testGreetSettingsDefaultInitOmittingProposals() {
        let id = UUID()
        let settings = Greet.Settings(status: .viewed, id: id)
        XCTAssertEqual(settings.rejectedTimeProposals, [])
        XCTAssertEqual(settings.agreedTimeProposals, [])
        XCTAssertEqual(settings.status, .viewed)
        XCTAssertEqual(settings.id, id)
    }

    func testGreetSettingsFullInit() {
        let id = UUID()
        let settings = Greet.Settings(
            rejectedTimeProposals: [5],
            agreedTimeProposals: [10, 20],
            status: .enroute,
            id: id
        )
        XCTAssertEqual(settings.rejectedTimeProposals, [5])
        XCTAssertEqual(settings.agreedTimeProposals, [10, 20])
        XCTAssertEqual(settings.status, .enroute)
        XCTAssertEqual(settings.id, id)
    }

    func testUpdateSettingsWithNilOtherLeavesStatusUnchanged() {
        var settings = Greet.Settings(status: .viewed, id: UUID())
        settings.updateSettings(with: nil)
        XCTAssertEqual(settings.status, .viewed)
    }

    func testUpdateSettingsWithNoCommonProposalsLeavesStatusUnchanged() {
        var settings = Greet.Settings(agreedTimeProposals: [10], status: .viewed, id: UUID())
        let other = Greet.Settings(agreedTimeProposals: [20], status: .viewed, id: UUID())
        settings.updateSettings(with: other)
        XCTAssertEqual(settings.status, .viewed)
    }

    func testUpdateSettingsWithCommonProposalRejectedBySelfLeavesStatusUnchanged() {
        var settings = Greet.Settings(
            rejectedTimeProposals: [20],
            agreedTimeProposals: [10, 20],
            status: .viewed,
            id: UUID()
        )
        let other = Greet.Settings(agreedTimeProposals: [20, 30], status: .viewed, id: UUID())
        settings.updateSettings(with: other)
        XCTAssertEqual(settings.status, .viewed)
    }

    func testUpdateSettingsWithCommonProposalRejectedByOtherLeavesStatusUnchanged() {
        var settings = Greet.Settings(agreedTimeProposals: [10, 20], status: .viewed, id: UUID())
        let other = Greet.Settings(
            rejectedTimeProposals: [20],
            agreedTimeProposals: [20, 30],
            status: .viewed,
            id: UUID()
        )
        settings.updateSettings(with: other)
        XCTAssertEqual(settings.status, .viewed)
    }

    func testUpdateSettingsWithValidCommonProposalSetsEnroute() {
        var settings = Greet.Settings(agreedTimeProposals: [10, 20], status: .viewed, id: UUID())
        let other = Greet.Settings(agreedTimeProposals: [20, 30], status: .viewed, id: UUID())
        settings.updateSettings(with: other)
        XCTAssertEqual(settings.status, .enroute)
    }

    func testGreetSettingsEquatableAndHashable() {
        let id = UUID()
        let a = Greet.Settings(status: .viewed, id: id)
        let b = Greet.Settings(status: .viewed, id: id)
        let c = Greet.Settings(status: .viewed, id: UUID())
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
        XCTAssertEqual(Set([a, b, c]).count, 2)
    }

    func testGreetSettingsCodableRoundTrip() throws {
        let settings = Greet.Settings(
            rejectedTimeProposals: [1, 2],
            agreedTimeProposals: [3, 4],
            status: .exceededRange,
            id: UUID()
        )
        XCTAssertEqual(try encodeDecode(settings), settings)
    }

    // MARK: - CallType

    func testCallTypeRawValues() {
        XCTAssertEqual(CallType.ringToGreet.rawValue, "ringToGreet")
        XCTAssertEqual(CallType.ringToVoipAfterOtherUserNotViewed.rawValue, "ringToVoipAfterOtherUserNotViewed")
        XCTAssertEqual(CallType.ringToVoipEnroute.rawValue, "ringToVoipEnroute")
    }

    func testCallTypeCaseIterable() {
        XCTAssertEqual(CallType.allCases.count, 3)
        XCTAssertTrue(CallType.allCases.contains(.ringToGreet))
        XCTAssertTrue(CallType.allCases.contains(.ringToVoipAfterOtherUserNotViewed))
        XCTAssertTrue(CallType.allCases.contains(.ringToVoipEnroute))
    }

    func testCallTypeOpensLiveVoipConversation() {
        XCTAssertFalse(CallType.ringToGreet.opensLiveVoipConversation)
        XCTAssertTrue(CallType.ringToVoipAfterOtherUserNotViewed.opensLiveVoipConversation)
        XCTAssertTrue(CallType.ringToVoipEnroute.opensLiveVoipConversation)
    }

    func testCallTypeRedButtonClosesGreet() {
        XCTAssertTrue(CallType.ringToGreet.redButtonClosesGreet)
        XCTAssertTrue(CallType.ringToVoipAfterOtherUserNotViewed.redButtonClosesGreet)
        XCTAssertFalse(CallType.ringToVoipEnroute.redButtonClosesGreet)
    }

    func testCallTypeCodableRoundTrip() throws {
        for callType in CallType.allCases {
            XCTAssertEqual(try encodeDecode(callType), callType)
        }
    }

    func testCallTypeHashable() {
        XCTAssertEqual(Set(CallType.allCases).count, 3)
    }

    // MARK: - CallKitFeatureFlag

    private var originalCallKitEnabled: Bool = false
    private var originalRingToGreetEnabled: Bool = true
    private var originalRingToVoipAfterOtherUserNotViewedEnabled: Bool = false
    private var originalRingToVoipEnrouteEnabled: Bool = false

    override func setUp() {
        super.setUp()
        originalCallKitEnabled = CallKitFeatureFlag.isCallKitEnabled
        originalRingToGreetEnabled = CallKitFeatureFlag.isRingToGreetEnabled
        originalRingToVoipAfterOtherUserNotViewedEnabled = CallKitFeatureFlag.isRingToVoipAfterOtherUserNotViewedEnabled
        originalRingToVoipEnrouteEnabled = CallKitFeatureFlag.isRingToVoipEnrouteEnabled
    }

    override func tearDown() {
        CallKitFeatureFlag.isCallKitEnabled = originalCallKitEnabled
        CallKitFeatureFlag.isRingToGreetEnabled = originalRingToGreetEnabled
        CallKitFeatureFlag.isRingToVoipAfterOtherUserNotViewedEnabled = originalRingToVoipAfterOtherUserNotViewedEnabled
        CallKitFeatureFlag.isRingToVoipEnrouteEnabled = originalRingToVoipEnrouteEnabled
        super.tearDown()
    }

    func testCallKitFeatureFlagDefaults() {
        XCTAssertFalse(CallKitFeatureFlag.isCallKitEnabled)
        XCTAssertTrue(CallKitFeatureFlag.isRingToGreetEnabled)
        XCTAssertFalse(CallKitFeatureFlag.isRingToVoipAfterOtherUserNotViewedEnabled)
        XCTAssertFalse(CallKitFeatureFlag.isRingToVoipEnrouteEnabled)
    }

    func testIsAnyVoipCallEnabledRequiresMasterSwitch() {
        CallKitFeatureFlag.isCallKitEnabled = false
        CallKitFeatureFlag.isRingToVoipAfterOtherUserNotViewedEnabled = true
        CallKitFeatureFlag.isRingToVoipEnrouteEnabled = true
        XCTAssertFalse(CallKitFeatureFlag.isAnyVoipCallEnabled)
    }

    func testIsAnyVoipCallEnabledFalseWhenNoSubFlagOn() {
        CallKitFeatureFlag.isCallKitEnabled = true
        CallKitFeatureFlag.isRingToVoipAfterOtherUserNotViewedEnabled = false
        CallKitFeatureFlag.isRingToVoipEnrouteEnabled = false
        XCTAssertFalse(CallKitFeatureFlag.isAnyVoipCallEnabled)
    }

    func testIsAnyVoipCallEnabledTrueWithAfterNotViewedFlag() {
        CallKitFeatureFlag.isCallKitEnabled = true
        CallKitFeatureFlag.isRingToVoipAfterOtherUserNotViewedEnabled = true
        CallKitFeatureFlag.isRingToVoipEnrouteEnabled = false
        XCTAssertTrue(CallKitFeatureFlag.isAnyVoipCallEnabled)
    }

    func testIsAnyVoipCallEnabledTrueWithEnrouteFlag() {
        CallKitFeatureFlag.isCallKitEnabled = true
        CallKitFeatureFlag.isRingToVoipAfterOtherUserNotViewedEnabled = false
        CallKitFeatureFlag.isRingToVoipEnrouteEnabled = true
        XCTAssertTrue(CallKitFeatureFlag.isAnyVoipCallEnabled)
    }

    func testIsEnabledForCallTypeRequiresMasterSwitch() {
        CallKitFeatureFlag.isCallKitEnabled = false
        CallKitFeatureFlag.isRingToGreetEnabled = true
        XCTAssertFalse(CallKitFeatureFlag.isEnabled(for: .ringToGreet))
    }

    func testIsEnabledForRingToGreet() {
        CallKitFeatureFlag.isCallKitEnabled = true
        CallKitFeatureFlag.isRingToGreetEnabled = true
        XCTAssertTrue(CallKitFeatureFlag.isEnabled(for: .ringToGreet))
        CallKitFeatureFlag.isRingToGreetEnabled = false
        XCTAssertFalse(CallKitFeatureFlag.isEnabled(for: .ringToGreet))
    }

    func testIsEnabledForRingToVoipAfterOtherUserNotViewed() {
        CallKitFeatureFlag.isCallKitEnabled = true
        CallKitFeatureFlag.isRingToVoipAfterOtherUserNotViewedEnabled = true
        XCTAssertTrue(CallKitFeatureFlag.isEnabled(for: .ringToVoipAfterOtherUserNotViewed))
        CallKitFeatureFlag.isRingToVoipAfterOtherUserNotViewedEnabled = false
        XCTAssertFalse(CallKitFeatureFlag.isEnabled(for: .ringToVoipAfterOtherUserNotViewed))
    }

    func testIsEnabledForRingToVoipEnroute() {
        CallKitFeatureFlag.isCallKitEnabled = true
        CallKitFeatureFlag.isRingToVoipEnrouteEnabled = true
        XCTAssertTrue(CallKitFeatureFlag.isEnabled(for: .ringToVoipEnroute))
        CallKitFeatureFlag.isRingToVoipEnrouteEnabled = false
        XCTAssertFalse(CallKitFeatureFlag.isEnabled(for: .ringToVoipEnroute))
    }
}
