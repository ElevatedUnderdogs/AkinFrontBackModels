import Foundation

// Swath R contracts (item 1.4): semantic redundancy handling. One question's meaning-closeness to
// another, and the families that closeness forms, shared verbatim by iOS, Android, and the server.

/// The cosine similarity between two questions under a named embedding model, at a moment in time.
/// `cosine` is the raw model output; families are derived from it, not stored in place of it.
public struct QuestionSimilarity: Codable, Hashable {
    public let questionA: UUID
    public let questionB: UUID
    public let cosine: Double
    public let model: String
    public let computedAt: Date

    public init(questionA: UUID, questionB: UUID, cosine: Double, model: String, computedAt: Date) {
        self.questionA = questionA
        self.questionB = questionB
        self.cosine = cosine
        self.model = model
        self.computedAt = computedAt
    }
}

/// A cluster of semantically-equivalent questions, labelled by the meaning at its centroid. Members
/// are questions that answer the same underlying thing, so answering one can stand in for the rest.
public struct SemanticFamily: Codable, Hashable, Identifiable {
    public let id: UUID
    public let memberQuestionIDs: [UUID]
    public let centroidLabel: String

    public init(id: UUID, memberQuestionIDs: [UUID], centroidLabel: String) {
        self.id = id
        self.memberQuestionIDs = memberQuestionIDs
        self.centroidLabel = centroidLabel
    }
}
