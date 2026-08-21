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
        // Consider removing created because these statuses aren't mulually exclusive,
        // for example there can be questions created by this user in the not answered,
        // answered and all.  This category though is mostly used for making requests to the
        // server and secondarily to for the client presentation. 
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
    public var assessment: ModerationAssessment

    /// Who, if anyone, the creator wants this question attributed to (swath N3, item 6.3).
    ///
    /// Optional, and that is about compatibility rather than about meaning. Swift's synthesized
    /// `init(from:)` does not consult a property's default value, so a non optional field here
    /// would make every already-shipped client, which sends no such key, fail to post a question
    /// at all. Absent means the creator did not choose, and the server stores `silent`, which is
    /// what every question in the system already meant.
    public var authorVisibility: AuthorVisibility?

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
        defaultCompatibilityRule: CompatibilityRule,
        assessment: ModerationAssessment,
        authorVisibility: AuthorVisibility? = nil
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
        self.assessment = assessment
        self.authorVisibility = authorVisibility
    }

    func isDeepEqual(to other: Question) -> Bool {
        return self.id == other.id &&
        self.text == other.text &&
        self.responses == other.responses &&
        self.creatorID == other.creatorID &&
        self.defaultCompatibilityRule == other.defaultCompatibilityRule &&
        self.importanceFor == other.importanceFor &&
        self.contextPopularity == other.contextPopularity &&
        self.originalContext == other.originalContext &&
        self.requirementsFor == other.requirementsFor
    }
}
