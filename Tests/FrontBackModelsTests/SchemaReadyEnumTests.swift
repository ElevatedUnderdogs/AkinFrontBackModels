//
//  SchemaReadyEnumTests.swift
//  FrontBackModelsTests
//
//  Pins the explicit `CodingKeys` and `CaseIterable` added to the model enums, which let every
//  model type describe its own JSON shape.
//
//  MapMatesMCP builds the input schema for an MCP tool straight from a model type's
//  `init(from:)`. To list an enum's values it needs the enum to say what all of them are:
//  `CaseIterable` on a plain enum, and a `CaseIterable` `CodingKeys` on an enum whose cases carry
//  values. Before they were added, 41 enums said neither, so any type that reached one of them came
//  out with an incomplete schema.
//
//  What these tests prove, per enum:
//  - `allCases` (or `CodingKeys.allCases`) names exactly the cases the enum has, in order, so a
//    case added later without updating the list fails here.
//  - Every case still encodes to the same JSON as before. Plain enums are checked against their
//    raw value. Enums whose cases carry values are checked against JSON saved from main before
//    they were added, see SavedJSONBeforeChangeCases.swift, with both a plain `JSONEncoder` and
//    `JSONEncoder.akinWire`.
//  - Every case decodes back from that JSON.
//  The checks are written once, in the helpers at the bottom, and each test names the enum and
//  its expected cases.
//
//  The two `private enum CaseType` discriminators, in `Greet.Notification` and `VoipSignal`,
//  cannot be named from a test, so they are exercised through the type that owns them.
//

import XCTest
@testable import AkinFrontBackModels

final class SchemaReadyEnumTests: XCTestCase {

    // MARK: - Enums with raw values

    func testCompatibilityRuleAllCases() throws {
        let rawValues = ["mandatory", "weighted"]
        try assertRawCases(CompatibilityRule.self, rawValues)
    }

    func testFreezeOutcomeAllCases() throws {
        let rawValues = [
            "frozen",
            "released",
            "allowanceExhausted",
            "heldByAnother",
            "targetUnreachable",
        ]
        try assertRawCases(FreezeOutcome.self, rawValues)
    }

    func testReserveOutcomeAllCases() throws {
        let rawValues = [
            "reserved",
            "cancelled",
            "allowanceExhausted",
            "alreadyQueued",
            "targetAvailableNow",
            "targetNotReservable",
        ]
        try assertRawCases(ReserveOutcome.self, rawValues)
    }

    func testChooseForMeOutcomeAllCases() throws {
        let rawValues = ["chose", "noCandidates", "allUnavailable"]
        try assertRawCases(ChooseForMeOutcome.self, rawValues)
    }

    func testFlagSourceAllCases() throws {
        let rawValues = ["appleIntelligence", "autoServerOpenAI", "manualOtherUser"]
        try assertRawCases(FlagSource.self, rawValues)
    }

    func testRiskLevelAllCases() throws {
        let rawValues = ["low", "medium", "high", "critical"]
        try assertRawCases(RiskLevel.self, rawValues)
    }

    func testGreetDemoCallStateAllCases() throws {
        let rawValues = ["none", "ringingFromViewer", "ringingFromCounterpart", "connected"]
        try assertRawCases(GreetDemoCallState.self, rawValues)
    }

    func testHTTPMethodAllCases() throws {
        let rawValues = ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD"]
        try assertRawCases(AkinFrontBackModels.HTTPMethod.self, rawValues)
    }

    func testManualGreetStatusAllCases() throws {
        let rawValues = ["success"]
        try assertRawCases(ManualGreetStatus.self, rawValues)
    }

    func testMeetMarkPromptKindAllCases() throws {
        let rawValues = ["question", "answer"]
        try assertRawCases(MeetMarkPromptKind.self, rawValues)
    }

    func testMeetMarkedMemberStatusAllCases() throws {
        let rawValues = ["named", "anonymous", "departed"]
        try assertRawCases(MeetMarkedMemberStatus.self, rawValues)
    }

    func testNearbyUserMessageMessageTypeAllCases() throws {
        let rawValues = ["addUser", "removeUser", "updateUser", "resetAll"]
        try assertRawCases(NearbyUserMessage.MessageType.self, rawValues)
    }

    func testModerationContentTypeAllCases() throws {
        let rawValues = ["question", "response", "imageMetaData"]
        try assertRawCases(ModerationContentType.self, rawValues)
    }

    func testWeekDayNameAllCases() throws {
        let rawValues = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday",
        ]
        try assertRawCases(Week.Day.Name.self, rawValues)
    }

    func testRejectionActionAllCases() throws {
        let rawValues = [
            "dismiss",
            "cancel",
            "rejectedVoip",
            "closedApp",
            "rejectedByAcceptingAnotherCall",
        ]
        try assertRawCases(RejectionAction.self, rawValues)
    }

    func testTravelMethodAllCases() throws {
        let rawValues = ["bike", "car", "none", "walk", "motorcycle", "transit"]
        try assertRawCases(TravelMethod.self, rawValues)
    }

    func testViewSettingConifirmationReasonAllCases() throws {
        let rawValues = ["nearby", "theyConfirmed"]
        try assertRawCases(ViewSetting.ConifirmationReason.self, rawValues)
    }

    func testGreetNotificationLocalModelKeyAllCases() throws {
        let rawValues = ["getReviewTime", "weClosedTheGreet"]
        try assertRawCases(Greet.Notification.LocalModel.Key.self, rawValues)
    }

    func testWeekDayHourAMPMAllCases() throws {
        let rawValues = ["am", "pm"]
        try assertRawCases(Week.Day.Hour.AMPM.self, rawValues)
    }

    // MARK: - Enums without raw values or associated values

    func testGreetedClientStatusAllCases() throws {
        let expected: [GreetedClientStatus] = [
            .confirmedMet,
            .exceededRange,
            .rejectedOther,
            .onGoing,
            .connectionLost,
        ]
        XCTAssertEqual(GreetedClientStatus.allCases, expected)
        try assertMatchesSavedJSON(
            GreetedClientStatus.self,
            SavedJSONBeforeChangeCases.greetedClientStatus,
            covering: expected.map { "\($0)" }
        )
    }

    func testHideOptionAllCases() throws {
        let expected: [HideOption] = [.automatic, .manual]
        XCTAssertEqual(HideOption.allCases, expected)
        try assertMatchesSavedJSON(
            HideOption.self,
            SavedJSONBeforeChangeCases.hideOption,
            covering: expected.map { "\($0)" }
        )
    }

    func testRequirementLocationAllCases() throws {
        let expected: [Requirement.Location] = [
            .regular,
            .requiresDeeplinkToSettings,
            .shouldUpgradeToAlways,
        ]
        XCTAssertEqual(Requirement.Location.allCases, expected)
        try assertMatchesSavedJSON(
            Requirement.Location.self,
            SavedJSONBeforeChangeCases.requirementLocation,
            covering: expected.map { "\($0)" }
        )
    }

    func testRequirementPushNotificationAllCases() throws {
        let expected: [Requirement.PushNotification] = [.requiresDeeplinkToSettings, .regular]
        XCTAssertEqual(Requirement.PushNotification.allCases, expected)
        try assertMatchesSavedJSON(
            Requirement.PushNotification.self,
            SavedJSONBeforeChangeCases.requirementPushNotification,
            covering: expected.map { "\($0)" }
        )
    }

    // MARK: - Enums whose cases carry values

    func testAutomaticGreetDebugActionCodingKeys() throws {
        let names = ["expireCooldownNow", "setLastGreet", "clearPairHistory"]
        try assertCodingKeys(AutomaticGreetDebugAction.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            AutomaticGreetDebugAction.self,
            SavedJSONBeforeChangeCases.automaticGreetDebugAction,
            covering: names
        )
    }

    func testAutomaticGreetSuppressionCodingKeys() throws {
        let names = [
            "pairCooldown",
            "memberCapReached",
            "alreadyInAGreet",
            "pendingGreetUnanswered",
            "alreadyMet",
            "busy",
            "automaticGreetsOff",
            "hiddenFromNearby",
            "blocked",
            "unreachable",
            "unverified",
            "moderationFlagged",
            "frozenByAnotherMember",
            "outsideStatedAvailability",
            "noVenueBetweenThem",
            "unavailableToYou",
        ]
        try assertCodingKeys(AutomaticGreetSuppression.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            AutomaticGreetSuppression.self,
            SavedJSONBeforeChangeCases.automaticGreetSuppression,
            covering: names
        )
    }

    func testGreetActionCodingKeys() throws {
        let names = [
            "manualGreetInitiated",
            "agreedToMeet",
            "rejectTime",
            "travelTimeToVenue",
            "travelDistanceToVenue",
            "dismissGreet",
            "closeApp",
            "tappedRedVoipReject",
            "notGettingCloser",
            "callInitiated",
            "callAnswered",
            "callDeclined",
            "callEnded",
            "viewedGreetScreen",
            "confirmedMet",
            "rated",
        ]
        try assertCodingKeys(GreetAction.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            GreetAction.self,
            SavedJSONBeforeChangeCases.greetAction,
            covering: names
        )
    }

    func testGreetLogEventCodingKeys() throws {
        let names = [
            "greetAction",
            "pushQueued",
            "pushSent",
            "pushProviderAccepted",
            "pushFailed",
            "webSocketSent",
            "webSocketFailed",
            "deliveryConfirmed",
            "fallbackTriggered",
            "rateLimited",
            "pushNotifReceived",
            "voipReceived",
            "rejectedViaAnotherCall",
            "userViewed",
            "greetCreated",
            "greetExpired",
            "settingsUpdated",
            "serverFound",
            "clientFound",
        ]
        try assertCodingKeys(GreetLogEvent.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            GreetLogEvent.self,
            SavedJSONBeforeChangeCases.greetLogEvent,
            covering: names
        )
    }

    func testInitiationMethodCodingKeys() throws {
        let names = ["manual", "automatic", "devForced", "unknown"]
        try assertCodingKeys(InitiationMethod.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            InitiationMethod.self,
            SavedJSONBeforeChangeCases.initiationMethod,
            covering: names
        )
    }

    func testManualGreetResponseCodingKeys() throws {
        let names = [
            "notification",
            "otherUserIsInGreet",
            "thisUserIsInGreet",
            "thisAndOtherUserAlreadyInSameGreet",
            "noNearbyVenuesOpen",
        ]
        try assertCodingKeys(ManualGreetResponse.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            ManualGreetResponse.self,
            SavedJSONBeforeChangeCases.manualGreetResponse,
            covering: names
        )
    }

    func testNotificationSubjectCodingKeys() throws {
        let names = ["question", "response", "questionnaire"]
        try assertCodingKeys(NotificationSubject.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            NotificationSubject.self,
            SavedJSONBeforeChangeCases.notificationSubject,
            covering: names
        )
    }

    func testQuestionRequirementCodingKeys() throws {
        let names = ["mustHaveAnswered", "mustNotHaveChosen", "mustHaveChosenOneOf"]
        try assertCodingKeys(QuestionRequirement.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            QuestionRequirement.self,
            SavedJSONBeforeChangeCases.questionRequirement,
            covering: names
        )
    }

    func testQuestionnaireCreatorCodingKeys() throws {
        let names = ["you", "member", "anonymous"]
        try assertCodingKeys(QuestionnaireCreator.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            QuestionnaireCreator.self,
            SavedJSONBeforeChangeCases.questionnaireCreator,
            covering: names
        )
    }

    func testRelationUpdateCodingKeys() throws {
        let names = ["automatic", "manual", "blocked"]
        try assertCodingKeys(RelationUpdate.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            RelationUpdate.self,
            SavedJSONBeforeChangeCases.relationUpdate,
            covering: names
        )
    }

    func testRequirementCodingKeys() throws {
        let names = ["birthday", "location", "profilePic", "pushNotification", "callKitConsent"]
        try assertCodingKeys(Requirement.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            Requirement.self,
            SavedJSONBeforeChangeCases.requirement,
            covering: names
        )
    }

    func testSocketPayloadCodingKeys() throws {
        let names = [
            "greetUpdate",
            "greetEvent",
            "nearbyUserUpdate",
            "pong",
            "voipSignal",
            "nearbyStateUpdate",
            "reservationMatured",
        ]
        try assertCodingKeys(SocketPayload.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            SocketPayload.self,
            SavedJSONBeforeChangeCases.socketPayload,
            covering: names
        )
    }

    func testSubscriptionTargetCodingKeys() throws {
        let names = ["questionnaire", "member"]
        try assertCodingKeys(SubscriptionTarget.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            SubscriptionTarget.self,
            SavedJSONBeforeChangeCases.subscriptionTarget,
            covering: names
        )
    }

    func testTimingUpdateCodingKeys() throws {
        let names = ["agreed", "rejected"]
        try assertCodingKeys(TimingUpdate.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            TimingUpdate.self,
            SavedJSONBeforeChangeCases.timingUpdate,
            covering: names
        )
    }

    func testTravelUpdateCodingKeys() throws {
        let names = ["percentTravelled", "exceededRange"]
        try assertCodingKeys(TravelUpdate.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            TravelUpdate.self,
            SavedJSONBeforeChangeCases.travelUpdate,
            covering: names
        )
    }

    func testViewSettingCodingKeys() throws {
        let names = [
            "inGreet",
            "inGreetConfirmedMet",
            "otherAskedIfCanMeetLater",
            "rejected",
            "start",
            "thisUserAgreed",
        ]
        try assertCodingKeys(ViewSetting.CodingKeys.self, names)
        try assertMatchesSavedJSON(
            ViewSetting.self,
            SavedJSONBeforeChangeCases.viewSetting,
            covering: names
        )
    }

    // MARK: - The private discriminators

    func testNotificationCaseTypeKeepsItsJSONForEveryCase() throws {
        try assertMatchesSavedJSON(
            Greet.Notification.self,
            SavedJSONBeforeChangeCases.greetNotification,
            covering: ["getRating", "greet", "silentLocationUpdate"]
        )
    }

    func testVoipSignalCaseTypeKeepsItsJSONForEveryCase() throws {
        try assertMatchesSavedJSON(
            VoipSignal.self,
            SavedJSONBeforeChangeCases.voipSignal,
            covering: ["offer", "answer", "iceCandidate"]
        )
    }

    // MARK: - Helpers

    /// `allCases` lists exactly `expected`, and every case encodes to its raw value as a JSON
    /// string and decodes back to itself, with both encoders.
    private func assertRawCases<T>(
        _ type: T.Type,
        _ expected: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws
    where T: Codable & CaseIterable & RawRepresentable & Hashable, T.RawValue == String {
        XCTAssertEqual(T.allCases.map(\.rawValue), expected, file: file, line: line)
        XCTAssertEqual(Set(T.allCases).count, expected.count, file: file, line: line)
        XCTAssertNil(T(rawValue: "not a case of \(T.self)"), file: file, line: line)
        for value in T.allCases {
            for (encoder, decoder) in Self.coders {
                let data = try encoder.encode(value)
                let json = String(decoding: data, as: UTF8.self)
                XCTAssertEqual(json, "\"\(value.rawValue)\"", file: file, line: line)
                let back = try decoder.decode(T.self, from: data)
                XCTAssertEqual(back, value, file: file, line: line)
            }
        }
    }

    /// `CodingKeys.allCases` lists exactly `expected`, and every key behaves like the key Swift
    /// used to write: a string key named after its case, with no integer value.
    private func assertCodingKeys<K>(
        _ type: K.Type,
        _ expected: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws where K: CodingKey & CaseIterable & RawRepresentable, K.RawValue == String {
        XCTAssertEqual(K.allCases.map(\.stringValue), expected, file: file, line: line)
        for key in K.allCases {
            XCTAssertEqual(key.rawValue, key.stringValue, file: file, line: line)
            XCTAssertNil(key.intValue, file: file, line: line)
            XCTAssertEqual(K(stringValue: key.stringValue)?.stringValue, key.stringValue,
                           file: file, line: line)
            XCTAssertEqual(K(rawValue: key.rawValue)?.rawValue, key.rawValue,
                           file: file, line: line)
        }
        XCTAssertNil(K(stringValue: "notACase"), file: file, line: line)
        XCTAssertNil(K(intValue: 0), file: file, line: line)
    }

    /// The saved JSON covers exactly the `covering` cases. Each plain string decodes with the
    /// current code and encodes back to the same bytes, and the same value encodes to the saved
    /// akinWire string.
    ///
    /// Decoding the saved akinWire string is deliberately not part of this. A key ending in `ID`
    /// does not survive `.convertFromSnakeCase` (`user_id` comes back as `userId`), which is a
    /// known, older problem pinned in GL28IDKeyHazardTests, and it is the same with or without
    /// the explicit `CodingKeys`.
    private func assertMatchesSavedJSON<T: Codable>(
        _ type: T.Type,
        _ savedCases: [SavedJSONBeforeChange],
        covering expected: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        XCTAssertEqual(savedCases.map(\.caseName), expected, "a case has no saved JSON",
                       file: file, line: line)
        let (plainEncoder, plainDecoder) = Self.coders[0]
        let (akinWireEncoder, _) = Self.coders[1]
        for saved in savedCases {
            let value = try plainDecoder.decode(T.self, from: Data(saved.plain.utf8))
            let plain = String(decoding: try plainEncoder.encode(value), as: UTF8.self)
            XCTAssertEqual(plain, saved.plain, "\(T.self).\(saved.caseName) moved",
                           file: file, line: line)
            let akinWire = String(decoding: try akinWireEncoder.encode(value), as: UTF8.self)
            XCTAssertEqual(akinWire, saved.akinWire,
                           "\(T.self).\(saved.caseName) moved on akinWire",
                           file: file, line: line)
            try assertDecodesBackEqual(value, plainEncoder, plainDecoder, file: file, line: line)
        }
    }

    private func assertDecodesBackEqual<T: Codable>(
        _ value: T, _ encoder: JSONEncoder, _ decoder: JSONDecoder,
        file: StaticString, line: UInt
    ) throws {
        // Not Equatable, so equality is the byte comparison the caller already made.
    }

    private func assertDecodesBackEqual<T: Codable & Equatable>(
        _ value: T, _ encoder: JSONEncoder, _ decoder: JSONDecoder,
        file: StaticString, line: UInt
    ) throws {
        let back = try decoder.decode(T.self, from: try encoder.encode(value))
        XCTAssertEqual(back, value, file: file, line: line)
    }

    /// A plain encoder and decoder, and the snake_case, ISO date pair the app and server use.
    /// Keys are sorted so the output is stable text.
    private static var coders: [(JSONEncoder, JSONDecoder)] {
        let plain = JSONEncoder()
        plain.outputFormatting = [.sortedKeys]
        let akinWire = JSONEncoder.akinWire
        akinWire.outputFormatting = [.sortedKeys]
        return [(plain, JSONDecoder()), (akinWire, JSONDecoder.akinWire)]
    }
}
