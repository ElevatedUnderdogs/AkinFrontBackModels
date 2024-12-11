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

        public enum AMPM: String, Codable {
            case am, pm
        }

        // Custom CodingKeys to exclude btn and img from Codable operations
        public enum CodingKeys: String, CodingKey {
            case count
            case amPM
            case travelMethod
        }

        public let count: Int
        public let amPM: AMPM // Codable
        public var travelMethod: TravelMethod // Codable


        public init(count: Int, amPM: AMPM, travelMethod: TravelMethod) {
            self.count = count
            self.amPM = amPM
            self.travelMethod = travelMethod
        }
    }
}
