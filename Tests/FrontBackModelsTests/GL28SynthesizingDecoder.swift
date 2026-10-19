//
//  GL28SynthesizingDecoder.swift
//  FrontBackModelsTests
//
//  GOAL_LOOP28 item 1.7. A round trip needs an instance, and the package has 265 Codable types.
//  Hand writing a sample for each is 265 chances to write a sample that does not look like the
//  wire, and it is the reason "round trip every shared model" usually degrades into "round trip
//  the handful somebody got to".
//
//  So the instance is synthesized through the Decodable machinery itself: a Decoder that answers
//  every request a type's `init(from:)` makes, with a value of the right type. The type's own
//  initializer decides what it asks for, so this works for any shape without knowing it, custom
//  `init(from:)` included.
//
//  Depth is capped. A type that contains itself, directly or through a chain, would otherwise
//  recurse forever, and nested containers past the cap report themselves empty, which ends the
//  recursion the same way an empty array does.
//

import Foundation
@testable import AkinFrontBackModels

struct GL28SynthDecoder: Decoder {

    /// How deep a nested container may go before it starts answering empty.
    static let maxDepth = 4

    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var depth: Int = 0

    func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        KeyedDecodingContainer(GL28SynthKeyed<Key>(codingPath: codingPath, depth: depth))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        // One element, so a collection property is exercised rather than left empty, and none
        // past the cap, so a recursive shape terminates.
        // TWO elements, not one. A `[Key: Value]` whose key is neither `String` nor `Int`
        // decodes from an unkeyed container of alternating key and value, so a single element is
        // an odd length array and Foundation throws "Expected collection of key-value pairs;
        // encountered odd-length array instead". Two elements is one pair, and for an ordinary
        // array it is strictly better than one because it exercises order.
        GL28SynthUnkeyed(codingPath: codingPath, depth: depth,
                         count: depth >= Self.maxDepth ? 0 : 2)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        GL28SynthSingle(codingPath: codingPath, depth: depth)
    }
}

/// The sample values. Deliberately NOT zero and empty everywhere: a round trip that only ever
/// carries 0, false and "" cannot tell a field that is dropped from a field that is defaulted.
private enum Sample {
    static let string = "gl28"
    static let int = 7
    static let double = 1.5
    static let bool = true
    /// A whole number of milliseconds, because the wire format carries three decimal places and
    /// a finer instant would fail a round trip against the FORMAT rather than against the code.
    static let date = Date(timeIntervalSince1970: 1_791_000_000.123)
    static let uuid = UUID(uuidString: "00000000-0000-0000-0000-0000000000A1")!
    static let url = URL(string: "https://example.invalid/gl28")!
}

private func synthesize<T: Decodable>(_ type: T.Type, codingPath: [CodingKey], depth: Int) throws -> T {
    switch type {
    case is Date.Type: return Sample.date as! T
    case is UUID.Type: return Sample.uuid as! T
    case is URL.Type: return Sample.url as! T
    case is Data.Type: return Data([0x67, 0x6C]) as! T

    // The enums this decoder cannot invent a value for, named one per line.
    //
    // A raw value enum VALIDATES: it accepts its own spellings and rejects everything else. A
    // decoder that does not know the target type cannot know which string is legal for it, hands
    // over the generic sample, and the enum throws `dataCorrupted: Cannot initialize X from
    // invalid String value gl28`. That is a fact about this file's sample data and says nothing
    // at all about the wire contract, so it is answered here rather than reported as a failure.
    //
    // The `CaseIterable` branch below was written to answer this generically and does not. What
    // was MEASURED is that sixteen types reached the fall through and threw on the sample string,
    // every one of them `CaseIterable`; why the existential metatype cast does not take was not
    // established, and this comment says so rather than guessing. Naming the types does not
    // depend on the answer, and a type missing from the list announces itself by name in the
    // failure, which is a better error than a generic one.
    case is NearbyAvailability.Type: return NearbyAvailability.available as! T
    case is VenueAwarenessState.Type: return VenueAwarenessState.unaware as! T
    case is VenueAskOutcome.Type: return VenueAskOutcome.receptive as! T
    case is VenueAudience.Type: return VenueAudience.counterStaff as! T
    case is ProfileSelectionSide.Type: return ProfileSelectionSide.my as! T
    case is NotificationReason.Type:
        return NotificationReason.questionAddedToFollowedQuestionnaire as! T
    case is AutomaticGreetCooldownChoice.Type:
        return AutomaticGreetCooldownChoice.useDefault as! T
    case is AdDisclosureLabel.Type: return AdDisclosureLabel.sponsored as! T
    case is ChooseForMeOutcome.Type: return ChooseForMeOutcome.chose as! T
    case is FreezeOutcome.Type: return FreezeOutcome.frozen as! T
    case is ReserveOutcome.Type: return ReserveOutcome.reserved as! T
    case is GreetDemoCallState.Type: return GreetDemoCallState.none as! T
    // Not a raw value enum: an enum with associated values decodes from a keyed container
    // holding EXACTLY ONE key, and the keyed container below reports that every key is present,
    // so it reads as all of them at once and throws "Invalid number of keys found, expected one".
    case is AutomaticGreetDebugAction.Type:
        return AutomaticGreetDebugAction.expireCooldownNow as! T
    // Reached through a `caseType` discriminator the containing type reads as a String, and the
    // discriminator enum is `private`, so it cannot be named here. The payload free case is the
    // one that needs nothing else.
    case is Greet.Notification.Type: return Greet.Notification.silentLocationUpdate as! T
    case is Question.Response.Selections.MyTheir.Type:
        return Question.Response.Selections.MyTheir.my as! T
    case is CompatibilityRule.Type: return CompatibilityRule.mandatory as! T
    case is VenueMotivationArm.Type: return VenueMotivationArm.intrinsic as! T
    case is GreetAction.Type: return GreetAction.manualGreetInitiated as! T
    case is ReportFlag.Type: return ReportFlag.allCases[0] as! T
    case is FlagSource.Type: return FlagSource.appleIntelligence as! T
    case is ManualGreetStatus.Type: return ManualGreetStatus.success as! T
    case is VenueShiftBucket.Type: return VenueShiftBucket.overnight as! T
    case is VenueOutcomeReport.Source.Type: return VenueOutcomeReport.Source.card as! T
    case is NotificationSubject.Type:
        return NotificationSubject.question(
            id: UUID(uuidString: "00000000-0000-0000-0000-0000000000C3")!,
            text: "gl28"
        ) as! T

    default:
        // An enum validates: it accepts its own raw values and rejects everything else, so
        // handing it the generic string sample makes it throw `dataCorrupted` and the failure
        // says nothing about the wire contract. Where the type can enumerate itself, use a
        // value it actually has. This is the difference between a synthesizer that exercises
        // the package's types and one that reports a run of failures about its own sample data.
        if let enumerable = type as? any CaseIterable.Type,
           let first = enumerable.allCases.first as? T {
            return first
        }
        var d = GL28SynthDecoder()
        d.codingPath = codingPath
        d.depth = depth + 1
        return try T(from: d)
    }
}

private struct GL28SynthKeyed<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K
    var codingPath: [CodingKey]
    var depth: Int
    /// Every key the type asks for is present, so no `keyNotFound` is ever thrown, and the
    /// type's own optionality decides what it reads.
    var allKeys: [K] { [] }
    func contains(_ key: K) -> Bool { depth < GL28SynthDecoder.maxDepth }
    func decodeNil(forKey key: K) throws -> Bool { depth >= GL28SynthDecoder.maxDepth }

    func decode(_ type: Bool.Type, forKey key: K) throws -> Bool { Sample.bool }
    func decode(_ type: String.Type, forKey key: K) throws -> String { Sample.string }
    func decode(_ type: Double.Type, forKey key: K) throws -> Double { Sample.double }
    func decode(_ type: Float.Type, forKey key: K) throws -> Float { Float(Sample.double) }
    func decode(_ type: Int.Type, forKey key: K) throws -> Int { Sample.int }
    func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 { Int8(Sample.int) }
    func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 { Int16(Sample.int) }
    func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 { Int32(Sample.int) }
    func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 { Int64(Sample.int) }
    func decode(_ type: UInt.Type, forKey key: K) throws -> UInt { UInt(Sample.int) }
    func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 { UInt8(Sample.int) }
    func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 { UInt16(Sample.int) }
    func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 { UInt32(Sample.int) }
    func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 { UInt64(Sample.int) }
    func decode<T: Decodable>(_ type: T.Type, forKey key: K) throws -> T {
        try synthesize(type, codingPath: codingPath + [key], depth: depth)
    }

    func nestedContainer<NK: CodingKey>(keyedBy type: NK.Type, forKey key: K) throws
    -> KeyedDecodingContainer<NK> {
        KeyedDecodingContainer(GL28SynthKeyed<NK>(codingPath: codingPath + [key], depth: depth + 1))
    }
    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        GL28SynthUnkeyed(codingPath: codingPath + [key], depth: depth + 1,
                         count: depth + 1 >= GL28SynthDecoder.maxDepth ? 0 : 2)
    }
    func superDecoder() throws -> Decoder {
        var d = GL28SynthDecoder(); d.codingPath = codingPath; d.depth = depth + 1; return d
    }
    func superDecoder(forKey key: K) throws -> Decoder {
        var d = GL28SynthDecoder(); d.codingPath = codingPath + [key]; d.depth = depth + 1; return d
    }
}

private struct GL28SynthUnkeyed: UnkeyedDecodingContainer {
    var codingPath: [CodingKey]
    var depth: Int
    var count: Int?
    var currentIndex: Int = 0
    var isAtEnd: Bool { currentIndex >= (count ?? 0) }

    mutating func decodeNil() throws -> Bool { currentIndex += 1; return false }
    mutating func decode(_ type: Bool.Type) throws -> Bool { currentIndex += 1; return Sample.bool }
    mutating func decode(_ type: String.Type) throws -> String { currentIndex += 1; return Sample.string }
    mutating func decode(_ type: Double.Type) throws -> Double { currentIndex += 1; return Sample.double }
    mutating func decode(_ type: Float.Type) throws -> Float { currentIndex += 1; return Float(Sample.double) }
    mutating func decode(_ type: Int.Type) throws -> Int { currentIndex += 1; return Sample.int }
    mutating func decode(_ type: Int8.Type) throws -> Int8 { currentIndex += 1; return Int8(Sample.int) }
    mutating func decode(_ type: Int16.Type) throws -> Int16 { currentIndex += 1; return Int16(Sample.int) }
    mutating func decode(_ type: Int32.Type) throws -> Int32 { currentIndex += 1; return Int32(Sample.int) }
    mutating func decode(_ type: Int64.Type) throws -> Int64 { currentIndex += 1; return Int64(Sample.int) }
    mutating func decode(_ type: UInt.Type) throws -> UInt { currentIndex += 1; return UInt(Sample.int) }
    mutating func decode(_ type: UInt8.Type) throws -> UInt8 { currentIndex += 1; return UInt8(Sample.int) }
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 { currentIndex += 1; return UInt16(Sample.int) }
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 { currentIndex += 1; return UInt32(Sample.int) }
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 { currentIndex += 1; return UInt64(Sample.int) }
    mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
        currentIndex += 1
        return try synthesize(type, codingPath: codingPath, depth: depth)
    }
    mutating func nestedContainer<NK: CodingKey>(keyedBy type: NK.Type) throws
    -> KeyedDecodingContainer<NK> {
        currentIndex += 1
        return KeyedDecodingContainer(GL28SynthKeyed<NK>(codingPath: codingPath, depth: depth + 1))
    }
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        currentIndex += 1
        return GL28SynthUnkeyed(codingPath: codingPath, depth: depth + 1, count: 0)
    }
    mutating func superDecoder() throws -> Decoder {
        currentIndex += 1
        var d = GL28SynthDecoder(); d.codingPath = codingPath; d.depth = depth + 1; return d
    }
}

private struct GL28SynthSingle: SingleValueDecodingContainer {
    var codingPath: [CodingKey]
    var depth: Int
    func decodeNil() -> Bool { false }
    func decode(_ type: Bool.Type) throws -> Bool { Sample.bool }
    func decode(_ type: String.Type) throws -> String { Sample.string }
    func decode(_ type: Double.Type) throws -> Double { Sample.double }
    func decode(_ type: Float.Type) throws -> Float { Float(Sample.double) }
    func decode(_ type: Int.Type) throws -> Int { Sample.int }
    func decode(_ type: Int8.Type) throws -> Int8 { Int8(Sample.int) }
    func decode(_ type: Int16.Type) throws -> Int16 { Int16(Sample.int) }
    func decode(_ type: Int32.Type) throws -> Int32 { Int32(Sample.int) }
    func decode(_ type: Int64.Type) throws -> Int64 { Int64(Sample.int) }
    func decode(_ type: UInt.Type) throws -> UInt { UInt(Sample.int) }
    func decode(_ type: UInt8.Type) throws -> UInt8 { UInt8(Sample.int) }
    func decode(_ type: UInt16.Type) throws -> UInt16 { UInt16(Sample.int) }
    func decode(_ type: UInt32.Type) throws -> UInt32 { UInt32(Sample.int) }
    func decode(_ type: UInt64.Type) throws -> UInt64 { UInt64(Sample.int) }
    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try synthesize(type, codingPath: codingPath, depth: depth)
    }
}

/// The one way a test should build a sample.
///
/// `T(from: GL28SynthDecoder())` looks equivalent and is not: it enters the type's own
/// `init(from:)` directly and so SKIPS the table of values above, which is reached through
/// `synthesize`. A test that constructs a raw value enum that way gets the generic string sample
/// and a `dataCorrupted` failure that reads like a wire defect. Measured: five cases failed that
/// way before this existed.
enum GL28Synth {
    static func make<T: Decodable>(_ type: T.Type) throws -> T {
        try synthesize(type, codingPath: [], depth: 0)
    }
}
