//
//  DeleteOwnQuestion.swift
//  AkinFrontBackModels
//
//  2026-10-21. A member deletes a question they asked. Before this nothing could delete a
//  question, so a UI test that asked one in production could not remove it in its own tearDown
//  and test questions piled up in front of members' real ones.
//

import Foundation
import StrongContractClient

/// The question to delete. The caller is the bearer token's member; only its author may delete it.
public struct DeleteOwnQuestionPayload: Codable, Hashable, Equatable, Sendable {
    public let questionID: UUID

    public init(questionID: UUID) {
        self.questionID = questionID
    }
}

public typealias DeleteOwnQuestionRequest = Request<DeleteOwnQuestionPayload, StandardPostResponse>
extension DeleteOwnQuestionRequest {

    /// Purpose: delete one of the caller's own questions. Refused (403) for anybody but the author,
    /// and (409) once another member has answered it, because their answers are theirs.
    public static var deleteOwnQuestion: Self {
        .init(method: .post)
    }
}
