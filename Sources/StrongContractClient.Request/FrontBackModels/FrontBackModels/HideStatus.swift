//
//  File.swift
//  
//
//  Created by Scott Lydon on 6/26/24.
//

import Foundation

/// If the user doesn't want to be eligible for meetups, they cannot be eligible for showing
/// in the nearby list as this could be seen as teasing/frustrating people.
public enum HideStatus: String, Codable, CaseIterable, Equatable, Hashable {

    /// This user is eligible to meetup but doesn't want to be shown in nearby lists.
    case hiddenFromNearbyList

    /// This person is both ineligible for meetups and isn't shown in nearby lists.
    case hidden

    /// This person shows in both nearby lists and is eligible for meetups.
    case showing

    public var showsInNearbyList: Bool {
        self != .showing
    }

    public var eligibleForMeetup: Bool {
        self != .hidden
    }
}
