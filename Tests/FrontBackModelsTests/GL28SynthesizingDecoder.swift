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
        GL28SynthUnkeyed(codingPath: codingPath, depth: depth,
                         count: depth >= Self.maxDepth ? 0 : 1)
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
    default:
        // An enum validates: it accepts its own raw values and rejects everything else, so
        // handing it the generic string sample makes it throw `dataCorrupted` and the failure
        // says nothing about the wire contract. Where the type can enumerate itself, use a
        // value it actually has. This is the difference between a synthesizer that exercises
        // 269 types and one that reports 115 failures about its own sample data.
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
                         count: depth + 1 >= GL28SynthDecoder.maxDepth ? 0 : 1)
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
