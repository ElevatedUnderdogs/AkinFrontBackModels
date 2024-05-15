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
