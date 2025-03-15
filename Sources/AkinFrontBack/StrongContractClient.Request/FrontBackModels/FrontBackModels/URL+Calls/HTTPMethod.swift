//
//  File.swift
//  
//
//  Created by Scott Lydon on 4/5/24.
//

import Foundation

/// Represents the HTTP methods, providing a guide on when to use each.
public enum HTTPMethod: String, Codable {
    /// The `GET` method requests a representation of the specified resource. Requests using GET should only retrieve data.
    case get = "GET"

    /// The `POST` method is used to submit an entity to the specified resource, often causing a change in state or side effects on the server.
    /// side effects beyond the database state change, such as initiating push notifications, logging, or other internal processes to manage alerts. The POST method is well-suited for operations that result in side effects on the server.
    case post = "POST"

    /// The `PUT` method replaces all current representations of the target resource with the request payload.
    case put = "PUT"

    /// The `DELETE` method deletes the specified resource.
    case delete = "DELETE"

    /// The `PATCH` method is used to apply partial modifications to a resource.
    case patch = "PATCH"

    /// The `HEAD` method asks for a response identical to that of a GET request, but without the response body.
    case head = "HEAD"
}
