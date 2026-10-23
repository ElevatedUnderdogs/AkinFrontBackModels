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
    public let rawValue: String
    public let `case`: Case

    public init(id: UUID, `case`: Case) {
        self.id = id
        self.case = `case`
        self.rawValue = `case`.rawValue
    }

    /// Now always succeeds (item 1.11): a user-created context carries an arbitrary raw value, so
    /// this no longer returns nil for anything other than romance and social. The initializer stays
    /// failable in signature only so existing `if let`/`guard let` call sites keep compiling.
    public init?(id: UUID, rawValue: String) {
        self.id = id
        self.case = Case(rawValue: rawValue)
        self.rawValue = rawValue
    }

    /// A context kind. Value-backed rather than a closed enum (item 1.11): `romance` and `social`
    /// remain named statics, but any raw value is a valid case, so member-created contexts are
    /// first-class. Codable stays a bare string, exactly as the former `enum Case: String` encoded,
    /// so stored and in-flight `Context` payloads are unchanged.
    public struct Case: Codable, Hashable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(from decoder: Decoder) throws {
            self.rawValue = try decoder.singleValueContainer().decode(String.self)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }

        public static let romance = Case(rawValue: "romance")
        public static let social = Case(rawValue: "social")

        /// The Case for business, the second context every member sees.
        ///
        /// GOAL_LOOP35 box 75, DR115: a member never has fewer than two contexts they did not have
        /// to create, and this is the other one.
        ///
        /// DELIBERATELY NOT IN `allCases` BELOW. That list is the older built-in-only idea of the
        /// set, and its own comment says live call sites should read the context list instead.
        /// Adding to it would change what every one of those older paths sees, which is a wider
        /// change than shipping a second default. The set the server actually creates from is
        /// `Handler.shippedContextCases`, and that is where this Case is added alongside social.
        public static let business = Case(rawValue: "business")

        /// The built-in contexts. Call sites that must reflect member-created contexts read the live
        /// context list instead (swept in item 1.12); this remains for the built-in-only paths.
        public static let allCases: [Case] = [.romance, .social]
    }
}
