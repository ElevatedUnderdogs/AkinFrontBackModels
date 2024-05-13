//
//  Location.swift
//
//
//  Created by lsd on 10/05/24.
//

import Foundation

public struct Location: Codable {
    public let latitude: Double
    public let longitude: Double
}

public enum NotificationAuthorizationStatus: Int, Codable {
    case notDetermined = 0, denied, authorized, provisional, ephemeral
}

public enum LocationAuthorizationStatus: Int32, Codable {
    case notDetermined = 0, restricted, denied, authorizedAlways, authorizedWhenInUse
}

extension Location {
    func distance(from: Location, radius: Double = .earthRadius) -> Double {
        let haversine: (Double) -> Double = { (1 - cos($0)) / 2 }
        let ahaversine: (Double) -> Double = { 2 * asin(sqrt($0)) }
        let fromLat = latitude.degreesToRadians
        let fromLon = longitude.degreesToRadians
        let lat = from.latitude.degreesToRadians
        let lon = from.longitude.degreesToRadians
        return radius * ahaversine(haversine(lat - fromLat) + cos(fromLat) * cos(lat) * haversine(lon - fromLon))
    }
}
