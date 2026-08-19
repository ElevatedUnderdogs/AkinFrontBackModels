import Foundation

// Swath A contracts (item 1.9): the cross-platform advertising surface. The creative carries no field
// capable of holding a user identifier: targeting is expressed against an ideal profile and question
// answers, never against a person, and impressions and clicks reference only the campaign.

/// The permitted disclosure strings for a labelled advertisement. A closed enum so a creative cannot
/// ship without a store-policy-compliant label.
public enum AdDisclosureLabel: String, Codable, CaseIterable, Hashable {
    case sponsored = "Sponsored"
    case ad = "Ad"
    case paidPartnership = "Paid partnership"
}

/// The rendered advertisement. Content only: no UUID, no user reference. This is enforced by a
/// compiled test that reflects over the type and rejects any user-identifier-shaped field.
public struct AdCreative: Codable, Hashable {
    public let headline: String
    public let bodyText: String
    public let imageURL: URL?
    public let callToAction: String
    public let disclosure: AdDisclosureLabel

    public init(headline: String, bodyText: String, imageURL: URL?, callToAction: String, disclosure: AdDisclosureLabel) {
        self.headline = headline
        self.bodyText = bodyText
        self.imageURL = imageURL
        self.callToAction = callToAction
        self.disclosure = disclosure
    }
}

/// Who a campaign wants to reach, expressed as a profile shape and answer set, never as identities.
public struct AdTargeting: Codable, Hashable {
    public let questionIDs: [UUID]
    public let idealProfileID: UUID
    public let minProfileMatch: Double

    public init(questionIDs: [UUID], idealProfileID: UUID, minProfileMatch: Double) {
        self.questionIDs = questionIDs
        self.idealProfileID = idealProfileID
        self.minProfileMatch = minProfileMatch
    }
}

/// Where in the feed an ad may appear.
public struct AdPlacement: Codable, Hashable {
    public let slotIndexInFeed: Int
    public init(slotIndexInFeed: Int) { self.slotIndexInFeed = slotIndexInFeed }
}

/// A campaign: its creatives, its targeting, and its placement. The campaign id is a campaign id,
/// never a member id.
public struct AdCampaign: Codable, Hashable, Identifiable {
    public let id: UUID
    public let name: String
    public let targeting: AdTargeting
    public let creatives: [AdCreative]
    public let placement: AdPlacement

    public init(id: UUID, name: String, targeting: AdTargeting, creatives: [AdCreative], placement: AdPlacement) {
        self.id = id
        self.name = name
        self.targeting = targeting
        self.creatives = creatives
        self.placement = placement
    }
}

/// An impression, attributed to the campaign and slot only, so reporting stays aggregate.
public struct AdImpression: Codable, Hashable {
    public let campaignID: UUID
    public let placement: AdPlacement
    public let at: Date
    public init(campaignID: UUID, placement: AdPlacement, at: Date) {
        self.campaignID = campaignID
        self.placement = placement
        self.at = at
    }
}

/// A click, attributed to the campaign and slot only.
public struct AdClick: Codable, Hashable {
    public let campaignID: UUID
    public let placement: AdPlacement
    public let at: Date
    public init(campaignID: UUID, placement: AdPlacement, at: Date) {
        self.campaignID = campaignID
        self.placement = placement
        self.at = at
    }
}
