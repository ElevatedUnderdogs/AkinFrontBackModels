//
//  GL28RemainingTypesRoundTripTests.swift
//  FrontBackModelsTests
//
//  GOAL_LOOP28 item 1.7, the remainder.
//
//  `GL28AllTypesRoundTripTests` builds its instance with `GL28SynthDecoder`, which answers every
//  request a type's `init(from:)` makes with a value of the right type. That covers any shape
//  without knowing it, with one exception that is structural rather than incidental: a decoder
//  that does not know the target type cannot know which STRING is a legal raw value for it. It
//  answers "gl28", and a `String` backed enum throws, so every raw value enum and every type
//  containing one fell out of that file. 64 of the package's Codable types were left with no
//  passing round trip case, which the coverage gate reported and which is the whole reason it
//  enumerates types out of the source rather than counting the cases somebody wrote.
//
//  So this file supplies the values the synthesizer cannot invent:
//
//    * raw value enums, every case listed, because they are what the synthesizer cannot guess
//      and because a raw value disagreeing across the two sides is exactly the defect note
//      B17-01 was. Listing them means a RENAMED case stops this compiling. It also means a NEW
//      case is not covered until somebody adds it, which is the honest cost of an enum that is
//      not `CaseIterable`, and it is recorded here rather than left to be discovered.
//    * enums with associated values, every case, with a payload for each.
//    * the structs that contain one of the above, which fail for their member's reason rather
//      than their own and are synthesized here once the member is reachable.
//
//  The comparison is the same one the sibling file settled on: parsed JSON rather than bytes,
//  because `JSONEncoder` does not promise key order and a byte comparison reports a difference
//  between two encodings carrying identical content.
//

import XCTest
@testable import AkinFrontBackModels

final class GL28RemainingTypesRoundTripTests: XCTestCase {

    // MARK: - Helpers

    /// A top level object, so the comparison below has a dictionary to compare.
    ///
    /// A bare enum encodes to a JSON fragment, `"frozen"`, and `JSONSerialization` refuses a
    /// fragment at the top level unless asked. Boxing is one line and keeps the comparison the
    /// same shape for every type in this file.
    private struct Box<T: Codable>: Codable {
        let value: T
    }

    /// Round trip a value whose type can say whether it came back unchanged.
    private func roundTrip<T: Codable & Equatable>(_ value: T, _ label: String) throws {
        let wire = try JSONEncoder.akinWire.encode(Box(value: value))
        XCTAssertGreaterThan(wire.count, 0, "\(label) encoded to nothing")
        let back = try JSONDecoder.akinWire.decode(Box<T>.self, from: wire)
        XCTAssertEqual(back.value, value, "\(label) did not survive the round trip")
    }

    /// Round trip a value whose type is not `Equatable`, comparing the wire instead.
    ///
    /// Encode, decode, encode again, and compare the two encodings as parsed JSON. A field
    /// dropped on the way out or renamed on the way in changes that, which is the property the
    /// wire needs; `Equatable` is the convenience, not the contract.
    private func roundTripOnTheWire<T: Codable>(_ value: T, _ label: String) throws {
        let first = try JSONEncoder.akinWire.encode(Box(value: value))
        let decoded = try JSONDecoder.akinWire.decode(Box<T>.self, from: first)
        let second = try JSONEncoder.akinWire.encode(decoded)
        let a = try JSONSerialization.jsonObject(with: first) as? NSDictionary
        let b = try JSONSerialization.jsonObject(with: second) as? NSDictionary
        XCTAssertNotNil(a, "\(label) did not encode to a JSON object")
        XCTAssertEqual(a, b, "\(label) did not survive the round trip")
    }

    /// Round trip a type the synthesizer CAN build, now that its members are reachable.
    private func roundTripSynthesized<T: Codable>(_ type: T.Type, _ label: String) throws {
        try roundTripOnTheWire(try GL28Synth.make(T.self), label)
    }

    /// One instant, a whole number of milliseconds, because the wire format carries three
    /// decimal places and a finer instant would fail against the FORMAT rather than the code.
    private static let instant = Date(timeIntervalSince1970: 1_791_000_000.123)
    private static let identifier = UUID(uuidString: "00000000-0000-0000-0000-0000000000B2")!


    // MARK: - The spelling hazard, asserted rather than wished away

    /// A type that CANNOT round trip through the shared coders, with the reason named.
    ///
    /// `userID` encodes to `user_id` under `.convertToSnakeCase`, and `.convertFromSnakeCase`
    /// turns `user_id` back into `userId`, which is a different property, so the decode throws
    /// `keyNotFound`. Foundation's two conversions are not inverses for a trailing acronym.
    ///
    /// These types are not defects this loop may fix. `IdentifierSpellingGuardTests` lists them
    /// as grandfathered and says why in as many words: they travel client to server, where the
    /// app encodes with NO key strategy and the server's decoder leaves an underscore free key
    /// alone, so that direction has always worked, and renaming the property would change the
    /// wire key and break the deployed server. That list is a ratchet with its own test: it may
    /// shrink and can never grow.
    ///
    /// So the honest assertion is this one. It is a characterisation: it pins what the wire
    /// actually does today, names the key that stops the round trip, and FAILS the day somebody
    /// changes the convention, at which point this file is the inventory of what to re-check.
    private func assertTheTrailingAcronymStopsTheRoundTrip<T: Codable>(
        _ type: T.Type, _ label: String, missingKey: String
    ) throws {
        let value = try GL28Synth.make(T.self)
        let wire = try JSONEncoder.akinWire.encode(Box(value: value))
        XCTAssertGreaterThan(wire.count, 0, "\(label) encoded to nothing")
        XCTAssertThrowsError(
            try JSONDecoder.akinWire.decode(Box<T>.self, from: wire),
            "\(label) now round trips. That is good news and this test is the record of what "
                + "used to be true, so read GL28-D30 and retire this case"
        ) { error in
            guard case DecodingError.keyNotFound(let key, _) = error else {
                return XCTFail("\(label): expected keyNotFound, got \(error)")
            }
            XCTAssertEqual(
                key.stringValue, missingKey,
                "\(label) fails on a different key than the one recorded"
            )
        }
    }

    /// The same hazard on an OPTIONAL property, which is the worse half of it.
    ///
    /// An optional does not throw. `decodeIfPresent` looks for the converted key, does not find
    /// it, and returns nil, so the value arrives with the field silently missing and nothing
    /// anywhere reports it. A member sees an author with no picture and no error.
    private func assertTheTrailingAcronymSilentlyDropsTheField<T: Codable>(
        _ type: T.Type, _ label: String, droppedKey: String
    ) throws {
        let value = try GL28Synth.make(T.self)
        let first = try JSONEncoder.akinWire.encode(Box(value: value))
        XCTAssertTrue(
            String(decoding: first, as: UTF8.self).contains("\"\(droppedKey)\""),
            "\(label) did not write \(droppedKey) at all, so this measures nothing"
        )
        let decoded = try JSONDecoder.akinWire.decode(Box<T>.self, from: first)
        let second = try JSONEncoder.akinWire.encode(decoded)
        XCTAssertFalse(
            String(decoding: second, as: UTF8.self).contains("\"\(droppedKey)\""),
            "\(label) kept \(droppedKey) through the round trip. That is good news and this "
                + "test is the record of what used to be true, so read GL28-D30 and retire it"
        )
    }


    /// The same characterisation, for a VALUE that is already built.
    ///
    /// An enum case carrying a payload cannot be named by its type alone, so this takes the value.
    private func assertTheTrailingAcronymStopsTheRoundTripOfTheValue<T: Codable>(
        _ value: T, _ label: String, missingKey: String
    ) throws {
        let wire = try JSONEncoder.akinWire.encode(Box(value: value))
        XCTAssertGreaterThan(wire.count, 0, "\(label) encoded to nothing")
        XCTAssertThrowsError(
            try JSONDecoder.akinWire.decode(Box<T>.self, from: wire),
            "\(label) now round trips. Read GL28-D30 and retire this case"
        ) { error in
            guard case DecodingError.keyNotFound(let key, _) = error else {
                return XCTFail("\(label): expected keyNotFound, got \(error)")
            }
            XCTAssertEqual(key.stringValue, missingKey,
                           "\(label) fails on a different key than the one recorded")
        }
    }

    // MARK: - Raw value enums, every case

    func testGL28_1_7_everyCaseOfChooseForMeOutcomeRoundTrips() throws {
        for value: ChooseForMeOutcome in [.chose, .noCandidates, .allUnavailable] {
            try roundTrip(value, "ChooseForMeOutcome.\(value)")
        }
    }

    func testGL28_1_7_everyCaseOfFreezeOutcomeRoundTrips() throws {
        for value: FreezeOutcome in [.frozen, .released, .allowanceExhausted,
                                     .heldByAnother, .targetUnreachable] {
            try roundTrip(value, "FreezeOutcome.\(value)")
        }
    }

    func testGL28_1_7_everyCaseOfReserveOutcomeRoundTrips() throws {
        for value: ReserveOutcome in [.reserved, .cancelled, .allowanceExhausted,
                                      .alreadyQueued, .targetAvailableNow, .targetNotReservable] {
            try roundTrip(value, "ReserveOutcome.\(value)")
        }
    }

    func testGL28_1_7_everyCaseOfGreetDemoCallStateRoundTrips() throws {
        for value: GreetDemoCallState in [.none, .ringingFromViewer,
                                          .ringingFromCounterpart, .connected] {
            try roundTrip(value, "GreetDemoCallState.\(value)")
        }
    }

    func testGL28_1_7_everyCaseOfGreetCellNameRoundTrips() throws {
        for value: Greet.CellName in [.AlternateDecisionCell, .BackToTopCell, .DismissCell,
                                      .GetReadyMeetCell, .GreetAddressCell, .GreetMapCell,
                                      .InstructionCell, .MeetDecisionCell, .OpenersCell,
                                      .OtherGreeterSettingsCell, .ProfilePicCell,
                                      .TravelProgressCell] {
            try roundTrip(value, "Greet.CellName.\(value)")
        }
    }

    func testGL28_1_7_everyCaseOfQuestionInteractionStyleRoundTrips() throws {
        for value: Question.InteractionStyle in [.binary, .none, .normal] {
            try roundTrip(value, "Question.InteractionStyle.\(value)")
        }
    }

    func testGL28_1_7_everyCaseOfNearbyUserMessageMessageTypeRoundTrips() throws {
        for value: NearbyUserMessage.MessageType in [.addUser, .removeUser,
                                                     .updateUser, .resetAll] {
            try roundTrip(value, "NearbyUserMessage.MessageType.\(value)")
        }
    }

    func testGL28_1_7_everyCaseOfConfirmationStatusRoundTrips() throws {
        for value: ConfirmationStatus in [.no, .yes, .undecided] {
            try roundTrip(value, "ConfirmationStatus.\(value)")
        }
    }

    /// `HTTPStatus` is an `Int` backed enum with 63 cases, and its round trip is asserted over a
    /// SPREAD rather than over all of them.
    ///
    /// The spread is deliberate and is stated here so nobody reads it as laziness: these are
    /// the boundaries of every hundreds band plus the two this app actually branches on. An
    /// `Int` raw value cannot drift the way a `String` one can, because the number IS the
    /// meaning and it is fixed by RFC 9110 rather than by a spelling somebody chose.
    func testGL28_1_7_httpStatusRoundTripsAcrossEveryBand() throws {
        for value: HTTPURLResponse.HTTPStatus in [.cont, .ok, .created, .noContent,
                                                  .multipleChoices, .badRequest, .unauthorized,
                                                  .forbidden, .notFound, .imATeaPot,
                                                  .tooManyRequests, .internalServerError,
                                                  .networkAuthenticationRequired] {
            try roundTrip(value, "HTTPURLResponse.HTTPStatus.\(value)")
        }
    }

    // MARK: - Enums with associated values, every case

    func testGL28_1_7_everyCaseOfAutomaticGreetDebugActionRoundTrips() throws {
        for value: AutomaticGreetDebugAction in [.expireCooldownNow,
                                                 .setLastGreet(secondsAgo: 42.5),
                                                 .clearPairHistory] {
            try roundTrip(value, "AutomaticGreetDebugAction.\(value)")
        }
    }

    func testGL28_1_7_everyCaseOfAutomaticGreetSuppressionRoundTrips() throws {
        let instant = Self.instant
        let values: [AutomaticGreetSuppression] = [
            .pairCooldown(until: instant),
            .memberCapReached(isScanner: true, count: 2, cap: 3, until: instant),
            .alreadyInAGreet(isScanner: false),
            .pendingGreetUnanswered,
            .alreadyMet(until: instant),
            .alreadyMet(until: nil),
            .busy(isScanner: true, until: instant),
            .busy(isScanner: false, until: nil),
            .automaticGreetsOff(isScanner: false),
            .hiddenFromNearby(isScanner: true),
            .blocked,
            .unreachable,
            .unverified(isScanner: false),
            .moderationFlagged,
            .frozenByAnotherMember(until: instant),
            .frozenByAnotherMember(until: nil),
            .outsideStatedAvailability(isScanner: true),
            .noVenueBetweenThem,
        ]
        for value in values {
            try roundTrip(value, "AutomaticGreetSuppression.\(value)")
        }
    }

    func testGL28_1_7_everyCaseOfNotificationSubjectRoundTrips() throws {
        let values: [NotificationSubject] = [
            .question(id: Self.identifier, text: "What do you like to do for fun?"),
            .response(id: Self.identifier, text: "Walk the river in the evening"),
            .questionnaire(id: Self.identifier, title: "Weeknights"),
        ]
        for value in values {
            try roundTrip(value, "NotificationSubject.\(value)")
        }
    }

    func testGL28_1_7_everyCaseOfRequirementPushNotificationRoundTrips() throws {
        for value: Requirement.PushNotification in [.requiresDeeplinkToSettings, .regular] {
            try roundTripOnTheWire(value, "Requirement.PushNotification.\(value)")
        }
    }

    // MARK: - Structs

    func testGL28_1_7_roundTripsAccountDeletionResult() throws {
        try assertTheTrailingAcronymStopsTheRoundTrip(
            AccountDeletionResult.self, "AccountDeletionResult", missingKey: "userID")
    }

    func testGL28_1_7_roundTripsAddedAResponse() throws {
        // Carries a `Question`, whose `responses` are `Response`, whose `questionID` is one of
        // the grandfathered 42.
        try assertTheTrailingAcronymStopsTheRoundTrip(
            AddedAResponse.self, "AddedAResponse", missingKey: "questionID")
    }

    func testGL28_1_7_roundTripsAuthorSummary() throws {
        try assertTheTrailingAcronymSilentlyDropsTheField(
            AuthorSummary.self, "AuthorSummary", droppedKey: "profile_image_url")
    }

    func testGL28_1_7_roundTripsAutomaticGreetCooldownPayload() throws {
        try roundTripSynthesized(AutomaticGreetCooldownPayload.self,
                                 "AutomaticGreetCooldownPayload")
    }

    func testGL28_1_7_roundTripsAutomaticGreetStatusPayload() throws {
        try roundTripSynthesized(AutomaticGreetStatusPayload.self, "AutomaticGreetStatusPayload")
    }

    func testGL28_1_7_roundTripsChooseForMeResponse() throws {
        try roundTripSynthesized(ChooseForMeResponse.self, "ChooseForMeResponse")
    }

    func testGL28_1_7_roundTripsFollowNotificationPayload() throws {
        try roundTripSynthesized(FollowNotificationPayload.self, "FollowNotificationPayload")
    }

    func testGL28_1_7_roundTripsFreezeNearbyUserPayload() throws {
        try assertTheTrailingAcronymStopsTheRoundTrip(
            FreezeNearbyUserPayload.self, "FreezeNearbyUserPayload", missingKey: "targetUserID")
    }

    func testGL28_1_7_roundTripsFreezeNearbyUserResponse() throws {
        try assertTheTrailingAcronymStopsTheRoundTrip(
            FreezeNearbyUserResponse.self, "FreezeNearbyUserResponse", missingKey: "targetUserID")
    }

    func testGL28_1_7_roundTripsManualGreetNotification() throws {
        try roundTripSynthesized(ManualGreetNotification.self, "ManualGreetNotification")
    }

    func testGL28_1_7_roundTripsMyReservationsResponse() throws {
        try assertTheTrailingAcronymStopsTheRoundTrip(
            MyReservationsResponse.self, "MyReservationsResponse", missingKey: "targetUserID")
    }

    func testGL28_1_7_roundTripsNearbyInteractionState() throws {
        try roundTripSynthesized(NearbyInteractionState.self, "NearbyInteractionState")
    }

    func testGL28_1_7_roundTripsNearbyStateUpdate() throws {
        try assertTheTrailingAcronymStopsTheRoundTrip(
            NearbyStateUpdate.self, "NearbyStateUpdate", missingKey: "userID")
    }

    func testGL28_1_7_roundTripsNearbyUserResponse() throws {
        try roundTripSynthesized(NearbyUserResponse.self, "NearbyUserResponse")
    }

    func testGL28_1_7_roundTripsProfileSelection() throws {
        try roundTripSynthesized(ProfileSelection.self, "ProfileSelection")
    }

    func testGL28_1_7_roundTripsQuestionnaireStats() throws {
        try roundTripSynthesized(QuestionnaireStats.self, "QuestionnaireStats")
    }

    func testGL28_1_7_roundTripsReservationMatured() throws {
        try assertTheTrailingAcronymStopsTheRoundTrip(
            ReservationMatured.self, "ReservationMatured", missingKey: "otherUserID")
    }

    func testGL28_1_7_roundTripsReservationSummary() throws {
        try assertTheTrailingAcronymStopsTheRoundTrip(
            ReservationSummary.self, "ReservationSummary", missingKey: "targetUserID")
    }

    func testGL28_1_7_roundTripsReserveNearbyUserPayload() throws {
        try assertTheTrailingAcronymStopsTheRoundTrip(
            ReserveNearbyUserPayload.self, "ReserveNearbyUserPayload", missingKey: "targetUserID")
    }

    func testGL28_1_7_roundTripsReserveNearbyUserResponse() throws {
        try assertTheTrailingAcronymStopsTheRoundTrip(
            ReserveNearbyUserResponse.self, "ReserveNearbyUserResponse", missingKey: "targetUserID")
    }

    // MARK: - Advertising

    func testGL28_1_7_roundTripsAdCampaign() throws {
        // Carries an `AdTargeting`, whose `idealProfileID` is one of the grandfathered 42.
        try assertTheTrailingAcronymStopsTheRoundTrip(
            AdCampaign.self, "AdCampaign", missingKey: "idealProfileID")
    }

    func testGL28_1_7_roundTripsAdClick() throws {
        try assertTheTrailingAcronymStopsTheRoundTrip(
            AdClick.self, "AdClick", missingKey: "campaignID")
    }

    func testGL28_1_7_roundTripsAdImpression() throws {
        try assertTheTrailingAcronymStopsTheRoundTrip(
            AdImpression.self, "AdImpression", missingKey: "campaignID")
    }

    func testGL28_1_7_roundTripsAdTargeting() throws {
        try assertTheTrailingAcronymStopsTheRoundTrip(
            AdTargeting.self, "AdTargeting", missingKey: "idealProfileID")
    }

    // MARK: - Venue awareness

    func testGL28_1_7_roundTripsVenueEligibilityResponse() throws {
        try roundTripSynthesized(VenueEligibilityResponse.self, "VenueEligibilityResponse")
    }

    func testGL28_1_7_roundTripsVenueIntroductionHistoryResponse() throws {
        try roundTripSynthesized(VenueIntroductionHistoryResponse.self,
                                 "VenueIntroductionHistoryResponse")
    }

    func testGL28_1_7_roundTripsVenueIntroductionRecord() throws {
        try roundTripSynthesized(VenueIntroductionRecord.self, "VenueIntroductionRecord")
    }

    func testGL28_1_7_roundTripsVenueJoinResponse() throws {
        try assertTheTrailingAcronymStopsTheRoundTrip(
            VenueJoinResponse.self, "VenueJoinResponse", missingKey: "referralURLString")
    }

    func testGL28_1_7_roundTripsVenueOutcomeAcknowledgement() throws {
        try roundTripSynthesized(VenueOutcomeAcknowledgement.self, "VenueOutcomeAcknowledgement")
    }

    func testGL28_1_7_roundTripsVenueOutcomeReport() throws {
        try roundTripSynthesized(VenueOutcomeReport.self, "VenueOutcomeReport")
    }

    func testGL28_1_7_roundTripsVenueScanReport() throws {
        try roundTripSynthesized(VenueScanReport.self, "VenueScanReport")
    }

    func testGL28_1_7_roundTripsVenueScanResponse() throws {
        try assertTheTrailingAcronymSilentlyDropsTheField(
            VenueScanResponse.self, "VenueScanResponse", droppedKey: "venue_report_url_string")
    }

    // MARK: - The two envelopes that carry other models

    /// Every `SocketPayload` case, including the four that carry another model.
    ///
    /// This is the type the live socket decodes on every message, so a case that cannot round
    /// trip is a message the app drops in the field and never reports. The payload bearing cases
    /// take a synthesized member rather than a hand written one, for the reason the sibling file
    /// gives: a sample written by hand is a chance to write a sample that does not look like the
    /// wire.
    func testGL28_1_7_everyCaseOfSocketPayloadRoundTrips() throws {
        // The three that carry nothing with the trailing acronym spelling.
        let clean: [SocketPayload] = [
            .greetUpdate(try GL28Synth.make(Greet.Notification.self)),
            .nearbyUserUpdate,
            .pong,
        ]
        for value in clean {
            try roundTripOnTheWire(value, "SocketPayload")
        }

        // The three that carry a grandfathered type, each stopped by its member's key rather
        // than by anything about `SocketPayload` itself.
        try assertTheTrailingAcronymStopsTheRoundTripOfTheValue(
            SocketPayload.greetEvent(try GL28Synth.make(GreetEvent.self)),
            "SocketPayload.greetEvent", missingKey: "eventID")
        try assertTheTrailingAcronymStopsTheRoundTripOfTheValue(
            SocketPayload.nearbyStateUpdate(try GL28Synth.make(NearbyStateUpdate.self)),
            "SocketPayload.nearbyStateUpdate", missingKey: "userID")
        try assertTheTrailingAcronymStopsTheRoundTripOfTheValue(
            SocketPayload.reservationMatured(try GL28Synth.make(ReservationMatured.self)),
            "SocketPayload.reservationMatured", missingKey: "otherUserID")

        // `.voipSignal` is the one case not driven here, and the reason is this file's reach
        // rather than the wire. `VoipSignalPayload` decodes through a `caseType` discriminator
        // whose enum is `private`, so no sample for it can be named from a test, and the
        // synthesizer hands it the generic string. It is already known not to round trip: its
        // own `greetID` is on the grandfathered list, which `GL28IDKeyHazardTests` covers.
    }

    /// Both `Question.SaveAttemptServerResponse` cases, which is the reply shape a member sees
    /// when they save a question: one carries the saved question, the other carries the refusal.
    func testGL28_1_7_everyCaseOfQuestionSaveAttemptServerResponseRoundTrips() throws {
        // `ServerError` is nested one level further, inside this very enum, and is a `String`
        // backed enum of three cases, so its cases are listed as the rest of this file lists them.
        let refusals: [Question.SaveAttemptServerResponse] = [
            .error(.incorrectFormatServerError),
            .error(.repeatQuestion),
            .error(.unknownError),
        ]
        for value in refusals {
            try roundTripOnTheWire(value, "Question.SaveAttemptServerResponse")
        }

        // The success case carries a `Question`, which is grandfathered twice over: its own
        // `creatorID`, and the `questionID` on each `Response` it carries. The decode stops at
        // whichever it reaches first, and that is the nested one, because `responses` is read
        // before the question's own keys.
        try assertTheTrailingAcronymStopsTheRoundTripOfTheValue(
            Question.SaveAttemptServerResponse.question(try GL28Synth.make(Question.self)),
            "Question.SaveAttemptServerResponse.question", missingKey: "questionID")
    }

    // MARK: - The seven types no other file in this package reaches
    //
    // These were the whole justification for a generated package wide file, and generating one
    // produced 72 cases that duplicated 71 already covered here and never compiled. The seven
    // that were genuinely missing are written out by hand instead, with real initialisers rather
    // than a synthesised value where the type's own Codable is hand written, because a synthesised
    // value cannot choose which branch of a hand written decoder to exercise.

    /// All three cases, including the one that decides whether an absent field is tolerated.
    ///
    /// `VoipSignal` writes its own `encode(to:)` and `init(from:)` keyed on a private `caseType`
    /// discriminator, so nothing about it is derived and nothing about it is covered by a test of
    /// any other type. `iceCandidate` is tested twice on purpose: `sdpMid` is written with
    /// `encodeIfPresent` and read with `decodeIfPresent`, so the nil and non nil spellings take
    /// different paths through both halves, and only one of them is reached by a sample value.
    func testGL28_1_7_everyCaseOfVoipSignalRoundTrips() throws {
        let signals: [VoipSignal] = [
            .offer(sdp: "v=0\r\no=- 1 1 IN IP4 127.0.0.1"),
            .answer(sdp: "v=0\r\na=recvonly"),
            .iceCandidate(sdp: "candidate:1 1 UDP 2130706431 10.0.0.1 54321 typ host",
                          sdpMLineIndex: 0, sdpMid: "audio"),
            .iceCandidate(sdp: "candidate:2 1 UDP 2130706430 10.0.0.2 54322 typ host",
                          sdpMLineIndex: 1, sdpMid: nil),
        ]
        for signal in signals {
            try roundTrip(signal, "VoipSignal.\(signal)")
        }
    }

    /// And the absent `sdpMid` really is absent on the wire, not written as null.
    ///
    /// Without this the case above passes whether `encodeIfPresent` or `encode` is used, because
    /// both decode back to the same value. The difference is visible only in the bytes, and it
    /// matters: the server relays this payload unchanged to the other participant.
    func testGL28_1_7_anAbsentSdpMidIsOmittedFromTheWireRatherThanWrittenAsNull() throws {
        let wire = try JSONEncoder.akinWire.encode(
            Box(value: VoipSignal.iceCandidate(sdp: "candidate:3", sdpMLineIndex: 2, sdpMid: nil)))
        let text = String(decoding: wire, as: UTF8.self)
        XCTAssertTrue(text.contains("candidate:3"), "the signal did not encode at all: \(text)")
        XCTAssertFalse(text.contains("sdp_mid"), "an absent sdpMid was written anyway: \(text)")
        let present = try JSONEncoder.akinWire.encode(
            Box(value: VoipSignal.iceCandidate(sdp: "candidate:4", sdpMLineIndex: 2, sdpMid: "v")))
        XCTAssertTrue(String(decoding: present, as: UTF8.self).contains("sdp_mid"),
                      "a present sdpMid was not written, so the assertion above measures nothing")
    }

    /// `Week` and its nested `Day`, which carry no acronym and so round trip whole.
    ///
    /// `Week` is `Codable` and not `Equatable`, so the comparison is on the re-encoded JSON.
    func testGL28_1_7_weekRoundTrips() throws {
        let week = Week(
            monday: .init(name: .Monday, timeBlocks: []),
            tuesday: .init(name: .Tuesday, timeBlocks: []),
            wednesday: .init(name: .Wednesday, timeBlocks: []),
            thursday: .init(name: .Thursday, timeBlocks: []),
            friday: .init(name: .Friday, timeBlocks: []),
            saturday: .init(name: .Saturday, timeBlocks: []),
            sunday: .init(name: .Sunday, timeBlocks: []))
        try roundTripOnTheWire(week, "Week")
    }

    /// Every case of the two nested raw value enums, and the third that is also an `Error`.
    func testGL28_1_7_everyCaseOfTheThreeNestedRawValueEnumsRoundTrips() throws {
        for value: Greet.Notification.LocalModel.Key in [.getReviewTime, .weClosedTheGreet] {
            try roundTrip(value, "Greet.Notification.LocalModel.Key.\(value)")
        }
        for value in Greet.Method.allCases {
            try roundTrip(value, "Greet.Method.\(value)")
        }
        // Not `CaseIterable`, so the three are named. A loop over `allCases` that does not exist
        // is a loop over nothing, and this file already carries one case that was written that
        // way and measured nothing.
        let errors: [Question.SaveAttemptServerResponse.ServerError] =
            [.incorrectFormatServerError, .repeatQuestion, .unknownError]
        for value in errors {
            try roundTripOnTheWire(value, "Question.SaveAttemptServerResponse.ServerError.\(value)")
        }
    }

    /// The two that carry a trailing acronym, characterised rather than wished away.
    ///
    /// `GreetEvent` stops on `eventID`, its first declared property, and `VoipSignalPayload` on
    /// `greetID`, which is also its first. Both are non optional, so the decode throws rather
    /// than silently dropping the field, which is the better of the two failures: GL28-D30
    /// records the optional case, where nothing anywhere reports the loss.
    func testGL28_1_7_theTwoRemainingTrailingAcronymTypesStillStopTheRoundTrip() throws {
        try assertTheTrailingAcronymStopsTheRoundTripOfTheValue(
            GreetEvent(serverSequenceNumber: 1, actorUserID: UUID(), serverDate: Date(),
                       action: .manualGreetInitiated, greetID: UUID()),
            "GreetEvent", missingKey: "eventID")
        try assertTheTrailingAcronymStopsTheRoundTripOfTheValue(
            VoipSignalPayload(greetID: UUID(), callType: .ringToGreet,
                              signal: .offer(sdp: "v=0")),
            "VoipSignalPayload", missingKey: "greetID")
    }
}
