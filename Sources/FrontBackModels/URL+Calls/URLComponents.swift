//
//  File.swift
//  
//
//  Created by Scott Lydon on 4/3/24.
//

import Foundation
#if canImport(FoundationNetworking)
// Provided for `URL` related objects on Linux platforms.
import FoundationNetworking
#endif

public extension URLComponents {

    /// "http://127.0.0.1:8080/api/"
    /// Same as `localhost`
    static var debug: Self {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "127.0.0.1"
        components.port = 8080
        return components
    }

    /// "https://akindev/api/"
    static var notDebug: Self {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "akindev"
        components.port = 8080
        return components
    }

    static var baseURLComponents: Self {
        EnvConfig.isDebug ? debug : notDebug
    }

    func with(queryItems: URLQueryItem...) -> Self {
        with(array: queryItems)
    }

    func with(array: [URLQueryItem]) -> Self {
        var buffer = self
        buffer.queryItems = buffer.queryItems ?? [] + array
        return buffer
    }

    func with(path: String) -> Self {
        var buffer = self
        buffer.path = "/api/" + path
        return buffer
    }
}
