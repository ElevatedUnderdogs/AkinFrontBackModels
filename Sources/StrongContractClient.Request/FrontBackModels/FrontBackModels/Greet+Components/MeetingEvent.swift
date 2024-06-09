//
//  GreetModels.swift
//  akin
//
//  Created by Scott Lydon on 3/25/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

extension Greet {

    public struct MeetingEvent: Codable {

        public var meetInXMinutes: Int = 0
        public var halfwayPoint: Location
        public var business: Business? = nil

        public init(halfway: Location) {
            self.halfwayPoint = halfway
        }
    }
}
