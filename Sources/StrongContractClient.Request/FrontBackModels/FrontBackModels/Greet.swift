//
//  Greet.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation
import CommonExtensions

public typealias CompatibilityContext = String
public typealias CompatibilityScore = Double

public struct Greet: Codable {

    // MARK - properties
    
    public var otherUser: Greet.User
    public var greetID: String
    
    public var method: Greet.Method = .wave
    public var compatitibility: [CompatibilityContext: CompatibilityScore] = [:]
    public var openers: [String] = []
    public var meetingEvent: MeetingEvent? = nil
    public var isMrPractice: Bool = false
    public var thisSettings = Settings(status: .viewed)
    public var percentThisTravelled: Double = 0
    public var minutesAway: Int? = nil
    public var travelMethod: TravelMethod? = nil
    public var withinRangeOfEachOtherAndMeetPlace: Int? = nil
    public var matchMakingMethodVersion: Double? = nil
    public var estimatedTravelTimeInMinutes: Int? = nil
    
    public var meetInXMinutes: Int? {
        guard let estimatedTravelTime = estimatedTravelTimeInMinutes else { return nil }
        return estimatedTravelTime + (agreedTime ?? 0)
    }
    
    public var agreedTime: Int? {
        guard let otherUserSettings = otherUser.settings else { return nil }
        return thisSettings.agreedTimeProposals.filter({ !otherUserSettings.rejectedTimeProposals.contains($0) && otherUserSettings.agreedTimeProposals.contains($0) }).first
    }
    
    public var rangeThreshold: Int = 0
    
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
        meetingEvent = new.meetingEvent
        otherUser = new.otherUser
        thisSettings.updateSettings(with: otherUser.settings)
        withinRangeOfEachOtherAndMeetPlace = new.withinRangeOfEachOtherAndMeetPlace
        
        if thisSettings.status == .enroute && otherUser.settings?.status == .viewed {
            otherUser.settings?.status = .enroute
        }
        
        return Greet.Update(
            this: thisSettings.status,
            otherUser: otherUser.settings?.status,
            withinRange: withinRange,
            rejectedProposal: rejectedTime,
            viewForProposal: viewForProposal,
            otherUserName: otherUser.name
        )
    }
    
    // Reject
    
    public func rejectedProposal(from new: Greet) -> Int? {
        if let oldRejectedTimeProposals = otherUser.settings?.rejectedTimeProposals,
            let newRejectedTimeProposals =  new.otherUser.settings?.rejectedTimeProposals {
            let differentProposals = newRejectedTimeProposals.filter { !oldRejectedTimeProposals.contains($0) }
            if let first = differentProposals.first {
                return first
            }
        }
        return nil
    }
    
    public mutating func mrPracticeDidReject() -> Bool? {
        if !isMrPractice {return nil}
        return arc4random_uniform(4) == 0
    }
    
    public init(otherUser: Greet.User, greetID: String) {
        self.otherUser = otherUser
        self.greetID = greetID
    }

    var estimatedMeetTime: String {
        guard let minutes = meetInXMinutes else { return "unknown" }
        return Date(timeFromNow: minutes)?.clockTime ?? "unknown"
    }
}
