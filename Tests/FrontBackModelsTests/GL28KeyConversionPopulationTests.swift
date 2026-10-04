//
//  GL28KeyConversionPopulationTests.swift
//  FrontBackModelsTests
//
//  GOAL_LOOP28, raised by the Z3 professionality pass. `DISCOVERED.md` entry GL28-D30 opens with a
//  five line table and the reviewer could reproduce three of the five lines exactly and neither of
//  the first two under any population they tried:
//
//      564 property names in the package     <- not reproducible
//       39 do not survive the pair           <- not reproducible
//       54 types declare one of those 39     <- reproduces
//       42 of those 54 are grandfathered     <- reproduces
//       12 of those 54 watched by nothing    <- reproduces, and all twelve verified by name
//
//  They tried 483, 622, 790 and 993 as readings of "property names in the package" and none of
//  them is 564. The probe that produced the two figures was a throwaway and is gone, so the
//  numbers cannot be defended, only re-measured.
//
//  This is the re-measurement, and it is a COMMITTED test rather than a number in a document, so
//  the next person to doubt it can run it. The loop's own rule covers this case: a number that came
//  from a tool nobody can re-run is a defect in the number.
//
//  WHAT IS MEASURED, stated rather than left for a reader to infer, because the whole finding was
//  that the population was unstated:
//
//    * The population is every DISTINCT property name declared in `Sources/`, found by reading the
//      package's own source files and matching stored and computed property declarations. Not
//      declarations, names: `imageURL` on four types is one name, because the hazard is a property
//      of the NAME and Foundation does not know which type it came from.
//    * A name BREAKS when Foundation's two key strategies are not inverses for it, asked through a
//      real keyed container rather than by reimplementing the conversions.
//
//  The count is written to an evidence file and asserted loosely, with the specific known breakers
//  asserted exactly. An exact total would fail the next time anybody adds a property, which turns
//  a measurement into a chore and gets it deleted.
//

import Foundation
import XCTest

@testable import AkinFrontBackModels

final class GL28KeyConversionPopulationTests: XCTestCase {

    /// The package's `Sources` directory, derived from this file rather than hardcoded.
    private static var sourcesDirectory: URL {
        URL(fileURLWithPath: #filePath)            // .../Tests/FrontBackModelsTests/<this>.swift
            .deletingLastPathComponent()           // .../Tests/FrontBackModelsTests
            .deletingLastPathComponent()           // .../Tests
            .deletingLastPathComponent()           // package root
            .appendingPathComponent("Sources")
    }

    /// Every `.swift` file under `Sources`.
    private func sourceFiles() throws -> [URL] {
        let root = Self.sourcesDirectory
        guard let walker = FileManager.default.enumerator(
            at: root, includingPropertiesForKeys: nil
        ) else {
            return []
        }
        var out: [URL] = []
        for case let url as URL in walker where url.pathExtension == "swift" {
            out.append(url)
        }
        return out
    }

    /// Distinct property names declared anywhere under `Sources`.
    ///
    /// A regex over source text, and the shape of it is the population's definition: an optional
    /// run of modifiers, then `let` or `var`, then the name. It deliberately does NOT try to tell a
    /// `Codable` type's property from any other, because a name that cannot survive the conversion
    /// is a hazard the moment somebody makes its type `Codable`, and restricting the count to
    /// today's conformances measures today's luck.
    private func declaredPropertyNames() throws -> Set<String> {
        let pattern = try NSRegularExpression(
            pattern: #"^[ \t]*(?:(?:public|internal|private|fileprivate|package|static|final|lazy|weak|unowned|open|override|nonisolated\(unsafe\)|nonisolated)[ \t]+)*(?:let|var)[ \t]+([A-Za-z_][A-Za-z0-9_]*)"#,
            options: [.anchorsMatchLines]
        )
        var names: Set<String> = []
        for file in try sourceFiles() {
            let text = try String(contentsOf: file, encoding: .utf8)
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            pattern.enumerateMatches(in: text, range: range) { match, _, _ in
                guard let match, let r = Range(match.range(at: 1), in: text) else { return }
                names.insert(String(text[r]))
            }
        }
        return names
    }

    /// Does `name` survive `.convertToSnakeCase` followed by `.convertFromSnakeCase`?
    ///
    /// Asked of Foundation, through a real keyed container, which is the only way to be sure. A
    /// reimplementation of the two conversions is a model of Foundation and this hazard exists
    /// precisely because the model everybody carries is wrong. An earlier probe used a
    /// `[String: T]` and reported every name as broken, because `JSONDecoder` applies no key
    /// strategy to a dictionary.
    private func survivesTheConversionPair(_ name: String) -> Bool {
        struct OneKey: CodingKey {
            let stringValue: String
            var intValue: Int? { nil }
            init(_ value: String) { stringValue = value }
            init?(stringValue: String) { self.stringValue = stringValue }
            init?(intValue: Int) { return nil }
        }
        struct Writer: Encodable {
            let key: String
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: OneKey.self)
                try container.encode(1, forKey: OneKey(key))
            }
        }
        struct Reader: Decodable {
            let found: Bool
            let key: String
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: OneKey.self)
                key = GL28ConversionProbe.key
                found = container.contains(OneKey(GL28ConversionProbe.key))
            }
        }
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        GL28ConversionProbe.key = name
        do {
            let wire = try encoder.encode(Writer(key: name))
            return try decoder.decode(Reader.self, from: wire).found
        } catch {
            return false
        }
    }

    /// The population and the break count, measured and recorded.
    func testGL28_1_7_theKeyConversionPopulationIsMeasurableAndRecorded() throws {
        let names = try declaredPropertyNames()
        XCTAssertGreaterThan(
            names.count, 200,
            "only \(names.count) property names were found, so the regex matched almost nothing "
                + "and every number below would be meaningless"
        )
        let broken = names.filter { !survivesTheConversionPair($0) }.sorted()
        XCTAssertFalse(
            broken.isEmpty,
            "no name breaks the conversion pair, which contradicts GL28-D30 and this file's "
                + "own two sanity cases below; the probe is measuring nothing"
        )

        // Written beside the package so DISCOVERED.md can cite a file rather than a memory.
        let report = Self.sourcesDirectory
            .deletingLastPathComponent()
            .appendingPathComponent("GL28-key-conversion-population.txt")
        var text = """
            GL28-D30, re-measured by GL28KeyConversionPopulationTests.
            POPULATION: distinct property names declared under Sources/, any type, any conformance.
            METHOD: Foundation's own .convertToSnakeCase then .convertFromSnakeCase, through a real
            keyed container. Not a reimplementation of either conversion.
            DISTINCT-PROPERTY-NAMES: \(names.count)
            NAMES-THAT-BREAK-THE-PAIR: \(broken.count)

            """
        text += broken.map { "  \($0)" }.joined(separator: "\n") + "\n"
        try? text.write(to: report, atomically: true, encoding: .utf8)
        print("GL28-D30 re-measured: \(names.count) distinct names, \(broken.count) break the pair")
    }

    /// Two names whose verdicts are known, so a population count cannot be believed on its own.
    ///
    /// `userID` must break and `authorId` must not. If these two ever agree, the probe is broken
    /// rather than the package, and the count above is noise.
    func testGL28_1_7_theConversionProbeAgreesWithTheTwoKnownCases() {
        XCTAssertFalse(survivesTheConversionPair("userID"), "userID should not survive the pair")
        XCTAssertTrue(survivesTheConversionPair("authorId"), "authorId should survive the pair")
        XCTAssertFalse(survivesTheConversionPair("amPM"), "amPM should not survive the pair")
        XCTAssertFalse(survivesTheConversionPair("priceUSD"), "priceUSD should not survive the pair")
        XCTAssertTrue(survivesTheConversionPair("title"), "an ordinary name should survive")
    }
}

/// The key the decoding probe looks for, which `Decodable` gives no way to pass in.
///
/// `init(from:)` takes only a decoder, so the name under test cannot be an argument. A file scope
/// box is the smallest thing that works. The tests that use it are serial within one class.
enum GL28ConversionProbe {
    nonisolated(unsafe) static var key: String = ""
}
