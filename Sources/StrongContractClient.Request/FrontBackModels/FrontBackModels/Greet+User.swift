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
        public var id: String
        public var name: String
        public var profileImages: [String] = []
        public var percentTravelled: Double? = nil
        public var image: Data? = nil
        public var minutesFromPoint: Int? = nil
        public var settings: Greet.Settings? = nil
        public var verified: Bool = false
        // var imageUpdatedTo: ImageAction? = nil

        public init(id: String, name: String, profileImages: [String], percentTravelled: Double? = nil, image: Data? = nil, minutesFromPoint: Int? = nil, settings: Greet.Settings? = nil, verified: Bool) {
            self.id = id
            self.name = name
            self.profileImages = profileImages
            self.percentTravelled = percentTravelled
            self.image = image
            self.minutesFromPoint = minutesFromPoint
            self.settings = settings
            self.verified = verified
        }
    }
}
