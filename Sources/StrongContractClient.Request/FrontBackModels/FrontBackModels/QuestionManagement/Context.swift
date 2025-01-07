//
//  Contekst.swift
//  akin
//
//  Created by Scott Lydon on 8/5/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public struct Context: Codable, Hashable {

    public typealias RawValue = String

    public let id: UUID
    public let `case`: Case

    public init(id: UUID, `case`: Case) {
        self.id = id
        self.case = `case`
    }

    public var rawValue: RawValue { self.case.rawValue }

    public enum Case: String, CaseIterable, Codable, Hashable {
        case romance, social
    }
}
