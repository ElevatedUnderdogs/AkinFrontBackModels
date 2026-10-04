//
//  MatchmakingProfileSummary.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP28 item 1.3. One matchmaking profile, as it crosses the wire.
//
//  This type was declared TWICE before this file existed: as `MatchmakingProfileSummary` in
//  akin/Flows/Social/SocialDTOs.swift and as `MatchmakingProfileDTO` in
//  akin-server-side/Sources/App/Matchmaking/ProfileService.swift. The two happened to agree
//  field for field, which is the part worth noticing: they agreed by coincidence and by care,
//  not by construction, and nothing would have said anything the first time one of them moved.
//
//  The package already carried `MatchmakingProfile` with six of these seven fields, and both
//  sides declared their own variant anyway. A shared package that the two sides route around
//  is not a contract, so the wire shape lives here now and the two local declarations are
//  gone.
//
//  Why this is SEPARATE from `MatchmakingProfile` rather than replacing it. That type is the
//  full record, with `ownerId` non optional because a stored profile always has an owner. This
//  is what a READER is told, where the owner is disclosed only to the owner, so `ownerId` is
//  optional by design. Collapsing them would force every reader of the full record to unwrap a
//  field that is never absent there.
//

import Foundation

/// One matchmaking profile, as a reader is told about it.
public struct MatchmakingProfileSummary: Codable, Hashable, Sendable, Identifiable {

    public let id: UUID

    /// Present only to the owner.
    ///
    /// Every profile route is owner scoped today, so in practice it is always present. The
    /// type does not rely on that: "this endpoint is owner only" is a fact about today's route
    /// table, and an optional is what keeps the payload honest after somebody adds tomorrow's.
    public let ownerId: UUID?

    public let contextId: UUID

    public let name: String

    public let isActive: Bool

    public let isDefault: Bool

    /// When the profile was made.
    ///
    /// Read and written through `JSONDecoder.akinWire` and `JSONEncoder.akinWire`. This field
    /// is the one that produced note B17-01: the server wrote it with fractional seconds and
    /// the app decoded with a strategy that refused them, so the whole reply failed and a
    /// member got a black screen with one red box on it.
    public let createdAt: Date

    public init(
        id: UUID,
        ownerId: UUID?,
        contextId: UUID,
        name: String,
        isActive: Bool,
        isDefault: Bool,
        createdAt: Date
    ) {
        self.id = id
        self.ownerId = ownerId
        self.contextId = contextId
        self.name = name
        self.isActive = isActive
        self.isDefault = isDefault
        self.createdAt = createdAt
    }
}
