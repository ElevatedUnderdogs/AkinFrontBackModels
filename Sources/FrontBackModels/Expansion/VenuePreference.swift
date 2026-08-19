import Foundation

// Swath V contracts (item 1.8): venue preferences, blacklists, and negotiation. Venues are keyed by
// the same Google place id string the rest of the venue surface already uses (see VenueByGoogleID).
public typealias VenueID = String

/// A member's standing venue choices for matching and meetups.
public struct VenuePreference: Codable, Hashable {
    public let preferred: [VenueID]
    public let blocked: [VenueID]
    public let negotiationProposal: NegotiationProposal?

    public init(preferred: [VenueID], blocked: [VenueID], negotiationProposal: NegotiationProposal? = nil) {
        self.preferred = preferred
        self.blocked = blocked
        self.negotiationProposal = negotiationProposal
    }
}

/// One member's proposal to meet at a specific venue, which the other can accept or counter.
public struct NegotiationProposal: Codable, Hashable {
    public let proposedVenue: VenueID
    public let alternativeVenues: [VenueID]
    public let note: String?

    public init(proposedVenue: VenueID, alternativeVenues: [VenueID] = [], note: String? = nil) {
        self.proposedVenue = proposedVenue
        self.alternativeVenues = alternativeVenues
        self.note = note
    }
}

/// The honest cost of a blacklist: how many otherwise-eligible matches a preference removes, so the
/// UI can warn before a member narrows themselves into an empty pool.
public struct ExclusionWarning: Codable, Hashable {
    public let excludedMatchCount: Int
    public let excludedFraction: Double
    public let reason: String

    public init(excludedMatchCount: Int, excludedFraction: Double, reason: String) {
        self.excludedMatchCount = excludedMatchCount
        self.excludedFraction = excludedFraction
        self.reason = reason
    }
}
