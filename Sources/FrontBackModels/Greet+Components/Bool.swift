//
//  File 2.swift
//  
//
//  Created by Scott Lydon on 4/2/24.
//

import Foundation

extension Bool {
    public var strInt: String {
        "\(int)"
    }

    ///Returns 1 if true, 0 if false
    public var int: Int {
        self ? 1 : 0
    }

    // This can be used to add debug statements.
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
