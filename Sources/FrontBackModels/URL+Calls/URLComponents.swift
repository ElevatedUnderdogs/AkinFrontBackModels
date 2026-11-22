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

extension URLComponents {

    /// "http://127.0.0.1:8080/api/"
    /// Same as `localhost`
    public static var debug: Self {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "127.0.0.1"
        components.port = 8080
        return components
    }

    /// "https://akindev/api/".
    public static var notDebug: Self {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "akindev"
        components.port = 8080
        return components
    }

    /// The server address requests start from: ``debug`` in a debug build, ``notDebug`` otherwise.
    public static var baseURLComponents: Self {
        EnvConfig.isDebug ? debug : notDebug
    }

    /// A copy of these components with the given query items, written as a variadic list.
    public func with(queryItems: URLQueryItem...) -> Self {
        with(array: queryItems)
    }

    /// A copy of these components with the given query items.
    ///
    /// If the components already carry query items, those are kept and `array` is not added.
    public func with(array: [URLQueryItem]) -> Self {
        var buffer = self
        buffer.queryItems = buffer.queryItems ?? [] + array
        return buffer
    }

    /// A copy of these components whose path is `path` under the server's `/api/` root.
    public func with(path: String) -> Self {
        var buffer = self
        buffer.path = "/api/" + path
        return buffer
    }
}
