//
//  Importance.swift
//  akin
//
//  Created by Scott Lydon on 8/5/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Question {
    
    enum Importance: Int, Equatable, Codable {
        
        case irrelevant = 1
        case somewhat = 3
        case very = 9
        
        init?(_ int: Int) {
            switch int {
            case 1: self = .irrelevant
            case 3: self =  .somewhat
            case 9: self =  .very
            default: return nil
            }
        }
        
        init?(_ hasSelections: Bool, _ oldImportance: Importance?) {
            guard let old = oldImportance else {
                if hasSelections {
                    self = .irrelevant
                    return
                } else {
                    return nil
                }
            }
            self = old
        }
    }
}
