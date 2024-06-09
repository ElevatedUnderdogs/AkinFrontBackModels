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
    let total: Int
    let businesses: [Business]
}


// MARK: - Business
public struct Business: Codable {
    let rating: Double
    let price, phone, id: String
    let categories: [Category]
    let reviewCount: Int
    let name: String
    let url: String
    let coordinates: Coordinates
    let imageURL: String
    let location: Location

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
    let alias, title: String
}

// MARK: - Coordinates
public struct Coordinates: Codable {
    let latitude, longitude: Double
}

// MARK: - Location
public struct Location: Codable {
    let city, country, address2, address3: String
    let state, address1, zipCode: String

    enum CodingKeys: String, CodingKey {
        case city, country, address2, address3, state, address1
        case zipCode = "zip_code"
    }
}
