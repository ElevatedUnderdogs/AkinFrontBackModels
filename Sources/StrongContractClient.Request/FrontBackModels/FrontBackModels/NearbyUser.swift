//
//  File.swift
//  
//
//  Created by Scott Lydon on 6/24/24.
//

import Foundation

/// To hold details about nearby users for display.
public struct NearbyUser: Codable, Hashable, Equatable {

    /// IdValue
    public let id: String

    /// Display name of the user.
    public let name: String

    /// Shows an image of the user.
    public var profileImages: [String] = []

    /// Confirms if the user verified their identity.
    public var verified: Bool = false

    public init(
        id: String,
        name: String,
        profileImages: [String],
        verified: Bool = false
    ) {
        self.id = id
        self.name = name
        self.profileImages = profileImages
        self.verified = verified
    }

    public var placeholderGreetUser: Greet.User {
        Greet.User(
            nearbyUser: self,
            percentTravelled: nil,
            image: nil,
            minutesFromPoint: nil,
            settings: nil
        )
    }
}
