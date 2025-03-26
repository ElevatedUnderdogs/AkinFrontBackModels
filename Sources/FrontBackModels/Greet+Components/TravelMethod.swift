//
//  TravelMethod.swift
//  akin
//
//  Created by Scott Lydon on 4/2/24.
//  Copyright © 2024 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public enum TravelMethod: String, Codable {
    case bike, car, none, walk, motorcycle, transit

    /// The string used for google places api.
    /// https://developers.google.com/maps/documentation/routes/reference/rest/v2/RouteTravelMode
    public var googlePlaces: SafeTravelMode {
        switch self {
        case .bike: return .bicycle
        case .car: return .drive(routingPreference: .trafficAware)
        case .none, .walk: return .walk
        case .motorcycle: return .twoWheeler(routingPreference: .trafficAware)
        case .transit: return .transit
        }
    }

    public var emoji: String {
        switch self {
        case .bike: return "🚲"
        case .car: return "🚗"
        case .none, .walk: return "👣"
        case .motorcycle: return "🏍️"
        case .transit: return "🚇"
        }
    }
}


/// Represents the travel mode and its optional routing preference for the Google Routes API.
public enum SafeTravelMode {
    /// Driving with an optional routing preference (valid for DRIVE).
    case drive(routingPreference: RoutingPreference?)
    /// Two-wheeler with an optional routing preference (valid for TWO_WHEELER).
    case twoWheeler(routingPreference: RoutingPreference?)
    /// Walking (no routing preference allowed).
    case walk
    /// Bicycle (no routing preference allowed).
    case bicycle
    /// Transit (no routing preference allowed).
    case transit

    /// Represents the routing preference options, only applicable to DRIVE and TWO_WHEELER.
    public enum RoutingPreference {
        /*
         Computes routes without taking live traffic conditions into consideration.
         Suitable when traffic conditions don't matter or are not applicable. Using
         this value produces the lowest latency. Note: For RouteTravelMode DRIVE and
         TWO_WHEELER, the route and duration chosen are based on road network and
         average time-independent traffic conditions, not current road conditions.
         Consequently, routes may include roads that are temporarily closed. Results
         for a given request may vary over time due to changes in the road network,
         updated average traffic conditions, and the distributed nature of the service.
         Results may also vary between nearly-equivalent routes at any time or frequency.
         **/
        case trafficUnaware
        /*
         Calculates routes taking live traffic conditions into consideration. In
         contrast to TRAFFIC_AWARE_OPTIMAL, some optimizations are applied to
         significantly reduce latency.
         **/
        case trafficAware
        /*
         Calculates the routes taking live traffic conditions into consideration,
         without applying most performance optimizations. Using this value produces
         the highest latency.
         **/
        case trafficAwareOptimal

        /// Maps to the API's string value.
        public var apiValue: String {
            switch self {
            case .trafficUnaware: return "TRAFFIC_UNAWARE"
            case .trafficAware: return "TRAFFIC_AWARE"
            case .trafficAwareOptimal: return "TRAFFIC_AWARE_OPTIMAL"
            }
        }
    }

    /// Maps to the API's travelMode string value.
    public var apiValue: String {
        switch self {
        case .drive: return "DRIVE"
        case .twoWheeler: return "TWO_WHEELER"
        case .walk: return "WALK"
        case .bicycle: return "BICYCLE"
        case .transit: return "TRANSIT"
        }
    }

    /// Extracts the routing preference if it exists.
    public var routingPreference: RoutingPreference? {
        switch self {
        case .drive(let pref), .twoWheeler(let pref):
            return pref
        case .walk, .bicycle, .transit:
            return nil
        }
    }
}
