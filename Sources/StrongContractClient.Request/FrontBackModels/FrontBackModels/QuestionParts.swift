//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 12/19/24.
//

import Foundation

/// - [x] Add a question - question parts
typealias QuestionsParts = [Question.Parts]

public extension Question {

    /// Adding a response when your question you added hasn't been saved yet, and it isn't known
    ///  - question parts, response parts.
    ///  This also works for Adding a question, or Questions.
    ///  - [ ] Add a question - question parts
    struct Parts: Codable, Equatable, Hashable {
        public var text: String
        public var responses: [Response.Parts] = []
        public var creatorID: UUID
        public var originalContext: String
        public var importanceFor: [ContextRawValue: Importance] = [:]
        public var languageCode: LanguageCodeEnum

        public func hash(into hasher: inout Hasher) {
            hasher.combine(text)
        }

        public init(
            text: String,
            responses: [Response.Parts],
            creatorID: UUID,
            originalContext: String,
            languageCode: LanguageCodeEnum
        ) {
            self.text = text
            self.responses = responses
            self.creatorID = creatorID
            self.originalContext = originalContext
            self.languageCode = languageCode
        }
    }
}
