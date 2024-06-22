//
//  Response.swift
//  akin
//
//  Created by apple on 5/13/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public typealias ContextID = String
public typealias PopularityScore = Int
public typealias ContextAction = (Context) -> Void

extension Question {
    
    public struct Response: Equatable, Codable {

        public static func == (lhs: Response, rhs: Response) -> Bool {
            lhs.id == rhs.id
        }
        
        public var text: String = ""
        public var id: Int
        public var timeStamp: String

        /// The id of the user that created the response.
        public var creator: Creator

        /// The context the user created the question in.  The question is not limited to the context it was created in.
        /// ie: It may be a question originally intended for friendship, but could be used in the context of romance for
        public var intendedContextID: ContextID

        public var questionID: Int
        
        public var myChoice: [ContextID: Selections.MyTheir.Choice] = [:]
        public var theirChoices: [ContextID: Selections.MyTheir.Choice] = [:]
        public var popularity: [ContextID: PopularityScore] = [:]
        
        public init(
            text: String,
            id: Int = NSUUID().hash,
            timeStamp: String = "",
            creator: Creator,
            intendedContextID: ContextID = "neutral",
            questionID: Int = -1
        ) {
            self.text = text
            self.id = id
            self.timeStamp = timeStamp
            self.creator = creator
            self.intendedContextID = intendedContextID
            self.questionID = questionID
        }

        public func has(_ myTheir: Selections.MyTheir, for contextID: String) -> Bool {
            switch myTheir {
            case .my:
                return myChoice[contextID] == .YES || myChoice[contextID] == .NO
            case .their:
                return theirChoices[contextID] == .YES || theirChoices[contextID] == .NO
            }
        }
        
        public mutating func set(_ myTheir: Selections.MyTheir, _  choice: Selections.MyTheir.Choice, for context: Context) {
            switch myTheir {
            case .my: myChoice[context.rawValue] = choice
            case .their: theirChoices[context.rawValue] = choice
            }
        }
        
        public func choice(for myTheir: Selections.MyTheir, _ context: Context) -> Selections.MyTheir.Choice? {
            switch myTheir {
            case .my: return myChoice[context.rawValue]
            case .their: return theirChoices[context.rawValue]
            }
        }
    }
}
