//
//  RequestPathParameters.swift
//  AkinFrontBackModels
//
//  StrongContractClient sends `path` as written. A contract whose path has `:name` components
//  (the server's Vapor parameters) is filled in with real values before it is sent.
//

import Foundation
import StrongContractClient

extension Request {

    /// This request with each `:name` path component replaced by `values[name]`.
    /// - Parameter values: The value for each parameter name, without the colon.
    /// - Returns: A copy whose path has no `:name` component left for a name in `values`.
    public func filling(_ values: [String: String]) -> Self {
        let filledPath: String = path
            .split(separator: "/", omittingEmptySubsequences: false)
            .map { component -> String in
                guard component.hasPrefix(":"), let value = values[String(component.dropFirst())] else {
                    return String(component)
                }
                return value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? value
            }
            .joined(separator: "/")
        return Self(
            path: filledPath,
            method: method,
            baseComponents: baseComponents,
            initialPath: initialPath,
            contentType: contentType,
            token: token,
            assertHasAccessToken: assertHasAccessToken
        )
    }

    /// This request with `items` as its query string.
    /// - Parameter items: The query items, in order.
    /// - Returns: A copy that sends `items` after the path.
    public func querying(_ items: [URLQueryItem]) -> Self {
        var components: URLComponents = baseComponents
        components.queryItems = items.isEmpty ? nil : items
        return Self(
            path: path,
            method: method,
            baseComponents: components,
            initialPath: initialPath,
            contentType: contentType,
            token: token,
            assertHasAccessToken: assertHasAccessToken
        )
    }
}
