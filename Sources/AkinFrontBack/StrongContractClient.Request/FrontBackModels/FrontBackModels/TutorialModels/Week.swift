//
//  Week.swift
//  akin
//
//  Created by Scott Lydon on 4/2/24.
//  Copyright © 2024 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public struct Week: Codable {
    public var monday, tuesday, wednesday, thursday, friday, saturday, sunday: Day

    public init(
        monday: Day,
        tuesday: Day,
        wednesday: Day,
        thursday: Day,
        friday: Day,
        saturday: Day,
        sunday: Day
    ) {
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
    }
}
