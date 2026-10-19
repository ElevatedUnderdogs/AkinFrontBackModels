import Foundation

// Swath D contracts (item 1.10): the anonymous market-data product. Answers are aggregate only,
// floored by a minimum cohort size and perturbed by calibrated noise, so no buyer can isolate a
// person. The floor lives here as one constant, revisited in Phase 10 if the product needs a higher k.

/// The smallest cohort an answer may describe. Below this, an answer is refused rather than returned.
public let KAnonymityFloor: Int = 100

/// A named aggregate question against the member base. Detail of the query language is Phase 10's;
/// the contract that travels between client and server is the id and its human description.
public struct MarketQuery: Codable, Hashable, Identifiable {
    public let id: UUID
    public let description: String
    public init(id: UUID, description: String) {
        self.id = id
        self.description = description
    }
}

/// One aggregate answer. It cannot be constructed below the k-anonymity floor: the failable init
/// returns nil, so a too-small cohort can never be packaged into a sellable answer.
public struct MarketAnswer: Codable, Hashable {
    public let value: Double
    public let cohortSize: Int
    public let noiseScale: Double

    public init?(value: Double, cohortSize: Int, noiseScale: Double) {
        guard cohortSize >= KAnonymityFloor else { return nil }
        self.value = value
        self.cohortSize = cohortSize
        self.noiseScale = noiseScale
    }
}

/// A buyer's remaining query allowance, so repeated narrow queries cannot reconstruct rows over time.
public struct QueryBudget: Codable, Hashable {
    public let ceiling: Int
    public let remaining: Int
    public init(ceiling: Int, remaining: Int) {
        self.ceiling = ceiling
        self.remaining = remaining
    }
}
