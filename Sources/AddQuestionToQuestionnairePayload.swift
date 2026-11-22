//
//  AddQuestionToQuestionnairePayload.swift
//

import Foundation
import StrongContractClient

/// Adding one question to one questionnaire the CALLER created.
///
/// Build 27, B27-09: "single question view three dot buttons should have the option in addition to
/// flag, it can be add question to questionnaire, and then you can add it that way to a
/// questionnaire you created". B27-10 settles whose questions may be added: "Tou can add questions
/// from anyone. It should not be limited to questions you've created."
///
/// SO THE TWO OWNERSHIP RULES ARE DIFFERENT, and that asymmetry is the whole contract. The
/// QUESTIONNAIRE must be the caller's, because adding to somebody else's questionnaire would let
/// any member rewrite a grouping they do not own. The QUESTION need not be: a questionnaire is a
/// grouping of questions worth answering together, and restricting it to the caller's own
/// questions would make a questionnaire a list of things one person wrote rather than a reading
/// list. The caller is never a field here; the server reads them from the verified token.
public struct AddQuestionToQuestionnairePayload: Codable, Hashable, Equatable, Sendable {

    /// The questionnaire to add to. Must be one the caller created.
    public let questionnaireId: UUID

    /// The question to add. May be anybody's.
    public let questionId: UUID

    public init(questionnaireId: UUID, questionId: UUID) {
        self.questionnaireId = questionnaireId
        self.questionId = questionId
    }
}
