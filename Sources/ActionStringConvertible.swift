//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 1/19/26.
//

import Foundation

public protocol ActionStringConvertible {
    var actionString: String { get }
}

public extension ActionStringConvertible {

    var actionString: String {
        let mirror = Mirror(reflecting: self)

        // Case name (strip "(...)" if present)
        let rawCaseName = String(describing: self)
            .components(separatedBy: "(")
            .first!
            .snakeCased

        // No associated values
        guard let child = mirror.children.first else {
            return rawCaseName
        }

        // Extract associated values in declaration order
        let associatedValues: [String] = Mirror(reflecting: child.value).children.map {
            stringifyAssociatedValue($0.value)
        }

        guard !associatedValues.isEmpty else {
            return rawCaseName
        }

        return ([rawCaseName] + associatedValues).joined(separator: "_")
    }

    private func stringifyAssociatedValue(_ value: Any) -> String {
        switch value {
        case let uuid as UUID:
            return uuid.uuidString.lowercased()

        case let string as String:
            return string.snakeCased

        case let int as Int:
            return String(int)

        case let bool as Bool:
            return bool ? "true" : "false"

        case Optional<Any>.none:
            return "nil"

        case let optional as Optional<Any>:
            return optional.map { stringifyAssociatedValue($0) } ?? "nil"

        default:
            return String(describing: value).snakeCased
        }
    }
}
