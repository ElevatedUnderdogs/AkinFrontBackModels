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

    /// If nil, this means the location hasn't been updated.
    public let lastLocationUpdate: Date?

    /// Whether the other user has granted CallKit (VoIP calling) consent.
    /// When `false`, the call button should be hidden for this user.
    public var hasGrantedCallKitConsent: Bool

    public init(
        id: UUID,
        name: String,
        profileImage: String,
        imageMetaData: ImageMetadata,
        verified: Bool = false,
        lastLocationUpdate: Date? = nil,
        hasGrantedCallKitConsent: Bool = false
    ) {
        self.id = id
        self.name = name
        self.profileImage = profileImage
        self.verified = verified
        self.imageMetaData = imageMetaData
        self.lastLocationUpdate = lastLocationUpdate
        self.hasGrantedCallKitConsent = hasGrantedCallKitConsent
    }

    /// Custom decoder to remain backward-compatible with server payloads that predate
    /// the `hasGrantedCallKitConsent` field.  Any JSON missing that key decodes to `false`
    /// rather than throwing `keyNotFound`.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        profileImage = try container.decode(String.self, forKey: .profileImage)
        imageMetaData = try container.decode(ImageMetadata.self, forKey: .imageMetaData)
        verified = try container.decodeIfPresent(Bool.self, forKey: .verified) ?? false
        lastLocationUpdate = try container.decodeIfPresent(Date.self, forKey: .lastLocationUpdate)
        hasGrantedCallKitConsent = try container.decodeIfPresent(Bool.self, forKey: .hasGrantedCallKitConsent) ?? false
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
