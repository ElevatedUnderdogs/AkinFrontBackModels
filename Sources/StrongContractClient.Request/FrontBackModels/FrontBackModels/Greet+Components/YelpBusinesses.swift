//
//  YelpBusinesses.swift
//  akin
//
//  Created by Scott Lydon on 3/28/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public enum Yelp {}

extension Yelp {

    public struct Business: Codable {
        public struct Category {
            public let alias: String
            public let title: String
        }
        public var alias: String? = nil
        public var coordinate: Location? = nil
        public var location: Yelp.Business.Location? = nil
        public var name: String? = nil
    }
}

extension Yelp.Business {
    
    public struct Location: Codable {
        public var displayAddress: [String]
    }
}
