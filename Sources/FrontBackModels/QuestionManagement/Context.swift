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
    /// this no longer returns nil for a raw value that is not one of the built in cases. The
    /// initializer stays failable in signature only so existing `if let`/`guard let` call sites
    /// keep compiling.
    ///
    /// The built in cases were romance and social when this was written, which is why the sentence
    /// above used to name that pair. Business joined them in GOAL_LOOP41, and naming the SET
    /// rather than its members is what keeps this line true the next time one is added.
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
        /// NOW IN `allCases` BELOW, AND THAT IS A REVERSAL OF WHAT THIS COMMENT USED TO SAY. The
        /// argument here was that leaving business out kept the change narrow, because every
        /// built-in-only path that reads `allCases` would otherwise gain a context it had never
        /// seen. GOAL_LOOP41 reverses it: Social and Business are the two contexts every member
        /// has without creating anything, and a default that the built-in-only paths cannot see is
        /// not a default. Those paths are the settings rows, the compatibility sweep and the debug
        /// fixtures, and each of them was describing a product with one company context. The
        /// server creates from `Handler.shippedContextCases`, which is `[.social, .business]`, and
        /// a client list that disagreed with it is the drift this closes.
        public static let business = Case(rawValue: "business")

        /// The built-in contexts, the two company defaults first. Call sites that must reflect
        /// member-created contexts read the live context list instead (swept in item 1.12); this
        /// remains for the built-in-only paths.
        ///
        /// THE ORDER IS THE ORDER THE TWO WAY CONTROLS DRAW, so a reader of this list does not
        /// have to re-sort it to match the screen. The list used to start with romance, and the
        /// one caller that needed Social first sorted it again itself and said in its own comment
        /// that it was doing so.
        ///
        /// ROMANCE IS STILL HERE, AND IT IS NO LONGER A DEFAULT. It remains a built-in context a
        /// member can switch on in the contexts section, so every built-in-only path still has to
        /// be able to name it. What changed is that nobody may take the DEFAULTS from the front of
        /// this list: the two places that decide which contexts are defaults, `DefaultContexts`
        /// in the app and `Handler.shippedContextCases` on the server, state their own pair.
        public static let allCases: [Case] = [.social, .business, .romance]
    }
}
