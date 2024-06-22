//
//  YelpBusinesses.swift
//  akin
//
//  Created by Scott Lydon on 3/28/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

// https://docs.developer.yelp.com/docs/fusion-intro

// MARK: - Yelp
public struct Yelp: Codable {
    public let total: Int
    public let businesses: [Business]
}

// MARK: - Business
public struct Business: Codable {
    public let rating: Double
    public let price, phone, id: String
    public let categories: [Category]
    public let reviewCount: Int
    public let name: String
    public let url: String
    public let coordinates: Coordinates
    public let imageURL: String
    public let location: Location

    var venue: Venue {
        Venue(
            url: url,
            name: name,
            address: location.displayAddress,
            latitude: coordinates.latitude,
            longitude: coordinates.longitude
        )
    }

    enum CodingKeys: String, CodingKey {
        case rating, price, phone, id, categories
        case reviewCount = "review_count"
        case name, url, coordinates
        case imageURL = "image_url"
        case location
    }
}

// MARK: - Category
public struct Category: Codable {
    public let alias, title: String
}

// MARK: - Coordinates
public struct Coordinates: Codable {
    public let latitude, longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - Location
public struct Location: Codable {
    public let city, country, address2, address3: String
    public let state, address1, zipCode: String

    enum CodingKeys: String, CodingKey {
        case city, country, address2, address3, state, address1
        case zipCode = "zip_code"
    }

    // Computed property to get the display address
    public var displayAddress: String {
        var addressComponents: [String] = []

        if !address1.isEmpty { addressComponents.append(address1) }
        if !address2.isEmpty { addressComponents.append(address2) }
        if !address3.isEmpty { addressComponents.append(address3) }
        if !city.isEmpty { addressComponents.append(city) }
        if !state.isEmpty { addressComponents.append(state) }
        if !zipCode.isEmpty { addressComponents.append(zipCode) }
        if !country.isEmpty { addressComponents.append(country) }

        return addressComponents.joined(separator: ", ")
    }
}
