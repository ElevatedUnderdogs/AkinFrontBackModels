//
//  File.swift
//  
//
//  Created by Scott Lydon on 4/2/24.
//

import Foundation

public enum TypeAlternator<Preferred: Codable, Secondary: Codable>: Codable {

    case preferred(Preferred)
    case secondary(Secondary)

    init?(_ preferred: Preferred?, _ secondary: Secondary?) {
        if let preferred = preferred {
            self = .preferred(preferred)
        } else if let secondary = secondary {
            self = .secondary(secondary)
        } else {
            return nil
        }
    }
}
