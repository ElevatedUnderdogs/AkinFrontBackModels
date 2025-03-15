//
//  File.swift
//  
//
//  Created by Scott Lydon on 6/22/24.
//

import Foundation

public struct Venue: Codable, Hashable, Equatable {
    public let url: String
    public let name: String
    public let address: String
    public let latitude: Double
    public let longitude: Double

    public init(
        url: String,
        name: String,
        address: String,
        latitude: Double,
        longitude: Double
    ) {
        self.url = url
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}
