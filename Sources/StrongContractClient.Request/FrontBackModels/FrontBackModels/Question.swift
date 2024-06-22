//
//  Question.swift
//  akin
//
//  Created by apple on 5/13/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public typealias QuestionAction = ((Question) -> Void)

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
    public var text: String = ""
    public var responses: [Response] = [] // Codable
    public var id: Int?
    public var creatorID: String
    public var importanceFor: [ContextID: Importance] = [:] // Codable
    public var contextPopularity: [ContextID: PopularityScore] = [:] // Codable
    public var originalContext: Context
    
    // MARK - computed properties
    
    public var currentID: Int {
        id ?? -53
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public func responses(containing searchText: String) -> [Response] {
        responses.filter {  $0.text.lowercased().contains(searchText.lowercased()) }
    }
    
    // MARK - initializers


    public init(
        text: String,
        responses: [Response] = [],
        id: Int? = nil,
        creatorID: String,
        originalContext: Context
    ) {
        self.text = text
        self.responses = responses
        self.id = id ?? NSUUID().hash
        self.creatorID = creatorID
        self.originalContext = originalContext
    }
}
