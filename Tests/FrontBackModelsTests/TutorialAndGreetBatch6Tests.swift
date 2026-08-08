import XCTest
@testable import AkinFrontBackModels

/// Table-driven expectations for every `GreetAction` computed property.
struct GreetActionCase {
    let action: GreetAction
    let isTravelTimeUpdate: Bool
    let isDistanceUpdate: Bool
    let travelTime: Int?
    let travelDistance: Double?
    let isRated: Bool
    let isAgreeToMeet: Bool
    let isRejectMeet: Bool
    let agreeToTime: Int?
    let isCallKitAction: Bool
    let callType: CallType?
    let isViewedGreetScreen: Bool
}

final class TutorialAndGreetBatch6Tests: XCTestCase {

    // MARK: - Shared helpers (Greet + friends)

    func makeNearbyUser(id: UUID = UUID(), name: String = "Tom") -> NearbyUser {
        NearbyUser(
            id: id,
            name: name,
            profileImage: "",
            imageMetaData: ImageMetadata(
                width: 20,
                height: 20,
                format: "jpeg",
                assessment: ModerationAssessment(entries: []),
                id: UUID()
            ),
            verified: true,
            lastLocationUpdate: nil
        )
    }

    func makeEvent(
        eventID: UUID = UUID(),
        serverSequenceNumber: Int,
        actorUserID: UUID,
        serverDate: Date = Date(),
        action: GreetAction,
        greetID: UUID = UUID()
    ) -> GreetEvent {
        GreetEvent(
            eventID: eventID,
            serverSequenceNumber: serverSequenceNumber,
            actorUserID: actorUserID,
            serverDate: serverDate,
            action: action,
            greetID: greetID
        )
    }

    func makeGreet(
        thisUserID: UUID,
        otherUser: NearbyUser,
        otherMinutesAway: Int = 15,
        minutesAway: Int = 10,
        events: [GreetEvent] = []
    ) throws -> Greet {
        try Greet(
            thisUserID: thisUserID,
            otherUser: otherUser,
            greetID: UUID(),
            venue: Venue(url: "", name: "Starbucks", address: "", latitude: 37, longitude: 36),
            minutesAway: minutesAway,
            otherMinutesAway: otherMinutesAway,
            initiationMethod: .manual(userID: thisUserID),
            travelMethod: .bike,
            matchMakingMethodVersion: 1,
            participantUserIDs: [thisUserID, otherUser.id],
            events: events
        )
    }

    // MARK: - Week

    func testWeekInitAssignsEachDay() {
        let week = Week(
            monday: Week.Day(name: .Monday),
            tuesday: Week.Day(name: .Tuesday),
            wednesday: Week.Day(name: .Wednesday),
            thursday: Week.Day(name: .Thursday),
            friday: Week.Day(name: .Friday),
            saturday: Week.Day(name: .Saturday),
            sunday: Week.Day(name: .Sunday)
        )
        XCTAssertEqual(week.monday.name, .Monday)
        XCTAssertEqual(week.tuesday.name, .Tuesday)
        XCTAssertEqual(week.wednesday.name, .Wednesday)
        XCTAssertEqual(week.thursday.name, .Thursday)
        XCTAssertEqual(week.friday.name, .Friday)
        XCTAssertEqual(week.saturday.name, .Saturday)
        XCTAssertEqual(week.sunday.name, .Sunday)
    }

    func testWeekCodableRoundTrip() throws {
        let hour = Week.Day.Hour(militaryHour: 9, amPM: .am, travelMethod: .bike)
        let week = Week(
            monday: Week.Day(name: .Monday, timeBlocks: [hour]),
            tuesday: Week.Day(name: .Tuesday),
            wednesday: Week.Day(name: .Wednesday),
            thursday: Week.Day(name: .Thursday),
            friday: Week.Day(name: .Friday),
            saturday: Week.Day(name: .Saturday),
            sunday: Week.Day(name: .Sunday)
        )
        let data = try JSONEncoder().encode(week)
        let decoded = try JSONDecoder().decode(Week.self, from: data)

        XCTAssertEqual(decoded.monday.name, .Monday)
        XCTAssertEqual(decoded.monday.timeBlocks.count, 1)
        XCTAssertEqual(decoded.monday.timeBlocks.first?.militaryHour, 9)
        XCTAssertEqual(decoded.monday.timeBlocks.first?.amPM, .am)
        XCTAssertEqual(decoded.monday.timeBlocks.first?.travelMethod, .bike)
        XCTAssertEqual(decoded.tuesday.timeBlocks.count, 0)
        XCTAssertEqual(decoded.sunday.name, .Sunday)
    }

    // MARK: - Week.Day

    func testDayInitDefaultsTimeBlocksToEmpty() {
        let day = Week.Day(name: .Friday)
        XCTAssertEqual(day.name, .Friday)
        XCTAssertTrue(day.timeBlocks.isEmpty)
    }

    func testDayInitWithCustomTimeBlocks() {
        let hour1 = Week.Day.Hour(militaryHour: 8, amPM: .am, travelMethod: .walk)
        let hour2 = Week.Day.Hour(militaryHour: 17, amPM: .pm, travelMethod: .car)
        let day = Week.Day(name: .Saturday, timeBlocks: [hour1, hour2])
        XCTAssertEqual(day.timeBlocks.count, 2)
        XCTAssertEqual(day.timeBlocks[0].militaryHour, 8)
        XCTAssertEqual(day.timeBlocks[1].militaryHour, 17)
    }

    func testDayNameAllCasesRawValuesAndCodableRoundTrip() throws {
        let cases: [(Week.Day.Name, String)] = [
            (.Sunday, "Sunday"), (.Monday, "Monday"), (.Tuesday, "Tuesday"),
            (.Wednesday, "Wednesday"), (.Thursday, "Thursday"), (.Friday, "Friday"),
            (.Saturday, "Saturday")
        ]
        for (name, rawValue) in cases {
            XCTAssertEqual(name.rawValue, rawValue)
            let data = try JSONEncoder().encode(name)
            let decoded = try JSONDecoder().decode(Week.Day.Name.self, from: data)
            XCTAssertEqual(decoded, name)
        }
    }

    // MARK: - Week.Day.Hour

    func testHourInitAssignsProperties() {
        let hour = Week.Day.Hour(militaryHour: 14, amPM: .pm, travelMethod: .transit)
        XCTAssertEqual(hour.militaryHour, 14)
        XCTAssertEqual(hour.amPM, .pm)
        XCTAssertEqual(hour.travelMethod, .transit)
    }

    func testHourTravelMethodIsMutable() {
        var hour = Week.Day.Hour(militaryHour: 14, amPM: .pm, travelMethod: .transit)
        hour.travelMethod = .motorcycle
        XCTAssertEqual(hour.travelMethod, .motorcycle)
    }

    func testStandardHourBoundaryValues() {
        let cases: [(Int, Int)] = [
            (0, 12),   // midnight
            (1, 1),
            (11, 11),
            (12, 12),  // noon
            (13, 1),
            (23, 11),  // end of day
            (24, 12)   // wraps past 24
        ]
        for (militaryHour, expectedStandardHour) in cases {
            let hour = Week.Day.Hour(militaryHour: militaryHour, amPM: .am, travelMethod: .walk)
            XCTAssertEqual(hour.standardHour, expectedStandardHour, "militaryHour \(militaryHour)")
        }
    }

    func testHourCodableRoundTrip() throws {
        let hour = Week.Day.Hour(militaryHour: 6, amPM: .am, travelMethod: .car)
        let data = try JSONEncoder().encode(hour)
        let decoded = try JSONDecoder().decode(Week.Day.Hour.self, from: data)
        XCTAssertEqual(decoded.militaryHour, 6)
        XCTAssertEqual(decoded.amPM, .am)
        XCTAssertEqual(decoded.travelMethod, .car)
    }

    // MARK: - Week.Day.Hour.AMPM

    func testAMPMRawValuesAndCodableRoundTrip() throws {
        for (value, rawValue) in [(Week.Day.Hour.AMPM.am, "am"), (.pm, "pm")] {
            XCTAssertEqual(value.rawValue, rawValue)
            let data = try JSONEncoder().encode(value)
            let decoded = try JSONDecoder().decode(Week.Day.Hour.AMPM.self, from: data)
            XCTAssertEqual(decoded, value)
        }
    }

    // MARK: - HideStatus

    func testHideStatusShowsInNearbyList() {
        XCTAssertTrue(HideStatus.hiddenFromNearbyList.showsInNearbyList)
        XCTAssertTrue(HideStatus.hidden.showsInNearbyList)
        XCTAssertFalse(HideStatus.showing.showsInNearbyList)
    }

    func testHideStatusEligibleForMeetup() {
        XCTAssertTrue(HideStatus.hiddenFromNearbyList.eligibleForMeetup)
        XCTAssertFalse(HideStatus.hidden.eligibleForMeetup)
        XCTAssertTrue(HideStatus.showing.eligibleForMeetup)
    }

    func testHideStatusAllCases() {
        XCTAssertEqual(HideStatus.allCases.count, 3)
        XCTAssertTrue(HideStatus.allCases.contains(.hiddenFromNearbyList))
        XCTAssertTrue(HideStatus.allCases.contains(.hidden))
        XCTAssertTrue(HideStatus.allCases.contains(.showing))
    }

    func testHideStatusRawValuesAndCodableRoundTrip() throws {
        let cases: [(HideStatus, String)] = [
            (.hiddenFromNearbyList, "hiddenFromNearbyList"),
            (.hidden, "hidden"),
            (.showing, "showing")
        ]
        for (status, rawValue) in cases {
            XCTAssertEqual(status.rawValue, rawValue)
            let data = try JSONEncoder().encode(status)
            let decoded = try JSONDecoder().decode(HideStatus.self, from: data)
            XCTAssertEqual(decoded, status)
        }
    }

    func testHideStatusHashable() {
        let set: Set<HideStatus> = [.hidden, .hidden, .showing]
        XCTAssertEqual(set.count, 2)
    }

    // MARK: - FloatingPoint

    func testDegreesToRadians() {
        XCTAssertEqual(Double(0).degreesToRadians, 0, accuracy: 0.0000001)
        XCTAssertEqual(Double(180).degreesToRadians, .pi, accuracy: 0.0000001)
        XCTAssertEqual(Double(90).degreesToRadians, .pi / 2, accuracy: 0.0000001)
        XCTAssertEqual(Double(360).degreesToRadians, 2 * .pi, accuracy: 0.0000001)
        XCTAssertEqual(Double(-90).degreesToRadians, -(.pi / 2), accuracy: 0.0000001)
    }

    func testRadiansToDegrees() {
        XCTAssertEqual(Double(0).radiansToDegrees, 0, accuracy: 0.0000001)
        XCTAssertEqual(Double.pi.radiansToDegrees, 180, accuracy: 0.0000001)
        XCTAssertEqual((Double.pi / 2).radiansToDegrees, 90, accuracy: 0.0000001)
        XCTAssertEqual((2 * Double.pi).radiansToDegrees, 360, accuracy: 0.0000001)
    }

    func testDegreesRadiansRoundTrip() {
        let original = 37.7749
        XCTAssertEqual(original.degreesToRadians.radiansToDegrees, original, accuracy: 0.0000001)
    }

    func testDegreesToRadiansOnFloat() {
        let value: Float = 180
        XCTAssertEqual(value.degreesToRadians, Float.pi, accuracy: 0.0001)
    }

    func testEarthRadiusConstant() {
        XCTAssertEqual(Double.earthRadius, 6367444.7)
    }

    // MARK: - GreetEvent

    func testGreetEventInitAssignsProperties() {
        let eventID = UUID()
        let greetID = UUID()
        let actorID = UUID()
        let date = Date()
        let event = makeEvent(
            eventID: eventID,
            serverSequenceNumber: 3,
            actorUserID: actorID,
            serverDate: date,
            action: .confirmedMet,
            greetID: greetID
        )
        XCTAssertEqual(event.eventID, eventID)
        XCTAssertEqual(event.greetID, greetID)
        XCTAssertEqual(event.serverSequenceNumber, 3)
        XCTAssertEqual(event.actorUserID, actorID)
        XCTAssertEqual(event.serverDate, date)
        XCTAssertEqual(event.action, .confirmedMet)
    }

    func testGreetEventDefaultEventIDIsUnique() {
        let event1 = GreetEvent(serverSequenceNumber: 1, actorUserID: UUID(), serverDate: Date(), action: .confirmedMet, greetID: UUID())
        let event2 = GreetEvent(serverSequenceNumber: 1, actorUserID: UUID(), serverDate: Date(), action: .confirmedMet, greetID: UUID())
        XCTAssertNotEqual(event1.eventID, event2.eventID)
    }

    func testGreetEventComparable() {
        let actor = UUID()
        let low = makeEvent(serverSequenceNumber: 1, actorUserID: actor, action: .confirmedMet)
        let high = makeEvent(serverSequenceNumber: 2, actorUserID: actor, action: .confirmedMet)
        XCTAssertTrue(low < high)
        XCTAssertFalse(high < low)

        let sorted = [high, low].sorted()
        XCTAssertEqual(sorted.map(\.serverSequenceNumber), [1, 2])
    }

    func testGreetEventCodableRoundTrip() throws {
        let event = makeEvent(serverSequenceNumber: 5, actorUserID: UUID(), action: .rated(4, outOf: 5))
        let data = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(GreetEvent.self, from: data)
        XCTAssertEqual(decoded, event)
    }

    // MARK: - Array<GreetEvent>.userAgreedTo

    func testUserAgreedToTrue() {
        let actor = UUID()
        let events = [makeEvent(serverSequenceNumber: 1, actorUserID: actor, action: .agreedToMeet(30))]
        XCTAssertTrue(events.userAgreedTo(meetIn: 30, userID: actor))
    }

    func testUserAgreedToFalseWrongUser() {
        let actor = UUID()
        let events = [makeEvent(serverSequenceNumber: 1, actorUserID: actor, action: .agreedToMeet(30))]
        XCTAssertFalse(events.userAgreedTo(meetIn: 30, userID: UUID()))
    }

    func testUserAgreedToFalseWrongMinutes() {
        let actor = UUID()
        let events = [makeEvent(serverSequenceNumber: 1, actorUserID: actor, action: .agreedToMeet(30))]
        XCTAssertFalse(events.userAgreedTo(meetIn: 45, userID: actor))
    }

    func testUserAgreedToFalseDifferentAction() {
        let actor = UUID()
        let events = [makeEvent(serverSequenceNumber: 1, actorUserID: actor, action: .confirmedMet)]
        XCTAssertFalse(events.userAgreedTo(meetIn: 30, userID: actor))
    }

    // MARK: - InitiationMethod

    func testInitiationMethodEquality() {
        let id1 = UUID()
        let id2 = UUID()
        XCTAssertEqual(InitiationMethod.manual(userID: id1), .manual(userID: id1))
        XCTAssertNotEqual(InitiationMethod.manual(userID: id1), .manual(userID: id2))
        XCTAssertEqual(InitiationMethod.automatic(userID: id1), .automatic(userID: id1))
        XCTAssertEqual(InitiationMethod.devForced, .devForced)
        XCTAssertEqual(InitiationMethod.unknown, .unknown)
        XCTAssertNotEqual(InitiationMethod.manual(userID: id1), .automatic(userID: id1))
    }

    func testInitiationMethodCodableRoundTrip() throws {
        let cases: [InitiationMethod] = [.manual(userID: UUID()), .automatic(userID: UUID()), .devForced, .unknown]
        for method in cases {
            let data = try JSONEncoder().encode(method)
            let decoded = try JSONDecoder().decode(InitiationMethod.self, from: data)
            XCTAssertEqual(decoded, method)
        }
    }

    // MARK: - GreetAction computed properties (table-driven, all 16 cases)

    func testGreetActionComputedProperties() {
        let cases: [GreetActionCase] = [
            GreetActionCase(action: .manualGreetInitiated, isTravelTimeUpdate: false, isDistanceUpdate: false, travelTime: nil, travelDistance: nil, isRated: false, isAgreeToMeet: false, isRejectMeet: false, agreeToTime: nil, isCallKitAction: false, callType: nil, isViewedGreetScreen: false),
            GreetActionCase(action: .agreedToMeet(30), isTravelTimeUpdate: false, isDistanceUpdate: false, travelTime: nil, travelDistance: nil, isRated: false, isAgreeToMeet: true, isRejectMeet: false, agreeToTime: 30, isCallKitAction: false, callType: nil, isViewedGreetScreen: false),
            GreetActionCase(action: .rejectTime(15), isTravelTimeUpdate: false, isDistanceUpdate: false, travelTime: nil, travelDistance: nil, isRated: false, isAgreeToMeet: false, isRejectMeet: true, agreeToTime: nil, isCallKitAction: false, callType: nil, isViewedGreetScreen: false),
            GreetActionCase(action: .travelTimeToVenue(changedTo: 12), isTravelTimeUpdate: true, isDistanceUpdate: false, travelTime: 12, travelDistance: nil, isRated: false, isAgreeToMeet: false, isRejectMeet: false, agreeToTime: nil, isCallKitAction: false, callType: nil, isViewedGreetScreen: false),
            GreetActionCase(action: .travelDistanceToVenue(changedTo: 100.5), isTravelTimeUpdate: false, isDistanceUpdate: true, travelTime: nil, travelDistance: 100.5, isRated: false, isAgreeToMeet: false, isRejectMeet: false, agreeToTime: nil, isCallKitAction: false, callType: nil, isViewedGreetScreen: false),
            GreetActionCase(action: .dismissGreet, isTravelTimeUpdate: false, isDistanceUpdate: false, travelTime: nil, travelDistance: nil, isRated: false, isAgreeToMeet: false, isRejectMeet: false, agreeToTime: nil, isCallKitAction: false, callType: nil, isViewedGreetScreen: false),
            GreetActionCase(action: .closeApp, isTravelTimeUpdate: false, isDistanceUpdate: false, travelTime: nil, travelDistance: nil, isRated: false, isAgreeToMeet: false, isRejectMeet: false, agreeToTime: nil, isCallKitAction: false, callType: nil, isViewedGreetScreen: false),
            GreetActionCase(action: .tappedRedVoipReject, isTravelTimeUpdate: false, isDistanceUpdate: false, travelTime: nil, travelDistance: nil, isRated: false, isAgreeToMeet: false, isRejectMeet: false, agreeToTime: nil, isCallKitAction: false, callType: nil, isViewedGreetScreen: false),
            GreetActionCase(action: .notGettingCloser(start: 10, allowance: 5, current: 20), isTravelTimeUpdate: false, isDistanceUpdate: false, travelTime: nil, travelDistance: nil, isRated: false, isAgreeToMeet: false, isRejectMeet: false, agreeToTime: nil, isCallKitAction: false, callType: nil, isViewedGreetScreen: false),
            GreetActionCase(action: .callInitiated(.ringToGreet), isTravelTimeUpdate: false, isDistanceUpdate: false, travelTime: nil, travelDistance: nil, isRated: false, isAgreeToMeet: false, isRejectMeet: false, agreeToTime: nil, isCallKitAction: true, callType: .ringToGreet, isViewedGreetScreen: false),
            GreetActionCase(action: .callAnswered(.ringToVoipAfterOtherUserNotViewed), isTravelTimeUpdate: false, isDistanceUpdate: false, travelTime: nil, travelDistance: nil, isRated: false, isAgreeToMeet: false, isRejectMeet: false, agreeToTime: nil, isCallKitAction: true, callType: .ringToVoipAfterOtherUserNotViewed, isViewedGreetScreen: false),
            GreetActionCase(action: .callDeclined(.ringToVoipEnroute), isTravelTimeUpdate: false, isDistanceUpdate: false, travelTime: nil, travelDistance: nil, isRated: false, isAgreeToMeet: false, isRejectMeet: false, agreeToTime: nil, isCallKitAction: true, callType: .ringToVoipEnroute, isViewedGreetScreen: false),
            GreetActionCase(action: .callEnded(.ringToGreet), isTravelTimeUpdate: false, isDistanceUpdate: false, travelTime: nil, travelDistance: nil, isRated: false, isAgreeToMeet: false, isRejectMeet: false, agreeToTime: nil, isCallKitAction: true, callType: .ringToGreet, isViewedGreetScreen: false),
            GreetActionCase(action: .viewedGreetScreen, isTravelTimeUpdate: false, isDistanceUpdate: false, travelTime: nil, travelDistance: nil, isRated: false, isAgreeToMeet: false, isRejectMeet: false, agreeToTime: nil, isCallKitAction: false, callType: nil, isViewedGreetScreen: true),
            GreetActionCase(action: .confirmedMet, isTravelTimeUpdate: false, isDistanceUpdate: false, travelTime: nil, travelDistance: nil, isRated: false, isAgreeToMeet: false, isRejectMeet: false, agreeToTime: nil, isCallKitAction: false, callType: nil, isViewedGreetScreen: false),
            GreetActionCase(action: .rated(4, outOf: 5), isTravelTimeUpdate: false, isDistanceUpdate: false, travelTime: nil, travelDistance: nil, isRated: true, isAgreeToMeet: false, isRejectMeet: false, agreeToTime: nil, isCallKitAction: false, callType: nil, isViewedGreetScreen: false),
        ]

        for testCase in cases {
            let action = testCase.action
            XCTAssertEqual(action.isTravelTimeUpdate, testCase.isTravelTimeUpdate, "\(action)")
            XCTAssertEqual(action.isDistanceUpdate, testCase.isDistanceUpdate, "\(action)")
            XCTAssertEqual(action.travelTime, testCase.travelTime, "\(action)")
            XCTAssertEqual(action.travelDistance, testCase.travelDistance, "\(action)")
            XCTAssertEqual(action.isRated, testCase.isRated, "\(action)")
            XCTAssertEqual(action.isAgreeToMeet, testCase.isAgreeToMeet, "\(action)")
            XCTAssertEqual(action.isRejectMeet, testCase.isRejectMeet, "\(action)")
            XCTAssertEqual(action.agreeToTime, testCase.agreeToTime, "\(action)")
            XCTAssertEqual(action.isCallKitAction, testCase.isCallKitAction, "\(action)")
            XCTAssertEqual(action.callType, testCase.callType, "\(action)")
            XCTAssertEqual(action.isViewedGreetScreen, testCase.isViewedGreetScreen, "\(action)")
        }
    }

    func testGreetActionCodableRoundTrip() throws {
        let actions: [GreetAction] = [
            .manualGreetInitiated,
            .agreedToMeet(30),
            .rejectTime(15),
            .travelTimeToVenue(changedTo: 12),
            .travelDistanceToVenue(changedTo: 100.5),
            .dismissGreet,
            .closeApp,
            .tappedRedVoipReject,
            .notGettingCloser(start: 10, allowance: 5, current: 20),
            .callInitiated(.ringToGreet),
            .callAnswered(.ringToVoipAfterOtherUserNotViewed),
            .callDeclined(.ringToVoipEnroute),
            .callEnded(.ringToGreet),
            .viewedGreetScreen,
            .confirmedMet,
            .rated(4, outOf: 5)
        ]
        for action in actions {
            let data = try JSONEncoder().encode(action)
            let decoded = try JSONDecoder().decode(GreetAction.self, from: data)
            XCTAssertEqual(decoded, action)
        }
    }

    // MARK: - Greet initializers

    func testGreetFirstInitializerDefaults() throws {
        let thisID = UUID()
        let other = makeNearbyUser()
        let greet = try makeGreet(thisUserID: thisID, otherUser: other)
        XCTAssertEqual(greet.method, .wave)
        XCTAssertTrue(greet.compatitibility.isEmpty)
        XCTAssertTrue(greet.openers.isEmpty)
        XCTAssertTrue(greet.events.isEmpty)
        XCTAssertEqual(greet.thisUserID, thisID)
        XCTAssertEqual(greet.otherUser, other)
        XCTAssertEqual(greet.minutesAway, 10)
        XCTAssertEqual(greet.otherMinutesAway, 15)
        XCTAssertEqual(greet.participantUserIDs, [thisID, other.id])
    }

    func testGreetFirstInitializerWithCustomMethodCompatibilityOpeners() throws {
        let thisID = UUID()
        let other = makeNearbyUser()
        let greet = try Greet(
            thisUserID: thisID,
            otherUser: other,
            greetID: UUID(),
            method: .hug,
            compatitibility: ["friend": 0.8],
            openers: ["hi there"],
            venue: Venue(url: "", name: "Starbucks", address: "", latitude: 37, longitude: 36),
            minutesAway: 10,
            otherMinutesAway: 15,
            initiationMethod: .manual(userID: thisID),
            travelMethod: .bike,
            matchMakingMethodVersion: 1,
            participantUserIDs: [thisID, other.id]
        )
        XCTAssertEqual(greet.method, .hug)
        XCTAssertEqual(greet.compatitibility, ["friend": 0.8])
        XCTAssertEqual(greet.openers, ["hi there"])
    }

    func testGreetSecondInitializerAssignsCorrectMinutesAwayFields() throws {
        let thisID = UUID()
        let other = makeNearbyUser()
        let greet = try Greet(
            thisUserID: thisID,
            otherUser: other,
            greetID: UUID(),
            venue: Venue(url: "", name: "Starbucks", address: "", latitude: 37, longitude: 36),
            otherMinutesAway: 25,
            minutesAway: 5,
            travelMethod: .walk,
            matchMakingMethodVersion: 2,
            participantUserIDs: [thisID, other.id],
            initiationMethod: .automatic(userID: other.id)
        )
        // Defaults applied even though this initializer doesn't set them explicitly.
        XCTAssertEqual(greet.method, .wave)
        XCTAssertTrue(greet.compatitibility.isEmpty)
        XCTAssertTrue(greet.openers.isEmpty)
        // Confirms the swapped parameter order still lands in the right stored property.
        XCTAssertEqual(greet.minutesAway, 5)
        XCTAssertEqual(greet.otherMinutesAway, 25)
        XCTAssertEqual(greet.travelMethod, .walk)
        XCTAssertEqual(greet.matchMakingMethodVersion, 2)
        XCTAssertEqual(greet.initiationMethod, .automatic(userID: other.id))
    }

    func testGreetThresholdConstants() throws {
        let greet = try makeGreet(thisUserID: UUID(), otherUser: makeNearbyUser())
        XCTAssertEqual(greet.wrongWayThreshold, 5)
        XCTAssertEqual(greet.notEnoughProgressThreshold, 10)
    }

    func testGreetCodableRoundTrip() throws {
        let greet = try makeGreet(thisUserID: UUID(), otherUser: makeNearbyUser())
        let data = try JSONEncoder().encode(greet)
        let decoded = try JSONDecoder().decode(Greet.self, from: data)
        XCTAssertEqual(decoded, greet)
    }

    // MARK: - Greet.latestServerSequenceNumber

    func testLatestServerSequenceNumberEmptyEvents() throws {
        let greet = try makeGreet(thisUserID: UUID(), otherUser: makeNearbyUser())
        XCTAssertEqual(greet.latestServerSequenceNumber, 0)
    }

    func testLatestServerSequenceNumberWithEvents() throws {
        let thisID = UUID()
        let other = makeNearbyUser()
        let events = [
            makeEvent(serverSequenceNumber: 0, actorUserID: thisID, action: .agreedToMeet(30)),
            makeEvent(serverSequenceNumber: 1, actorUserID: other.id, action: .agreedToMeet(30))
        ]
        let greet = try makeGreet(thisUserID: thisID, otherUser: other, events: events)
        XCTAssertEqual(greet.latestServerSequenceNumber, 1)
    }

    // MARK: - Greet.otherUserTravelStatusText

    func testOtherUserTravelStatusTextFallsBackToOtherMinutesAwayWhenNoEvents() throws {
        let greet = try makeGreet(thisUserID: UUID(), otherUser: makeNearbyUser(), otherMinutesAway: 15)
        XCTAssertEqual(greet.otherUserTravelStatusText, "Status: 15 minute/s away")
    }

    func testOtherUserTravelStatusTextAtVenueWhenOtherMinutesAwayIsZero() throws {
        let greet = try makeGreet(thisUserID: UUID(), otherUser: makeNearbyUser(), otherMinutesAway: 0)
        XCTAssertEqual(greet.otherUserTravelStatusText, "They are at the venue!")
    }

    func testOtherUserTravelStatusTextUsesLatestTravelTimeUpdateFromOtherUser() throws {
        let thisID = UUID()
        let other = makeNearbyUser()
        let events = [
            makeEvent(serverSequenceNumber: 1, actorUserID: other.id, action: .travelTimeToVenue(changedTo: 50)),
            makeEvent(serverSequenceNumber: 2, actorUserID: other.id, action: .agreedToMeet(30)),
            makeEvent(serverSequenceNumber: 3, actorUserID: other.id, action: .travelTimeToVenue(changedTo: 20))
        ]
        let greet = try makeGreet(thisUserID: thisID, otherUser: other, otherMinutesAway: 99, events: events)
        XCTAssertEqual(greet.otherUserTravelStatusText, "Status: 20 minute/s away")
    }

    func testOtherUserTravelStatusTextIgnoresEventsFromThisUser() throws {
        let thisID = UUID()
        let other = makeNearbyUser()
        let events = [
            makeEvent(serverSequenceNumber: 1, actorUserID: thisID, action: .travelTimeToVenue(changedTo: 999))
        ]
        let greet = try makeGreet(thisUserID: thisID, otherUser: other, otherMinutesAway: 8, events: events)
        XCTAssertEqual(greet.otherUserTravelStatusText, "Status: 8 minute/s away")
    }

    func testOtherUserTravelStatusTextAtVenueWhenLatestUpdateIsZero() throws {
        let thisID = UUID()
        let other = makeNearbyUser()
        let events = [
            makeEvent(serverSequenceNumber: 1, actorUserID: other.id, action: .travelTimeToVenue(changedTo: 0))
        ]
        let greet = try makeGreet(thisUserID: thisID, otherUser: other, otherMinutesAway: 15, events: events)
        XCTAssertEqual(greet.otherUserTravelStatusText, "They are at the venue!")
    }

    // MARK: - Greet+LocationCoordinate

    func testUserLocationCoordinateInitAssignsProperties() {
        let userID = UUID()
        let coordinate = Greet.UserLocationCoordinate(
            user: .init(id: userID),
            latitude: 40.7128,
            longitude: -74.0060
        )
        XCTAssertEqual(coordinate.user.id, userID)
        XCTAssertEqual(coordinate.latitude, 40.7128)
        XCTAssertEqual(coordinate.longitude, -74.0060)
    }

    func testUserLocationCoordinateCodableRoundTrip() throws {
        let userID = UUID()
        let coordinate = Greet.UserLocationCoordinate(user: .init(id: userID), latitude: 1.5, longitude: -2.5)
        let data = try JSONEncoder().encode(coordinate)
        let decoded = try JSONDecoder().decode(Greet.UserLocationCoordinate.self, from: data)
        XCTAssertEqual(decoded.user.id, userID)
        XCTAssertEqual(decoded.latitude, 1.5)
        XCTAssertEqual(decoded.longitude, -2.5)
    }

    // MARK: - Greet+User (String.imageIDFromString)

    func testImageIDFromStringWithSlashes() {
        XCTAssertEqual("http://example.com/imageID123".imageIDFromString, "imageID123")
    }

    func testImageIDFromStringMultipleSlashes() {
        XCTAssertEqual("a/b/c".imageIDFromString, "c")
    }

    func testImageIDFromStringNoSlash() {
        XCTAssertEqual("plainImageID".imageIDFromString, "plainImageID")
    }

    func testImageIDFromStringTrailingSlashYieldsEmptyString() {
        XCTAssertEqual("path/to/image/".imageIDFromString, "")
    }

    func testImageIDFromStringJustASlash() {
        XCTAssertEqual("/".imageIDFromString, "")
    }

    func testImageIDFromStringEmptyString() {
        XCTAssertEqual("".imageIDFromString, "")
    }
}
