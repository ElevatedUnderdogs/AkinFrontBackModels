//
//  SampleDecoder.swift
//  FrontBackModelsTests
//
//  Builds a sample value of any Codable type from its key names. Ported from the server's endpoint check.
//

import Foundation

/// A `Decoder` that invents a fixed value for every field, optionals included.
struct SampleDecoder: Decoder {
    var codingPath: [any CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] { [:] }

    /// Optionals and arrays below this depth stay empty so recursive types end.
    static let maxDepth = 8
    static let id = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    static func make<T: Decodable>(_ type: T.Type) throws -> T {
        try SampleDecoder().value(T.self, key: nil)
    }

    var isDeep: Bool { codingPath.count >= Self.maxDepth }

    static func string(for key: String?) -> String {
        guard let key else { return "sample" }
        let k = key.lowercased()
        if k.contains("email") { return "member@example.invalid" }
        // Validated string enums that are not CaseIterable.
        if k == "authorvisibility" { return "attributed" }
        if k.hasSuffix("id") { return id.uuidString }
        if k.contains("url") { return "https://example.invalid/sample" }
        return "sample \(key)"
    }

    func value<T: Decodable>(_ type: T.Type, key: String?) throws -> T {
        if T.self == UUID.self { return Self.id as! T }
        if T.self == String.self { return Self.string(for: key) as! T }
        if T.self == Calendar.self { return Calendar(identifier: .gregorian) as! T }
        if T.self == TimeZone.self { return TimeZone(identifier: "UTC")! as! T }
        if T.self == Locale.self { return Locale(identifier: "en_US") as! T }
        if T.self == Date.self { return Date(timeIntervalSinceReferenceDate: 0) as! T }
        if T.self == Data.self { return Data() as! T }
        if T.self == URL.self { return URL(string: Self.string(for: "url"))! as! T }
        if T.self == Int.self { return (key?.lowercased() == "per" ? 20 : 1) as! T }
        if T.self == Double.self { return 1.0 as! T }
        if T.self == Bool.self { return false as! T }
        if T.self == Float.self { return Float(1) as! T }
        if T.self == Int8.self { return Int8(1) as! T }
        if T.self == Int16.self { return Int16(1) as! T }
        if T.self == Int32.self { return Int32(1) as! T }
        if T.self == Int64.self { return Int64(1) as! T }
        if T.self == UInt.self { return UInt(1) as! T }
        if T.self == UInt8.self { return UInt8(1) as! T }
        if T.self == UInt16.self { return UInt16(1) as! T }
        if T.self == UInt32.self { return UInt32(1) as! T }
        if T.self == UInt64.self { return UInt64(1) as! T }
        if let cases = T.self as? any CaseIterable.Type, let first = Self.firstCase(cases) as? T {
            return first
        }
        return try T(from: self)
    }

    fileprivate static func firstCase<C: CaseIterable>(_ type: C.Type) -> Any? { type.allCases.first }

    func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        KeyedDecodingContainer(Keyed<Key>(decoder: self))
    }

    func unkeyedContainer() throws -> any UnkeyedDecodingContainer { Unkeyed(decoder: self) }

    func singleValueContainer() throws -> any SingleValueDecodingContainer { Single(decoder: self) }

    fileprivate var lastKey: String? { codingPath.last.flatMap { $0.intValue == nil ? $0.stringValue : nil } }

    private func child(_ key: any CodingKey) -> SampleDecoder {
        SampleDecoder(codingPath: codingPath + [key])
    }

    struct Keyed<Key: CodingKey>: KeyedDecodingContainerProtocol {
        let decoder: SampleDecoder
        var codingPath: [any CodingKey] { decoder.codingPath }
        /// An enum with associated values decodes its first CodingKeys case.
        var allKeys: [Key] {
            guard let cases = Key.self as? any CaseIterable.Type,
                  let first = SampleDecoder.firstCase(cases) as? Key else { return [] }
            return [first]
        }
        func contains(_ key: Key) -> Bool { true }
        func decodeNil(forKey key: Key) throws -> Bool { decoder.isDeep }
        func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
            try decoder.child(key).value(T.self, key: key.stringValue)
        }
        private func decode<T: Decodable>(_ type: T.Type, generic key: Key) throws -> T {
            try decoder.child(key).value(T.self, key: key.stringValue)
        }
        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool { try decode(type as Bool.Type, generic: key) }
        func decode(_ type: String.Type, forKey key: Key) throws -> String { try decode(type as String.Type, generic: key) }
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double { try decode(type as Double.Type, generic: key) }
        func decode(_ type: Float.Type, forKey key: Key) throws -> Float { try decode(type as Float.Type, generic: key) }
        func decode(_ type: Int.Type, forKey key: Key) throws -> Int { try decode(type as Int.Type, generic: key) }
        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 { try decode(type as Int8.Type, generic: key) }
        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 { try decode(type as Int16.Type, generic: key) }
        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 { try decode(type as Int32.Type, generic: key) }
        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 { try decode(type as Int64.Type, generic: key) }
        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt { try decode(type as UInt.Type, generic: key) }
        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 { try decode(type as UInt8.Type, generic: key) }
        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { try decode(type as UInt16.Type, generic: key) }
        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { try decode(type as UInt32.Type, generic: key) }
        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { try decode(type as UInt64.Type, generic: key) }
        func nestedContainer<NestedKey: CodingKey>(
            keyedBy type: NestedKey.Type, forKey key: Key
        ) throws -> KeyedDecodingContainer<NestedKey> {
            try decoder.child(key).container(keyedBy: type)
        }
        func nestedUnkeyedContainer(forKey key: Key) throws -> any UnkeyedDecodingContainer {
            try decoder.child(key).unkeyedContainer()
        }
        func superDecoder() throws -> any Decoder { decoder }
        func superDecoder(forKey key: Key) throws -> any Decoder { decoder.child(key) }
    }

    struct IndexKey: CodingKey {
        var stringValue: String { "\(intValue ?? 0)" }
        var intValue: Int?
        init(_ index: Int) { intValue = index }
        init?(stringValue: String) { nil }
        init?(intValue: Int) { self.intValue = intValue }
    }

    /// Two elements per array.
    struct Unkeyed: UnkeyedDecodingContainer {
        let decoder: SampleDecoder
        var codingPath: [any CodingKey] { decoder.codingPath }
        /// Two, so a dictionary with non-String keys gets a whole key/value pair.
        var count: Int? { decoder.isDeep ? 0 : 2 }
        var isAtEnd: Bool { currentIndex >= count ?? 1 }
        var currentIndex = 0
        init(decoder: SampleDecoder) { self.decoder = decoder }
        mutating func decodeNil() throws -> Bool { false }
        mutating func decode<T: Decodable>(_ type: T.Type) throws -> T { try decode(generic: type) }
        mutating func decode(_ type: Bool.Type) throws -> Bool { try decode(generic: type) }
        mutating func decode(_ type: String.Type) throws -> String { try decode(generic: type) }
        mutating func decode(_ type: Double.Type) throws -> Double { try decode(generic: type) }
        mutating func decode(_ type: Float.Type) throws -> Float { try decode(generic: type) }
        mutating func decode(_ type: Int.Type) throws -> Int { try decode(generic: type) }
        mutating func decode(_ type: Int8.Type) throws -> Int8 { try decode(generic: type) }
        mutating func decode(_ type: Int16.Type) throws -> Int16 { try decode(generic: type) }
        mutating func decode(_ type: Int32.Type) throws -> Int32 { try decode(generic: type) }
        mutating func decode(_ type: Int64.Type) throws -> Int64 { try decode(generic: type) }
        mutating func decode(_ type: UInt.Type) throws -> UInt { try decode(generic: type) }
        mutating func decode(_ type: UInt8.Type) throws -> UInt8 { try decode(generic: type) }
        mutating func decode(_ type: UInt16.Type) throws -> UInt16 { try decode(generic: type) }
        mutating func decode(_ type: UInt32.Type) throws -> UInt32 { try decode(generic: type) }
        mutating func decode(_ type: UInt64.Type) throws -> UInt64 { try decode(generic: type) }
        private mutating func decode<T: Decodable>(generic type: T.Type) throws -> T {
            defer { currentIndex += 1 }
            let key = decoder.lastKey.map { $0.hasSuffix("s") ? String($0.dropLast()) : $0 }
            return try SampleDecoder(codingPath: decoder.codingPath + [IndexKey(currentIndex)])
                .value(T.self, key: key)
        }
        mutating func nestedContainer<NestedKey: CodingKey>(
            keyedBy type: NestedKey.Type
        ) throws -> KeyedDecodingContainer<NestedKey> {
            defer { currentIndex += 1 }
            return try decoder.container(keyedBy: type)
        }
        mutating func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
            defer { currentIndex += 1 }
            return Unkeyed(decoder: decoder)
        }
        mutating func superDecoder() throws -> any Decoder { decoder }
    }

    struct Single: SingleValueDecodingContainer {
        let decoder: SampleDecoder
        var codingPath: [any CodingKey] { decoder.codingPath }
        func decodeNil() -> Bool { false }
        func decode<T: Decodable>(_ type: T.Type) throws -> T { try decode(generic: type) }
        func decode(_ type: Bool.Type) throws -> Bool { try decode(generic: type) }
        func decode(_ type: String.Type) throws -> String { try decode(generic: type) }
        func decode(_ type: Double.Type) throws -> Double { try decode(generic: type) }
        func decode(_ type: Float.Type) throws -> Float { try decode(generic: type) }
        func decode(_ type: Int.Type) throws -> Int { try decode(generic: type) }
        func decode(_ type: Int8.Type) throws -> Int8 { try decode(generic: type) }
        func decode(_ type: Int16.Type) throws -> Int16 { try decode(generic: type) }
        func decode(_ type: Int32.Type) throws -> Int32 { try decode(generic: type) }
        func decode(_ type: Int64.Type) throws -> Int64 { try decode(generic: type) }
        func decode(_ type: UInt.Type) throws -> UInt { try decode(generic: type) }
        func decode(_ type: UInt8.Type) throws -> UInt8 { try decode(generic: type) }
        func decode(_ type: UInt16.Type) throws -> UInt16 { try decode(generic: type) }
        func decode(_ type: UInt32.Type) throws -> UInt32 { try decode(generic: type) }
        func decode(_ type: UInt64.Type) throws -> UInt64 { try decode(generic: type) }
        private func decode<T: Decodable>(generic type: T.Type) throws -> T {
            try decoder.value(T.self, key: decoder.lastKey)
        }
    }
}
