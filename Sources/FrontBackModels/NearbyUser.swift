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
    public let id: UUID

    /// Display name of the user.
    public let name: String

    /// Shows an image of the user.
    public var profileImage: String

    public var imageMetaData: ImageMetadata

    /// Confirms if the user verified their identity.
    public var verified: Bool = false

    public init(
        id: UUID,
        name: String,
        profileImage: String,
        imageMetaData: ImageMetadata,
        verified: Bool = false
    ) {
        self.id = id
        self.name = name
        self.profileImage = profileImage
        self.verified = verified
        self.imageMetaData = imageMetaData
    }

//    public var placeholderGreetUser: NearbyUser {
//        NearbyUser(
//            nearbyUser: self,
//            percentTravelled: nil,
//            imageInfo: nil,
//            minutesFromPoint: nil,
//            settings: nil,
//            id: id
//        )
//    }
}

public struct ProfileImageDetails: Codable {
    public let url: String
    public let metaDataID: UUID

    public init(url: String, metaDataID: UUID) {
        self.url = url
        self.metaDataID = metaDataID
    }
}
