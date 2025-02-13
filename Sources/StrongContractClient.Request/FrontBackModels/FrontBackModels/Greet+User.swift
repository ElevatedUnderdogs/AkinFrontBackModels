//
//  Greet.User.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Greet {

    public struct User: Codable, Equatable, Hashable {
        public var personal: NearbyUser
        public var percentTravelled: Double? = nil
        public var image: Data? = nil
        public var minutesFromPoint: Int? = nil
        public var settings: Greet.Settings? = nil


        /// <#Description#>
        /// - Parameters:
        ///   - nearbyUser: <#nearbyUser description#>
        ///   - percentTravelled: <#percentTravelled description#>
        ///   - image: <#image description#>
        ///   - minutesFromPoint: Is this supposed to be minutes away from a central meeting location or minutes away from the other user.
        ///   I think this solves a problem I was having.  I was worried about people triangulating exact locations of people, however, if instead
        ///   of showing how near someone is to someone else, perhaps I can
        ///   - settings: <#settings description#>
        public init(
            nearbyUser: NearbyUser,
            percentTravelled: Double? = nil,
            image: Data? = nil,
            minutesFromPoint: Int? = nil,
            settings: Greet.Settings? = nil
        ) {
            self.personal = nearbyUser
            self.percentTravelled = percentTravelled
            self.image = image
            self.minutesFromPoint = minutesFromPoint
            self.settings = settings
        }
    }
}
