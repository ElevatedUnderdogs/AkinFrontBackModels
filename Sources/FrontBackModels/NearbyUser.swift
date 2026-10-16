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

    /// How early this member joined, as a band, or nil when they are outside the ranked window.
    ///
    /// TestFlight feedback note B17-15: "I want the early adopter emojis to show on the profile
    /// pictures of different users." Until this field existed, a rank reached exactly one screen,
    /// the viewer's own early adopter row, so the client had nothing to draw on anybody else's
    /// photograph.
    ///
    /// The BAND and not the rank, deliberately. See `EarlyAdopterTier` for the argument: the note
    /// asks for a glyph, an ordinal is more disclosure than that, and a number invites a ranking
    /// nobody designed.
    ///
    /// Optional, and nil is the ordinary answer for most members. It is also what a response from
    /// a server predating this field decodes to, which matters for the whole TestFlight window,
    /// because the app resolves this package at an exact pin and will be newer than the
    /// deployment it talks to. A client reading nil draws no badge, which is the same screen the
    /// app had before the field existed.
    public var earlyAdopterTier: EarlyAdopterTier?

    public init(
        id: UUID,
        name: String,
        profileImage: String,
        imageMetaData: ImageMetadata,
        verified: Bool = false,
        lastLocationUpdate: Date? = nil,
        hasGrantedCallKitConsent: Bool = false,
        interaction: NearbyInteractionState = .legacyDefault,
        earlyAdopterTier: EarlyAdopterTier? = nil
    ) {
        self.id = id
        self.name = name
        self.profileImage = profileImage
        self.verified = verified
        self.imageMetaData = imageMetaData
        self.lastLocationUpdate = lastLocationUpdate
        self.hasGrantedCallKitConsent = hasGrantedCallKitConsent
        self.interaction = interaction
        self.earlyAdopterTier = earlyAdopterTier
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
        // `decodeIfPresent` for the same reason every field above it uses one, and for one more:
        // an UNKNOWN tier string from a future server must not fail the whole decode of a member
        // and take their photograph off the list with it. `try?` swallows that case to nil, which
        // draws no badge.
        earlyAdopterTier = try? container.decodeIfPresent(EarlyAdopterTier.self, forKey: .earlyAdopterTier)
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
