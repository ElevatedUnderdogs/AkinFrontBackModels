//
//  Greet.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public typealias CompatibilityContext = String
public typealias CompatibilityScore = Double

//public struct GreetPayload {
//    // MARK - properties
//
//    public var greetID: UUID
//    public var method: Greet.Method = .wave
//    /// Will have to refactor this when accounting for more than two users.
//    public var compatibility: [CompatibilityContext: CompatibilityScore] = [:]
//    public var openers: [String] = []
//    public var venue: Venue? = nil
//    public var travelMethod: TravelMethod? = nil
//    public var matchMakingMethodVersion: Double? = nil
//    public var rangeThreshold: Int = 0
//    public var meetingTime: Date? = nil
//
//    public var users: [UUID: NearbyUser]
//
//}

extension [GreetEvent] {

    func userAgreedTo(meetIn: Int, userID: UUID) -> Bool {
        contains(
            where: { $0.action == .agreedToMeet(meetIn) &&
                $0.actorUserID == userID }
        )
    }
}

public enum InitiationMethod: Equatable, Hashable, Codable {
    /// The user that manually initiated the greet.
    case manual(userID: UUID)
    /// The user id of the user whose location update triggered the automatic greet.
    case automatic(userID: UUID)
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
    ///  
    public var compatitibility: [CompatibilityContext: CompatibilityScore] = [:]
    public var openers: [String] = []
    public var venue: Venue
//    public var isMrPractice: Bool = false
//    public var thisSettings = Settings(status: .viewed, id: .init())
//    /// consider moving to thisSettings.
//    /// **BACKEND**Should be given by the updater, so that it is sent to the
//    /// recipient in the otherUser.percentThisTravelled property chain.
//    /// **CLIENT** provide this information to be sent, ignore it when received.
//    public var percentThisTravelled: Double = 0
//    /// Needed for updating the travel distance. for updateGreet endpoint.
//    /// This is needed to be used for the isNearby calculation.
//    public var travelDistanceFromVenueInMeters: Double? = nil
//
    /// The starting distance away from the venue of the other user.
//    public var otherUserTravelMinutesAwayFromVenue: Int

//    /// The starting distance away from the venue of this user.
//    public var travelMinutesToVenue: Int

    public var initiationMethod: InitiationMethod

    /// I presume this user's travel method.   Though it might be the other user's travel method.
    public var travelMethod: TravelMethod
//    public var withinRangeOfEachOtherAndMeetPlace: Int? = nil
    public var matchMakingMethodVersion: Double

    /// Don't know what this is for...on the lookout.. or what it is measured in..
  //  public var rangeThreshold: Int = 0
    public var minutesAway: Int
    //        /// Starting minutes away that this user is.
    //         estimatedTravelTimeInMinutes: Int,
    /// Other user starting minutes away that this user is from the venue.
    public var otherMinutesAway: Int

    // public var meetingTime: Date? = nil

    public let participantUserIDs: [UUID]
    public var events: [GreetEvent] = []

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
        /// Alternatable.
        otherUser: NearbyUser,
        greetID: UUID,
        method: Greet.Method = .wave,
        /// alternatable
        compatitibility: [CompatibilityContext: CompatibilityScore] = [:],
        /// alternatable optionally.
        openers: [String] = [],
        venue: Venue,
        //         isMrPractice: Bool = false,
        /// alternatable
        //         thisSettings: Settings = Settings(status: .viewed, id: .init()),
        /// alternatable
        //         percentThisTravelled: Double = 0,
        //         travelDistanceFromVenueInMeters: Double? = nil,
        /// alternatable
        /// Starting minutes away that this user is.
        minutesAway: Int,
        //        /// Starting minutes away that this user is.
        //         estimatedTravelTimeInMinutes: Int,
        /// Other user starting minutes away that this user is from the venue.
        otherMinutesAway: Int,
        /// alternatable
        initiationMethod: InitiationMethod,
        travelMethod: TravelMethod,
        //         withinRangeOfEachOtherAndMeetPlace: Int? = nil,
        matchMakingMethodVersion: Double,
        // rangeThreshold: Int = 0,
        //  meetingTime: Date? = nil,
        participantUserIDs: [UUID],
        events: [GreetEvent] = []
    ) {
        self.otherUser = otherUser
         self.greetID = greetID
         self.method = method
         self.compatitibility = compatitibility
         self.openers = openers
         self.venue = venue
//         self.isMrPractice = isMrPractice
//         self.thisSettings = thisSettings
//         self.percentThisTravelled = percentThisTravelled
//         self.travelDistanceFromVenueInMeters = travelDistanceFromVenueInMeters
        // self.otherUserTravelMinutesAwayFromVenue = minutesAway
        self.initiationMethod = initiationMethod
         self.travelMethod = travelMethod
//         self.withinRangeOfEachOtherAndMeetPlace = withinRangeOfEachOtherAndMeetPlace
         self.matchMakingMethodVersion = matchMakingMethodVersion
        // self.travelMinutesToVenue = estimatedTravelTimeInMinutes
        // self.rangeThreshold = rangeThreshold
        // self.meetingTime = meetingTime

        self.minutesAway = minutesAway
        self.otherMinutesAway = otherMinutesAway
         self.participantUserIDs = participantUserIDs
         self.events = events
         self.thisUserID = thisUserID
     }
//
//    public var meetInXMinutes: Int? {
//        guard let travelMinutesToVenue else { return nil }
//        guard let otherUserTravelMinutesAwayFromVenue else { return nil }
//        return max(
//            (travelMinutesToVenue + 5 /*buffer*/ + (validProposals.first ?? 0)),
//            (otherUserTravelMinutesAwayFromVenue + 5 /*buffer*/ + (validProposals.first ?? 0))
//        )
//    }
//    
//    public var agreedTime: Int? {
//        guard let otherUserSettings = otherUser.settings else { return nil }
//        return thisSettings.agreedTimeProposals.filter({ !otherUserSettings.rejectedTimeProposals.contains($0) && otherUserSettings.agreedTimeProposals.contains($0) }).first
//    }
//        
//    public var isWaiting: Bool {
//        let proposals = thisSettings.agreedTimeProposals
//        guard let rejectedProposals = otherUser.settings?.rejectedTimeProposals else { return false }
//        return !proposals.filter { !rejectedProposals.contains($0) }.isEmpty
//    }
//    
//    public var viewForProposal: ViewSetting {
//        guard let newProposals = otherUser.settings?.agreedTimeProposals.filter({ !thisSettings.rejectedTimeProposals.contains($0) && $0 != 0 }),
//            let firstNewProposal = newProposals.first else { return .start }
//        return .otherAskedIfCanMeetLater(firstNewProposal)
//    }
//    
//    public var withinRange: Bool {
//        if let withinRange = withinRangeOfEachOtherAndMeetPlace {
//            return withinRange < rangeThreshold
//        }
//        return false
//    }
//    
//    public var otherUserIsEligibleToMeet: Bool {
//        if let otherStatus = otherUser.settings?.status {
//            return otherStatus != .rejectedOther
//                && otherStatus != .exceededRange
//        } else {
//            return false
//        }
//    }
//    
//    // MARK - updates
//    
//    public mutating func update(with new: Greet) -> Greet.Update? {
//        let rejectedTime = rejectedProposal(from: new)
//        venue = new.venue
//        otherUser = new.otherUser
//        thisSettings.updateSettings(with: otherUser.settings)
//        withinRangeOfEachOtherAndMeetPlace = new.withinRangeOfEachOtherAndMeetPlace
//        
//        if thisSettings.status == .enroute && otherUser.settings?.status == .viewed {
//            otherUser.settings?.status = .enroute
//        }
//
//        if !validProposals.isEmpty {
//            otherUser.settings?.status = .enroute
//            thisSettings.status = .enroute
//        }
//
//        return Greet.Update(
//            this: thisSettings.status,
//            otherUser: otherUser.settings?.status,
//            withinRange: withinRange,
//            rejectedProposal: rejectedTime,
//            viewForProposal: viewForProposal,
//            otherUserName: otherUser.personal.name
//        )
//    }
//
//    public var validProposals: [Int] {
//        thisSettings
//            .agreedTimeProposals
//            .filter({ otherUser.settings?.agreedTimeProposals.contains($0) == true })
//            .filter({ otherUser.settings?.rejectedTimeProposals.contains($0) != true && thisSettings.rejectedTimeProposals.contains($0) != true })
//    }
//
//    // Reject
//
//    public func rejectedProposal(from new: Greet) -> Int? {
//        guard let oldRejectedTimeProposals = otherUser.settings?.rejectedTimeProposals,
//              let updatedRejectedTimeProposals =  new.otherUser.settings?.rejectedTimeProposals else {
//            return nil
//        }
//        return updatedRejectedTimeProposals.first { !oldRejectedTimeProposals.contains($0) }
//    }
//
//    public mutating func mrPracticeDidReject() -> Bool? {
//        if !isMrPractice {return nil}
//#if canImport(Darwin)
//return arc4random_uniform(4) == 0
//#else
//return Int.random(in: 0..<4) == 0
//#endif
//    }



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
    ) {
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
        self.initiationMethod = initiationMethod
    }

    public var estimatedMeetTime: String {
        // when the second agreed to comes in. then we grab the server date of the second agreed to time.
        // or the later of the two times
        ""
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
        action: GreetAction
    ) {
        self.eventID = eventID
        self.serverSequenceNumber = serverSequenceNumber
        self.actorUserID = actorUserID
        self.serverDate = serverDate
        self.action = action
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

    // MARK: - Conclusion.
    case confirmedMet

    case rated(Int, outOf: Int)

    public var isTravelTimeUpdate: Bool {
        if case .travelTimeToVenue = self {
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
}
