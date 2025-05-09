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
        public var creator: UUID

        public var questionID: UUID

        public var myChoice: [ContextRawValue: Selections.MyTheir.Choice] = [:]
        public var theirChoices: [ContextRawValue: Selections.MyTheir.Choice] = [:]
        public var popularity: [ContextRawValue: PopularityScore] = [:]

        public var originalContextID: UUID

        /// This initializer isn't synthesized when Codable is conformed to.
        public init(
            text: String,
            timeStamp: Date,
            id: UUID,
            creator: UUID,
            questionID: UUID,
            myChoice: [ContextRawValue : Selections.MyTheir.Choice] = [:],
            theirChoices: [ContextRawValue : Selections.MyTheir.Choice] = [:],
            popularity: [ContextRawValue : PopularityScore] = [:],
            originalContextID: UUID
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
