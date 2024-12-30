//
//  File.swift
//  
//
//  Created by Scott Lydon on 4/2/24.
//

import Foundation

extension Date {
    public var apiString: String {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd HH:mm:ss"
        df.timeZone = TimeZone(identifier: "GMT")
        return df.string(from: self)
    }
    
    /// Generates a date earlier by a random number of seconds between 0.0001 and 10.0000 seconds.
    var randomEarlierDate: Date {
        // Use the random seconds from the TimeInterval extension
        addingTimeInterval(-.randomSeconds)
    }
}

extension TimeInterval {
    /// Generates a random `TimeInterval` between 0.0001 and 10.0000 seconds.
    static var randomSeconds: TimeInterval {
        // Generate a random number within the desired range
        Double.random(in: 0.0001...10.0000)
    }
}
