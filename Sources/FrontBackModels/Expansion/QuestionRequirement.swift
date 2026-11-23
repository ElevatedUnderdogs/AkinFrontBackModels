import Foundation

// Swath Q contract (item 1.6): a required-question filter flavor. One enum so a new flavor cannot
// silently bypass the filter: every consumer must switch exhaustively over these cases.
public enum QuestionRequirement: Codable, Hashable {
    /// Why do we need explicit coding keys when they match what would be synthesized?
    /// In order to give them CaseIterable conformance for schema generators to list every case.
    /// Schema generator: https://github.com/ElevatedUnderdogs/DecodableSchema
    enum CodingKeys: String, CodingKey, CaseIterable {
        case mustHaveAnswered, mustNotHaveChosen, mustHaveChosenOneOf
    }

    /// The other member must have answered this question at all.
    case mustHaveAnswered(questionID: UUID)
    /// The other member must NOT have chosen any of these responses.
    case mustNotHaveChosen(questionID: UUID, responseIDs: Set<UUID>)
    /// The other member must have chosen at least one of these responses.
    case mustHaveChosenOneOf(questionID: UUID, responseIDs: Set<UUID>)

    /// The question this requirement is about, common to every flavor.
    public var questionID: UUID {
        switch self {
        case .mustHaveAnswered(let q):        return q
        case .mustNotHaveChosen(let q, _):    return q
        case .mustHaveChosenOneOf(let q, _):  return q
        }
    }
}
