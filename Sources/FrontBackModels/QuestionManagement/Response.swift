//
//  Response.swift
//  akin
//
//  Created by apple on 5/13/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public typealias ContextRawValue = String
public typealias PopularityScore = Int
public typealias ContextAction = (Context) -> Void

extension Question {
    
    public struct Response: Equatable, Codable {

        public static func == (lhs: Response, rhs: Response) -> Bool {
            lhs.id == rhs.id
        }

        public var text: String = ""
        public var timeStamp: Date
        
        public var id: UUID

        /// The id of the user that created the response.
        /// Who wrote this response, present only when they are disclosed (swath N3, finding B1).
        ///
        /// Optional for the same reason `Question.creatorID` is. While it was non optional every
        /// serializer had to invent a value for the undisclosed case, and the two that existed
        /// invented different ones: one published the real author, the other a fresh random UUID.
        /// The first was a leak and the second was fabricated data presented as an identifier.
        public var creator: UUID?

        public var questionID: UUID

        public var myChoice: [ContextRawValue: Selections.MyTheir.Choice] = [:]
        public var theirChoices: [ContextRawValue: Selections.MyTheir.Choice] = [:]
        public var popularity: [ContextRawValue: PopularityScore] = [:]

        public var originalContextID: UUID

        public var assessment: ModerationAssessment

        /// Whether this response's author is disclosed (GOAL_LOOP14 F7.3).
        ///
        /// A response's author is not the question's author, so it needs its own answer. Before
        /// this field there was none, and the read path could only name the author to themselves,
        /// which meant a member who WANTED their name on a response could not have it.
        ///
        /// Optional for the same compatibility reason as `Question.authorVisibility`: Swift's
        /// synthesized `init(from:)` does not consult a property's default, so a non optional
        /// field here would make every already-shipped client, which sends no such key, fail to
        /// post a response at all. Absent means the member did not choose, and the server stores
        /// its own default.
        public var authorVisibility: AuthorVisibility?

        /// Who wrote it, ready to draw, present only when they are disclosed
        /// (GOAL_LOOP14 F1.2).
        ///
        /// `creator` above answers "may this author be named". This answers
        /// "what is their name". The invariant is that this is nil whenever
        /// `creator` is nil: a name without the id that authorised it would be
        /// a disclosure nobody gated.
        public var author: AuthorSummary?

        /// This initializer isn't synthesized when Codable is conformed to.
        public init(
            text: String,
            timeStamp: Date,
            id: UUID,
            creator: UUID?,
            questionID: UUID,
            myChoice: [ContextRawValue : Selections.MyTheir.Choice] = [:],
            theirChoices: [ContextRawValue : Selections.MyTheir.Choice] = [:],
            popularity: [ContextRawValue : PopularityScore] = [:],
            originalContextID: UUID,
            assessment: ModerationAssessment,
            authorVisibility: AuthorVisibility? = nil,
            author: AuthorSummary? = nil
        ) {
            self.text = text
            self.timeStamp = timeStamp
            self.id = id
            self.creator = creator
            self.questionID = questionID
            self.myChoice = myChoice
            self.theirChoices = theirChoices
            self.popularity = popularity
            self.originalContextID = originalContextID
            self.assessment = assessment
            self.authorVisibility = authorVisibility
            self.author = author
        }

        /// Performs a full field-by-field comparison of all properties.
        public func deepEquals(_ other: Question.Response) -> Bool {
            return self.id == other.id &&
            self.text == other.text &&
            self.timeStamp == other.timeStamp &&
            self.creator == other.creator &&
            self.questionID == other.questionID &&
            self.myChoice == other.myChoice &&
            self.theirChoices == other.theirChoices &&
            self.popularity == other.popularity &&
            self.originalContextID == other.originalContextID
        }

        public func has(
            _ myTheir: Selections.MyTheir,
            for contextRawValue: ContextRawValue
        ) -> Bool {
            switch myTheir {
            case .my:
                return myChoice[contextRawValue] == .YES || myChoice[contextRawValue] == .NO
            case .their:
                return theirChoices[contextRawValue] == .YES || theirChoices[contextRawValue] == .NO
            }
        }
        
        public mutating func set(
            _ myTheir: Selections.MyTheir,
            _ choice: Selections.MyTheir.Choice,
            for context: Context
        ) {
            switch myTheir {
            case .my: myChoice[context.rawValue] = choice
            case .their: theirChoices[context.rawValue] = choice
            }
        }
        
        public func choice(
            for myTheir: Selections.MyTheir,
            _ context: Context
        ) -> Selections.MyTheir.Choice? {
            switch myTheir {
            case .my: return myChoice[context.rawValue]
            case .their: return theirChoices[context.rawValue]
            }
        }
    }
}
