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

    public func age(currentDate: Date = Date()) -> Int {
        Calendar.current.dateComponents([.year], from: self, to: currentDate).year ?? 0
    }

    var birthdayReadable: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy" // Example: "January 5, 1993"
        return formatter.string(from: self)
    }
}
