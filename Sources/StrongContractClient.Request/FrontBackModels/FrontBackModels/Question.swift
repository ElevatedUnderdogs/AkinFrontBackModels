//
//  Question.swift
//  akin
//
//  Created by apple on 5/13/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public typealias QuestionAction = (Question) -> Void

public struct Question: Codable, Equatable, Hashable {

    // MARK - Types
    
    public enum Category: String, CaseIterable, Codable {
        case not_answered, answered, all, created
    }
    
    public static func == (lhs: Question, rhs: Question) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK - stored properties
    
    public var requirementsFor: [Context: [Response.Selections.MyTheir]] = [:] // codable
    public var text: String
    public var responses: [Response] = [] // Codable
    public var id: UUID
    public var creatorID: String

    /// Keep in mind the instances of these models in this package are customized for each user.
    public var importanceFor: [ContextID: Importance] = [:] // Codable

    /// The popularity of this question in each context.
    public var contextPopularity: [ContextID: PopularityScore] = [:] // Codable
    public var originalContext: Context
    
    // MARK - computed properties
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public func responses(containing searchText: String) -> [Response] {
        responses.filter {  $0.text.lowercased().contains(searchText.lowercased()) }
    }
    
    // MARK - initializers

    public init(
        parts: Parts,
        id: UUID
    ) {
        self.text = parts.text
        assertionFailure("the id needs to be adjusted when we learn more about the context")
        self.responses = parts.responses.map {
            Question.Response(
                id: .init(),
                addResponse: AddResponse(response: $0, questionID: id)
            )
        }
        self.id = id
        self.creatorID = parts.creatorID
        self.originalContext = parts.originalContext
    }
}


extension Question {

    public struct Parts: Codable, Equatable, Hashable {
        var text: String
        var responses: [Response.Parts] = []
        var creatorID: String
        var originalContext: Context

        public func hash(into hasher: inout Hasher) {
            hasher.combine(text)
        }

        public init(
            text: String,
            responses: [Response.Parts],
            creatorID: String,
            originalContext: Context
        ) {
            self.text = text
            self.responses = responses
            self.creatorID = creatorID
            self.originalContext = originalContext
        }
    }
}
