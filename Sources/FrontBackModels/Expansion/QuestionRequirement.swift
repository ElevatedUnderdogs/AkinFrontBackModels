import Foundation

// Swath Q contract (item 1.6): a required-question filter flavor. One enum so a new flavor cannot
// silently bypass the filter: every consumer must switch exhaustively over these cases.
public enum QuestionRequirement: Codable, Hashable {
    /// The other member must have answered this question at all.
    case mustHaveAnswered(questionID: UUID)
    /// The other member must NOT have chosen any of these responses.
    case mustNotHaveChosen(questionID: UUID, responseIDs: Set<UUID>)
    /// The other member must have chosen at least one of these responses.
    case mustHaveChosenOneOf(questionID: UUID, responseIDs: Set<UUID>)

    /// The question this requirement is about, common to every flavor.
    public var questionID: UUID {
        switch self {
        case let .mustHaveAnswered(q):        return q
        case let .mustNotHaveChosen(q, _):    return q
        case let .mustHaveChosenOneOf(q, _):  return q
        }
    }
}
