//
//  Greet+LocationCoordinate.swift
//  akin
//
//  Created by Jiten Devlani on 02/07/21.
//  Copyright © 2021 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Greet {
    public struct UserLocationCoordinate: Codable {
        // TODO: - Temporary implementation until we have a final User object ready
        // Should be replaced with the release build
        public struct User: Codable {
            public let id: UUID
//            let accessToken: String
            public init(id: UUID) {
                self.id = id
            }
        }
        public let user: User
        public let latitude: Double
        public let longitude: Double

        public init(user: User, latitude: Double, longitude: Double) {
            self.user = user
            self.latitude = latitude
            self.longitude = longitude
        }
    }
}
