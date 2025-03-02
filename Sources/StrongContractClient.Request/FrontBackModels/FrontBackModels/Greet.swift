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

public struct Greet: Codable, Equatable, Hashable {

    // MARK - properties
    
    public var otherUser: Greet.User
    public var greetID: UUID

    /// A random greeting method in common between both users in the greet.  If no common methods, then a wave.
    public var method: Greet.Method = .wave

    /// This is the compatibility of the other user to you.  
    /// For example, the other user might be 75% compatible as a friend, and 1% compatibility as a romantic partner.
    ///  
    public var compatitibility: [CompatibilityContext: CompatibilityScore] = [:]
    public var openers: [String] = []
    public var venue: Venue? = nil
    public var isMrPractice: Bool = false
    public var thisSettings = Settings(status: .viewed, id: .init())
    /// consider moving to thisSettings.
    /// **BACKEND**Should be given by the updater, so that it is sent to the
    /// recipient in the otherUser.percentThisTravelled property chain.
    /// **CLIENT** provide this information to be sent, ignore it when received.
    public var percentThisTravelled: Double = 0
    /// Needed for updating the travel distance. for updateGreet endpoint.
    /// This is needed to be used for the isNearby calculation.
    public var travelDistanceFromVenueInMeters: Double? = nil

    public var otherUserTravelMinutesAwayFromVenue: Int? = nil
    public var travelMinutesToVenue: Int? = nil

    public var travelMethod: TravelMethod? = nil
    public var withinRangeOfEachOtherAndMeetPlace: Int? = nil
    public var matchMakingMethodVersion: Double? = nil
    public var rangeThreshold: Int = 0

    public var meetingTime: Date? = nil

    // MARK: - Initializer
     public init(
        /// Alternatable.
         otherUser: Greet.User,
         greetID: UUID,
         method: Greet.Method = .wave,
         /// alternatable
         compatitibility: [CompatibilityContext: CompatibilityScore] = [:],
        /// alternatable optionally.
         openers: [String] = [],
         venue: Venue? = nil,
         isMrPractice: Bool = false,
        /// alternatable
         thisSettings: Settings = Settings(status: .viewed, id: .init()),
        /// alternatable
         percentThisTravelled: Double = 0,
         travelDistanceFromVenueInMeters: Double? = nil,
        /// alternatable
         minutesAway: Int? = nil,
        /// alternatable
         travelMethod: TravelMethod? = nil,
         withinRangeOfEachOtherAndMeetPlace: Int? = nil,
         matchMakingMethodVersion: Double? = nil,
        /// alternatable
         estimatedTravelTimeInMinutes: Int? = nil,
         rangeThreshold: Int = 0,
         meetingTime: Date? = nil
     ) {
         self.otherUser = otherUser
         self.greetID = greetID
         self.method = method
         self.compatitibility = compatitibility
         self.openers = openers
         self.venue = venue
         self.isMrPractice = isMrPractice
         self.thisSettings = thisSettings
         self.percentThisTravelled = percentThisTravelled
         self.travelDistanceFromVenueInMeters = travelDistanceFromVenueInMeters
         self.otherUserTravelMinutesAwayFromVenue = minutesAway
         self.travelMethod = travelMethod
         self.withinRangeOfEachOtherAndMeetPlace = withinRangeOfEachOtherAndMeetPlace
         self.matchMakingMethodVersion = matchMakingMethodVersion
         self.travelMinutesToVenue = estimatedTravelTimeInMinutes
         self.rangeThreshold = rangeThreshold
         self.meetingTime = meetingTime
     }

    public var meetInXMinutes: Int? {
        guard let travelMinutesToVenue else { return nil }
        guard let otherUserTravelMinutesAwayFromVenue else { return nil }
        return max(
            (travelMinutesToVenue + 5 /*buffer*/ + (validProposals.first ?? 0)),
            (otherUserTravelMinutesAwayFromVenue + 5 /*buffer*/ + (validProposals.first ?? 0))
        )
    }
    
    public var agreedTime: Int? {
        guard let otherUserSettings = otherUser.settings else { return nil }
        return thisSettings.agreedTimeProposals.filter({ !otherUserSettings.rejectedTimeProposals.contains($0) && otherUserSettings.agreedTimeProposals.contains($0) }).first
    }
        
    public var isWaiting: Bool {
        let proposals = thisSettings.agreedTimeProposals
        guard let rejectedProposals = otherUser.settings?.rejectedTimeProposals else { return false }
        return !proposals.filter { !rejectedProposals.contains($0) }.isEmpty
    }
    
    public var viewForProposal: ViewSetting {
        guard let newProposals = otherUser.settings?.agreedTimeProposals.filter({ !thisSettings.rejectedTimeProposals.contains($0) && $0 != 0 }),
            let firstNewProposal = newProposals.first else { return .start }
        return .otherAskedIfCanMeetLater(firstNewProposal)
    }
    
    public var withinRange: Bool {
        if let withinRange = withinRangeOfEachOtherAndMeetPlace {
            return withinRange < rangeThreshold
        }
        return false
    }
    
    public var otherUserIsEligibleToMeet: Bool {
        if let otherStatus = otherUser.settings?.status {
            return otherStatus != .rejectedOther
                && otherStatus != .exceededRange
        } else {
            return false
        }
    }
    
    // MARK - updates
    
    public mutating func update(with new: Greet) -> Greet.Update? {
        let rejectedTime = rejectedProposal(from: new)
        venue = new.venue
        otherUser = new.otherUser
        thisSettings.updateSettings(with: otherUser.settings)
        withinRangeOfEachOtherAndMeetPlace = new.withinRangeOfEachOtherAndMeetPlace
        
        if thisSettings.status == .enroute && otherUser.settings?.status == .viewed {
            otherUser.settings?.status = .enroute
        }

        if !validProposals.isEmpty {
            otherUser.settings?.status = .enroute
            thisSettings.status = .enroute
        }

        return Greet.Update(
            this: thisSettings.status,
            otherUser: otherUser.settings?.status,
            withinRange: withinRange,
            rejectedProposal: rejectedTime,
            viewForProposal: viewForProposal,
            otherUserName: otherUser.personal.name
        )
    }

    public var validProposals: [Int] {
        thisSettings
            .agreedTimeProposals
            .filter({ otherUser.settings?.agreedTimeProposals.contains($0) == true })
            .filter({ otherUser.settings?.rejectedTimeProposals.contains($0) != true && thisSettings.rejectedTimeProposals.contains($0) != true })
    }

    // Reject

    public func rejectedProposal(from new: Greet) -> Int? {
        guard let oldRejectedTimeProposals = otherUser.settings?.rejectedTimeProposals,
              let updatedRejectedTimeProposals =  new.otherUser.settings?.rejectedTimeProposals else {
            return nil
        }
        return updatedRejectedTimeProposals.first { !oldRejectedTimeProposals.contains($0) }
    }

    public mutating func mrPracticeDidReject() -> Bool? {
        if !isMrPractice {return nil}
        return arc4random_uniform(4) == 0
    }
    
    public init(otherUser: Greet.User, greetID: UUID) {
        self.otherUser = otherUser
        self.greetID = greetID
    }

    public var estimatedMeetTime: String {
        guard let meetInXMinutes else { return "unknown" }
        return Date(timeFromNow: meetInXMinutes)?.clockTime ?? "unknown"
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
