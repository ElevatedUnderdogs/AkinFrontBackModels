//
//  File.swift
//  
//
//  Created by Scott Lydon on 4/3/24.
//

import Foundation

extension Array {
    public var data: Data {
        withUnsafeBufferPointer { Data(buffer: $0) }
    }
}

extension Array where Element == Question.Response {

    public func hasSelection(
        context: Context/* = UserDefaults.questionContext*/,
        for myTheir: Question.Response.Selections.MyTheir
    ) -> Bool {
        contains { $0.has(myTheir, for: context.rawValue) }
    }
}

extension Array where Element == Greet.Method  {
    public mutating func remove(greetingMethod: Greet.Method) {
        removeAll { $0 == greetingMethod }
    }
}

extension Array where Element == Greet.User {
    public func index(of id: Int) -> Int? {
        firstIndex { Int($0.personal.id) == id }
    }
}
