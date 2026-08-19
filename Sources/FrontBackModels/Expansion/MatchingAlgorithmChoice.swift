import Foundation

// Swath M contract (item 1.5): the member-selectable matching algorithm. Modelled as a closed enum
// so a UI picker and the server dispatch cannot drift, and every case carries its own user-facing copy.
public enum MatchingAlgorithmChoice: String, Codable, CaseIterable, Hashable {
    case percentileWeighted
    case latentFactor

    /// Short label for a picker row.
    public var displayName: String {
        switch self {
        case .percentileWeighted: return "Percentile weighted"
        case .latentFactor:       return "Latent factor"
        }
    }

    /// One sentence a member reads before choosing, in plain language, not jargon.
    public var descriptionForUser: String {
        switch self {
        case .percentileWeighted:
            return "Ranks matches by how strongly your most-weighted answers agree, the original Akin method."
        case .latentFactor:
            return "Learns hidden taste patterns across everyone's answers to surface less obvious matches."
        }
    }
}
