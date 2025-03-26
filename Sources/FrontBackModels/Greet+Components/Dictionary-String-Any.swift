//
//  File.swift
//  
//
//  Created by Scott Lydon on 4/2/24.
//

import Foundation

extension Dictionary where Key == String, Value == Any {

    public var databaseTimeLapse: Float? {
        self["databaseTimeLapse"] as? Float
    }

    public var serversideOnlyTimeLapse: Float? {
        self["serversideOnlyTimeLapse"] as? Float
    }

    public func value<T>(for key: String) -> T? {
        self[key] as? T
    }
}
