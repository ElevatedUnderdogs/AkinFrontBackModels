//
//  ExitReason.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Greet.Update {
    
    public enum ExitReason: Equatable, Codable {

        case exceededRange(Question.Response.Selections.MyTheir)
        case rejected(Question.Response.Selections.MyTheir)
        case thisConfirmedMet
        
        public static func == (lhs: ExitReason, rhs: ExitReason) -> Bool {
            switch (lhs, rhs) {
            case (.exceededRange(let myTheir1), .exceededRange(let myTheir2)):
                return myTheir1 == myTheir2
            case (.rejected(let myTheir1), .rejected(let myTheir2)):
                return myTheir1 == myTheir2
            case (.thisConfirmedMet, .thisConfirmedMet):
                return true
            default:
                return false
            }
        }
    }
}
