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

    /// Whether this member can be greeted right now, from the REQUESTING
    /// viewer's perspective, plus the freeze and reservation state attached to
    /// them.
    ///
    /// Kept as one nested value rather than six flat fields so that the socket
    /// update which refreshes it mid scroll carries exactly the same type the
    /// list fetch delivered. One shape, one decoder, no chance of the two
    /// drifting.
    ///
    /// Defaults to `.legacyDefault`, which is "greetable, unfrozen, no queue",
    /// so a response from a server that predates this field decodes to the
    /// behaviour the app had before the field existed.
    public var interaction: NearbyInteractionState

    public init(
        id: UUID,
        name: String,
        profileImage: String,
        imageMetaData: ImageMetadata,
        verified: Bool = false,
        lastLocationUpdate: Date? = nil,
        hasGrantedCallKitConsent: Bool = false,
        interaction: NearbyInteractionState = .legacyDefault
    ) {
        self.id = id
        self.name = name
        self.profileImage = profileImage
        self.verified = verified
        self.imageMetaData = imageMetaData
        self.lastLocationUpdate = lastLocationUpdate
        self.hasGrantedCallKitConsent = hasGrantedCallKitConsent
        self.interaction = interaction
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
        interaction = try container.decodeIfPresent(NearbyInteractionState.self, forKey: .interaction) ?? .legacyDefault
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
