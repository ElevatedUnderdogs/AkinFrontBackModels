//
//  Greet.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation
import Callable

public typealias CompatibilityContext = String
public typealias CompatibilityScore = Double

extension [GreetEvent] {

    func userAgreedTo(meetIn: Int, userID: UUID) -> Bool {
        contains(
            where: { $0.action == .agreedToMeet(meetIn) &&
                $0.actorUserID == userID }
        )
    }

    /// Checks that the events are ordered and in a sequence.
    /// Considered calling it `isSequentialFromZeroNoGapsIfSorted`
    public var isValid: Bool {
        var counter: Int = 1
        for event in self.sorted(by: <) {
            if event.serverSequenceNumber != counter {
                return false
            }
            counter += 1
        }
        return true
    }
}

extension GreetEvent: Comparable {
    public static func < (lhs: AkinFrontBackModels.GreetEvent, rhs: AkinFrontBackModels.GreetEvent) -> Bool {
        lhs.serverSequenceNumber < rhs.serverSequenceNumber
    }
}

public enum InitiationMethod: Equatable, Hashable, Codable {
    /// The user that manually initiated the greet.
    case manual(userID: UUID)
    /// The user id of the user whose location update triggered the automatic greet.
    case automatic(userID: UUID)

    case devForced

    case unknown
}

public struct Greet: Codable, Equatable, Hashable {

    // MARK - properties

    public var thisUserID: UUID
    public var otherUser: NearbyUser
    public var greetID: UUID

    /// A random greeting method in common between both users in the greet.  If no common methods, then a wave.
    public var method: Greet.Method = .wave

    /// This is the compatibility of the other user to you.
    /// For example, the other user might be 75% compatible as a friend, and 1% compatibility as a romantic partner.
    public var compatitibility: [CompatibilityContext: CompatibilityScore] = [:]
    public var openers: [String] = []
    public var venue: Venue

    public var initiationMethod: InitiationMethod

    /// I presume this user's travel method.   Though it might be the other user's travel method.
    public var travelMethod: TravelMethod
    public var matchMakingMethodVersion: Double

    /// Don't know what this is for...on the lookout.. or what it is measured in..
    public var minutesAway: Int
    public var otherMinutesAway: Int
    public let participantUserIDs: [UUID]
    private(set) public var events: [GreetEvent] = []

    public mutating func add(event: GreetEvent) throws {
        events.append(event)
    }

    public mutating func replace(element tempID: UUID, with updatedElement: GreetEvent) throws {
        if let index = events.firstIndex(where: { $0.eventID == tempID }) {
            events[index] = updatedElement
        } else {
            throw GenericError(text: "We couldn't find an element with id: \(tempID) and events: \(events)")
        }
    }

    /// If their travel time goes beyond this then the greet is auto rejected because someone went the wrong way.
    public var wrongWayThreshold: Int {
        5
    }

    /// If there is a gap equal to this threshold between their travel time updates, then it auto rejects.
    public var notEnoughProgressThreshold: Int {
        10
    }

    // MARK: - Initializer
    public init(
        thisUserID: UUID,
        otherUser: NearbyUser,
        greetID: UUID,
        method: Greet.Method = .wave,
        compatitibility: [CompatibilityContext: CompatibilityScore] = [:],
        openers: [String] = [],
        venue: Venue,
        minutesAway: Int,
        otherMinutesAway: Int,
        initiationMethod: InitiationMethod,
        travelMethod: TravelMethod,
        matchMakingMethodVersion: Double,
        participantUserIDs: [UUID],
        events: [GreetEvent] = []
    ) throws {
        self.otherUser = otherUser
        self.greetID = greetID
        self.method = method
        self.compatitibility = compatitibility
        self.openers = openers
        self.venue = venue
        self.initiationMethod = initiationMethod
        self.travelMethod = travelMethod
        self.matchMakingMethodVersion = matchMakingMethodVersion

        self.minutesAway = minutesAway
        self.otherMinutesAway = otherMinutesAway
        self.participantUserIDs = participantUserIDs
        self.events = events
//        if !self.events.isValid {
//            throw GenericError(text: "events are not valid.")
//        }
        self.thisUserID = thisUserID
    }

    public var latestServerSequenceNumber: Int {
        events.last?.serverSequenceNumber ?? 0
    }

    public init(
        thisUserID: UUID,
        otherUser: NearbyUser,
        greetID: UUID,
        venue: Venue,
        otherMinutesAway: Int,
        minutesAway: Int,
        travelMethod: TravelMethod,
        matchMakingMethodVersion: Double,
        participantUserIDs: [UUID],
        initiationMethod: InitiationMethod,
        events: [GreetEvent] = []
    ) throws {
        self.thisUserID = thisUserID
        self.otherUser = otherUser
        self.greetID = greetID
        self.venue = venue
        self.otherMinutesAway = otherMinutesAway
        self.minutesAway = minutesAway
        self.travelMethod = travelMethod
        self.matchMakingMethodVersion = matchMakingMethodVersion
        self.participantUserIDs = participantUserIDs
        self.events = events
//        if !self.events.isValid {
//            throw GenericError(text: "events are not valid.")
//        }
        self.initiationMethod = initiationMethod
    }

    public var otherUserTravelStatusText: String {
        let lastDistanceUpdate: Int = events
            .filter { $0.actorUserID == otherUser.id }
            .sorted(by: { $0.serverSequenceNumber < $1.serverSequenceNumber })
            .last(where: { $0.action.isTravelTimeUpdate })?
            .action
            .travelTime ?? otherMinutesAway
        return lastDistanceUpdate >= 1 ? "Status: \(lastDistanceUpdate) minute/s away" : "They are at the venue!"
    }
}

typealias Minutes = Int
fileprivate extension Date {

    init?(timeFromNow: Minutes) {
        guard let date = Calendar.current.date(byAdding: .minute, value: timeFromNow, to: Date()) else { return nil}
        self = date
    }

    var clockTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = .init(identifier: .gregorian)
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: self)
    }
}


public struct GreetEvent: Codable, Sendable, Hashable {

    /// Stable identity for this event (idempotency, debugging).
    public let eventID: UUID

    public let greetID: UUID

    /// Monotonic ordering number assigned by the server, scoped to greetID.
    public let serverSequenceNumber: Int

    /// The user who authored the action.
    public let actorUserID: UUID

    /// Server-side timestamp.
    public let serverDate: Date

    /// Client Date

    /// Domain action.
    public let action: GreetAction

    public init(
        eventID: UUID = .init(),
        serverSequenceNumber: Int,
        actorUserID: UUID,
        serverDate: Date,
        action: GreetAction,
        greetID: UUID
    ) {
        self.eventID = eventID
        self.serverSequenceNumber = serverSequenceNumber
        self.actorUserID = actorUserID
        self.serverDate = serverDate
        self.action = action
        self.greetID = greetID
    }
}

// testManualGreetInitiatedStart
// testAlternativeTimeNegotiationThis
// - accept
// - reject
// testAlternativeTimeNegotiationOther
// - aceppt
// - reject
// testDismissBeforeAgree // regular rejections
// testDismissAfterAgree // Counts as a special kind of rejection... this could count against them.
// testCloseAppAfterConfirmedMet // close app, dismiss etc. don't count as rejections after confirmed met as a rejection.. has no effect.
// testCloseAppBeforeConfirmedMet // Maybe we need to add a closeAccepted Event where the user sees the rejected screen after swiping up to close the app?
// testRedRejectAfterOtherWaiting // Show it didn't work out screen.
// testRedReejctAtStartAutomatic // maybe hide greet, if one user rejects an automatic before the other user even sees it... They don't need to know they were rejected..
// testRedRejectAtStartOtherManual
// Test exceededTravelTimeAllowance // not getting closer


// MARK: - Event enum (top-level) with helpers
public enum GreetAction: Codable, Sendable, Hashable, Equatable, ActionStringConvertible {

    /// When a user taps or swipes on another user to try to meet them now.
    ///  **UI Effect:**
    /// It can affect the alert text, instead of "We think you may want to meet", "They'd like to meet you".
    case manualGreetInitiated

    // MARK: - negotiation
    /// The associated value represents a time from the agreement to meet that they would like to leave.
    ///  For example, if both agree to meet in 30 minutes at 5:00PM, then both users should aim to start traveling no later than
    ///  5:30PM
    ///  **UI Effect:** May prompt a user asking if they would like to meet at an alternative time.
    case agreedToMeet(Int)

    /// In the negotiation
    case rejectTime(Int)

    /// Associated value in minutes.
    case travelTimeToVenue(changedTo: Int)

    /// Associated value in meters.
    case travelDistanceToVenue(changedTo: Double)

    // MARK: - Greet closers.
    /// The current verbiage in the app ui is "dismiss" which is essentially rejecting the meetup with the other person
    /// altogether.
    ///  **UI Effect:** Should navigate to a "sorry it didn't work out screen"
    case dismissGreet

    /// A rejection of the other user.
    case closeApp

    case tappedRedVoipReject

    /// Maybe this shouldn't translate to a rejection... But a warning to the other user.  That they aren't getting closer, and we will keep track of that.  you can keep waiting if you'd like.
    /// If you are moving in a way that the travel time is growing past a certain point/allowance,
    ///  then the greet may auto close.  When current > (start + allowance), then auto-close.
    /// - starting travel time.
    /// - allowance
    /// - current travel time.
    case notGettingCloser(start: Int, allowance: Int, current: Int)

    // MARK: - CallKit activity

    /// A user initiated a VoIP call to the other participant.
    /// The associated `CallType` distinguishes the purpose of the call.
    case callInitiated(CallType)

    /// The recipient answered an incoming VoIP call.
    case callAnswered(CallType)

    /// The recipient actively declined an incoming VoIP call.
    case callDeclined(CallType)

    /// Either party ended an in-progress VoIP call.
    case callEnded(CallType)

    /// The other user has viewed the greet screen. Used to track
    /// whether the "no response" call offer should appear.
    case viewedGreetScreen

    // MARK: - Conclusion.
    case confirmedMet

    case rated(Int, outOf: Int)

    public var isTravelTimeUpdate: Bool {
        if case .travelTimeToVenue = self {
            return true
        }
        return false
    }

    public var isDistanceUpdate: Bool {
        if case .travelDistanceToVenue = self {
            return true
        }
        return false
    }

    public var travelTime: Int? {
        if case .travelTimeToVenue(let changedTo) = self {
            return changedTo
        }
        return nil
    }

    public var travelDistance: Double? {
        if case .travelDistanceToVenue(let changedTo) = self {
            return changedTo
        }
        return nil
    }

    public var isRated: Bool {
        if case .rated = self {
            return true
        }
        return false
    }

    public var isAgreeToMeet: Bool {
        if case .agreedToMeet = self {
            return true
        }
        return false
    }

    public var isRejectMeet: Bool {
        if case .rejectTime = self {
            return true
        }
        return false
    }

    /// If the case is agreedToMeet then this returns the time in minutes
    public var agreeToTime: Int? {
        if case .agreedToMeet(let int) = self {
            return int
        }
        return nil
    }

    /// Whether this action represents any CallKit-related activity.
    public var isCallKitAction: Bool {
        switch self {
        case .callInitiated, .callAnswered, .callDeclined, .callEnded:
            return true
        default:
            return false
        }
    }

    /// The `CallType` associated with a CallKit action, if any.
    public var callType: CallType? {
        switch self {
        case .callInitiated(let callType),
             .callAnswered(let callType),
             .callDeclined(let callType),
             .callEnded(let callType):
            return callType
        default:
            return nil
        }
    }

    /// Whether this action indicates the other user viewed the greet screen.
    public var isViewedGreetScreen: Bool {
        if case .viewedGreetScreen = self {
            return true
        }
        return false
    }
}
