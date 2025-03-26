//
//  Week.Day.Hour.swift
//  akin
//
//  Created by Scott Lydon on 4/2/24.
//  Copyright © 2024 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Week.Day {

    public struct Hour: Codable {

        public let militaryHour: Int
        public let amPM: AMPM
        public var travelMethod: TravelMethod

        public var standardHour: Int {
            militaryHour % 12 == 0 ? 12 : militaryHour % 12
        }

        public init(militaryHour: Int, amPM: AMPM, travelMethod: TravelMethod) {
            self.militaryHour = militaryHour
            self.amPM = amPM
            self.travelMethod = travelMethod
        }
    }
}
