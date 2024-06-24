//
//  Greet.User.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Greet {

    public struct User: Codable {
        public var personal: NearbyUser
        public var percentTravelled: Double? = nil
        public var image: Data? = nil
        public var minutesFromPoint: Int? = nil
        public var settings: Greet.Settings? = nil

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
