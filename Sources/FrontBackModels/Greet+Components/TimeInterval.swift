//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 3/8/25.
//

import Foundation

extension TimeInterval {
    /// Generates a random `TimeInterval` between 0.0001 and 10.0000 seconds.
    static var randomSeconds: TimeInterval {
        // Generate a random number within the desired range
        Double.random(in: 0.0001...10.0000)
    }
}

