//
//  GreetingMethod.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

extension Greet {
    
    public enum Method: String, Codable, CaseIterable {
        case handShake = "Hand shake"
        case hug
        case kiss
        case plur
        case highFive = "High Five"
        case wave
        case hook_up = "Hook up"
        case wetWilly = "Wet Willy"
        
        public var displayStr: String {
            switch self {
            case .hug: return "Hug 🤗"
            case .kiss: return "Kiss 😘"
            case .handShake: return "Hand Shake 🤝"
            case .wave: return "Wave 👋"
            case .hook_up: return "Hook up 👉👌"
            case .plur: return "P.L.U.R. ✌️❤️✊🫡"
            case .highFive: return "High Five 🙏"
            case .wetWilly: return "Wet Willy 👉💦👂"
            }
        }
    }
}
