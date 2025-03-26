//
//  Selections.swift
//  akin
//
//  Created by Scott Lydon on 8/5/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Question.Response {
    
    public struct Selections: Codable {
        public var my: MyTheir.Choice, their: MyTheir.Choice
        
        public init(my: MyTheir.Choice = .empty, their: MyTheir.Choice = .empty) {
            self.my = my
            self.their = their
        }
    }
}
