//
//  TravelMethod.swift
//  akin
//
//  Created by Scott Lydon on 4/2/24.
//  Copyright © 2024 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public enum TravelMethod: String, Codable {
    case bike, car, none, walk

    /// The string used for google places api.
    /// https://developers.google.com/maps/documentation/routes/reference/rest/v2/RouteTravelMode
    var googlePlaces: String {
        switch self {
        case .bike: return "BICYCLE"
        case .car: return "DRIVE"
        case .none: return "TRAVEL_MODE_UNSPECIFIED"
        case .walk: return "WALK"
            /*
             TWO_WHEELER    Two-wheeled, motorized vehicle. For example, motorcycle. Note that this differs from the BICYCLE travel mode which covers human-powered mode.
             TRANSIT
             */
        }
    }
}
