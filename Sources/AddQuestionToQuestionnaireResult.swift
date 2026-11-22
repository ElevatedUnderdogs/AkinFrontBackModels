//
//  AddQuestionToQuestionnaireResult.swift
//

import Foundation
import StrongContractClient

/// What the caller learns after adding.
///
/// The questionnaire's two counts come back so the confirmation can say what changed without a
/// second round trip, and so a second add of the same question can be told from a first: adding a
/// question already in the questionnaire succeeds and leaves ``questionCount`` where it was,
/// rather than failing. A member who taps add twice has asked for a state, not an operation.
public struct AddQuestionToQuestionnaireResult: Codable, Hashable, Equatable, Sendable {

    /// The questionnaire that was added to.
    public let questionnaireId: UUID

    /// Its title, so the confirmation can name it.
    public let questionnaireTitle: String

    /// How many questions it holds now.
    public let questionCount: Int

    /// Whether this call is what put the question there.
    public let wasAlreadyPresent: Bool

    public init(
        questionnaireId: UUID,
        questionnaireTitle: String,
        questionCount: Int,
        wasAlreadyPresent: Bool
    ) {
        self.questionnaireId = questionnaireId
        self.questionnaireTitle = questionnaireTitle
        self.questionCount = questionCount
        self.wasAlreadyPresent = wasAlreadyPresent
    }
}
