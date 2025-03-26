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
    public var creatorID: UUID
    public var defaultCompatibilityRule: CompatibilityRule

    /// Keep in mind the instances of these models in this package are customized for each user.
    public var importanceFor: [ContextRawValue: Importance] = [:] // Codable

    /// The popularity of this question in each context.
    public var contextPopularity: [ContextRawValue: PopularityScore] = [:] // Codable
    public var originalContext: Context
    
    // MARK - computed properties

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public func responses(containing searchText: String) -> [Response] {
        responses.filter {  $0.text.lowercased().contains(searchText.lowercased()) }
    }

    /// This initializer isn't synthesized when Codable is conformed to.
    public init(
        requirementsFor: [Context : [Response.Selections.MyTheir]] = [:],
        text: String,
        responses: [Response] = [],
        id: UUID,
        creatorID: UUID,
        importanceFor: [ContextRawValue : Importance] = [:],
        contextPopularity: [ContextRawValue : PopularityScore] = [:],
        originalContext: Context,
        defaultCompatibilityRule: CompatibilityRule
    ) {
        self.requirementsFor = requirementsFor
        self.text = text
        self.responses = responses
        self.id = id
        self.creatorID = creatorID
        self.importanceFor = importanceFor
        self.contextPopularity = contextPopularity
        self.originalContext = originalContext
        self.defaultCompatibilityRule = defaultCompatibilityRule
    }
}
