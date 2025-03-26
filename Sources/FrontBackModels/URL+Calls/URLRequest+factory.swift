//
//  URLRequest+factory.swift
//  akin
//
//  Created by Scott Lydon on 8/7/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//
//DOCUMENATION https://git.generalassemb.ly/Scottyblades/GreeterEndpoints

import Foundation
#if canImport(FoundationNetworking)
// Provided for `URL` related objects on Linux platforms.
import FoundationNetworking
#endif

extension URLRequest {
    
    static func update(schedule: [Week.Day]) -> URLRequest? {
        do {
            let data = try JSONEncoder().encode(schedule)
            var request = URLRequest(url: URL.updateSchedule!)
            request.httpBody = data
            request.httpMethod = "POST"
            return request
        } catch let error {
            print(error.localizedDescription, "for update schedule")
            return nil
        }
    }
    
    static func update(greet: Greet) -> URLRequest? {
        do {
            let data = try JSONEncoder().encode(greet)
            var request = URLRequest(url: .updateGreet)
            request.httpBody = data
            request.httpMethod = "POST"
            return request
        } catch let error {
            print(error.localizedDescription, "for update greet")
            return nil
        }
    }
    
    static func update(midGreetSettings: Greet.Settings) -> URLRequest? {
        do {
            let data = try JSONEncoder().encode(midGreetSettings)
            var request = URLRequest(url: .updateGreetSettings)
            request.httpMethod = "POST"
            request.httpBody = data
            return request
        } catch let error {
            print(error.localizedDescription, "for update midGreet settings.")
            return nil
        }
    }
    
    static func yelpBusiness(latitude: Double, longitude: Double, apikey: String) -> URLRequest? {
        guard let url = URL.yelpBusiness(latitude: latitude, longitude: longitude) else { return nil }
        var request =  URLRequest(url: url)
        request.setValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    /// Adds/Updates user's location onto the server database.
    /// - Parameters:
    ///   - userId: `User`'s id who's location needs to be updated. Current logged in user's id is the default value.
    ///   - latitude: Latitude of the location coordinate.
    ///   - longitude: Longitude of the location coordinate.
    ///   - contextId: Current context id.
    /// - Returns: New instance of `URLRequest`.
    @inline(__always) static func updateUserLocation(
        userId: UUID?/* = Keychain.thisUserID*/,
        latitude: Double?/* = CLLocationCoordinate2D.thisLocation?.latitude*/,
        longitude: Double?/* = CLLocationCoordinate2D.thisLocation?.longitude*/,
        contextId: String = ""
    ) -> Self? {
        guard let userId = userId, let latitude = latitude, let longitude = longitude else { return nil }
        
        let userLocation = Greet.UserLocationCoordinate(user: Greet.UserLocationCoordinate.User(id: userId), latitude: latitude, longitude: longitude)
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try encoder.encode(userLocation)
            
            var request = URLRequest(url: .updateUserLocation(userId: userId, contextId: contextId))
            request.httpMethod = "PUT"
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            return request
        } catch let error {
            print(error.localizedDescription, "while updating user location.")
            return nil
        }
    }
    
//    /// Adds/Updates user's location onto the server database.
//    /// - Parameters:
//    ///   - userId: `User`'s id who's location needs to be updated. Current logged in user's id is the default value.
//    ///   - contextId: Current context id.
//    /// - Returns: New instance of `URLRequest`.
//    static func updateUserLocation(
//        userId: String?/* = Keychain.thisUserID*/,
//        contextId: String = "",
//        thisLocation: Location
//    ) -> Self? {
//        Self.updateUserLocation(
//            userId: userId,
//            latitude: thisLocation.latitude,
//            longitude: thisLocation.longitude,
//            contextId: contextId
//        )
//    }
}
