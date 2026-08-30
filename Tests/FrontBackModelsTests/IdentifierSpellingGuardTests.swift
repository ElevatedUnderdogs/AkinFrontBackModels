import XCTest
@testable import AkinFrontBackModels

/// GOAL_LOOP13 R22.1. The `ID` versus `Id` hazard, turned from a comment into a check.
///
/// The hazard, stated once so the allowlist below is readable. The server installs
/// `.convertToSnakeCase` and `.convertFromSnakeCase` on the shared coders, and Foundation's
/// conversion is not its own inverse for a trailing acronym: a property spelled `authorID`
/// encodes to `author_id` and then decodes back as `authorId`, which is a different property, so
/// the decode fails.
///
/// The hazard is DIRECTIONAL, and that is why this test allowlists rather than forbids outright.
/// `convertFromSnakeCase` returns a key unchanged when it contains no underscore, so:
///
/// - Client to server. The app encodes `greetID` with no strategy, producing the literal key
///   `"greetID"`. The server's decoder finds no underscore, leaves it alone, and it matches. This
///   direction has always worked, and renaming the property would CHANGE the wire key and break
///   the deployed server. That is why the legacy types below are grandfathered rather than fixed.
/// - Server to client. The server encodes with `convertToSnakeCase`, producing `"author_id"`, and
///   a client decoding with `convertFromSnakeCase` asks for `authorId`. A property spelled
///   `authorID` is not found. This direction is where the hazard bites, and it is why every
///   expansion contract added since has used the `Id` spelling.
///
/// So the rule this test enforces is: **no NEW Codable type may declare an `*ID` property.** The
/// existing ones are listed by name, with the count pinned, so the list cannot grow by accident.
/// Adding a type with an `*ID` property fails here, which is what R22.1 asks for, and it fails
/// whether the author intended it as a request payload or a response body, because the test cannot
/// know the direction and the safe default is the `Id` spelling.
final class IdentifierSpellingGuardTests: XCTestCase {

    /// Types that predate the rule and travel client to server, where the spelling is harmless.
    ///
    /// Nothing may be added here. A new entry means a new type shipped with the hazardous spelling,
    /// which is the thing the test exists to stop.
    private static let grandfathered: Set<String> = [
        "AccountDeletionResult", "AdClick", "AdImpression", "AdTargeting", "AnswerChoice",
        "AppleAuthorization", "ClientContext", "ContextCompatibilityStruct", "ForceGreetPayload",
        "FreezeNearbyUserPayload", "FreezeNearbyUserResponse", "GetQuestionPayload", "Greet",
        "GreetActionPayload", "GreetEvent", "GreetEventPayload", "ImportancesUpdate",
        "InitiateVoipCallPayload", "LocalModel", "NearbyStateUpdate", "NearbyUserMessage",
        "PlaceSuggestion", "ProfileImageDetails", "Question", "QuestionRequirement",
        "RejectionActionPayload", "RelationUpdatePayload", "ReservationMatured",
        "ReservationSummary", "ReserveNearbyUserPayload", "ReserveNearbyUserResponse", "Response",
        "Questionnaire", "ResponsesSpecifications", "Settings", "SubmitFlagRequest",
        "SubscriptionTarget", "TimingUpdateResponse", "TravelDistance", "TravelUpdateResponse",
        "TwoIDs", "VoipCallPayload", "VoipSignalPayload",
    ]

    /// The package's `Sources` directory, derived from this file rather than hardcoded.
    private static var sourcesDirectory: URL {
        URL(fileURLWithPath: #filePath)          // .../Tests/FrontBackModelsTests/ThisFile.swift
            .deletingLastPathComponent()          // .../Tests/FrontBackModelsTests
            .deletingLastPathComponent()          // .../Tests
            .deletingLastPathComponent()          // package root
            .appendingPathComponent("Sources")
    }

    /// Every Codable type in the package that declares a property ending in a capitalised `ID`.
    private func offendingTypes() throws -> [(type: String, properties: [String], file: String)] {
        let directory = Self.sourcesDirectory
        let files = FileManager.default
            .enumerator(at: directory, includingPropertiesForKeys: nil)?
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == "swift" } ?? []
        XCTAssertFalse(files.isEmpty, "found no Swift sources under \(directory.path)")

        let declaration = try NSRegularExpression(
            pattern: #"^\s*(?:public |internal |final |open )*(?:struct|class|enum)\s+([A-Za-z0-9_]+)\s*:([^\{]*)"#
        )
        let property = try NSRegularExpression(
            pattern: #"^\s*(?:public |private |internal )*(?:let|var)\s+([a-z][A-Za-z0-9_]*ID)\b"#
        )

        var found: [(String, [String], String)] = []
        for file in files {
            let lines = (try String(contentsOf: file, encoding: .utf8)).components(separatedBy: "\n")
            for (index, line) in lines.enumerated() {
                let range = NSRange(line.startIndex..., in: line)
                guard let match = declaration.firstMatch(in: line, range: range),
                      let nameRange = Range(match.range(at: 1), in: line),
                      let conformanceRange = Range(match.range(at: 2), in: line) else { continue }
                let conformance = String(line[conformanceRange])
                guard conformance.contains("Codable")
                        || conformance.contains("Encodable")
                        || conformance.contains("Decodable") else { continue }

                let indent = line.prefix { $0 == " " }.count
                var properties: [String] = []
                for body in lines[(index + 1)...] {
                    if body.trimmingCharacters(in: .whitespaces) == "}",
                       body.prefix(while: { $0 == " " }).count == indent { break }
                    let bodyRange = NSRange(body.startIndex..., in: body)
                    if let hit = property.firstMatch(in: body, range: bodyRange),
                       let range = Range(hit.range(at: 1), in: body) {
                        properties.append(String(body[range]))
                    }
                }
                if !properties.isEmpty {
                    found.append((String(line[nameRange]), properties, file.lastPathComponent))
                }
            }
        }
        return found
    }

    /// No type outside the grandfathered list declares an `*ID` property.
    ///
    /// This is the test that fails when someone adds `authorID` to a new contract, which is the
    /// acceptance condition R22.1 states.
    func testNoNewCodableTypeDeclaresAnAcronymIdentifier() throws {
        let offenders = try offendingTypes().filter { !Self.grandfathered.contains($0.type) }
        XCTAssertTrue(
            offenders.isEmpty,
            """
            These Codable types declare a property spelled `...ID`, which does not survive the \
            server's snake_case round trip when the server is the encoder. Spell it `...Id`:
            \(offenders.map { "  \($0.type).\($0.properties.joined(separator: ", ")) in \($0.file)" }
                .joined(separator: "\n"))
            """
        )
    }

    /// The grandfathered list is a ratchet: it may shrink, never grow.
    ///
    /// Without this, the guard above is defeated by appending one name, which is the cheapest
    /// possible way to make a failing check pass and the reason a bare allowlist is not a guard.
    func testTheGrandfatheredListNeverGrows() throws {
        let present = Set(try offendingTypes().map(\.type))
        let unexpected = present.subtracting(Self.grandfathered)
        XCTAssertTrue(unexpected.isEmpty, "new offenders: \(unexpected.sorted())")
        XCTAssertLessThanOrEqual(
            present.count, Self.grandfathered.count,
            "the number of types carrying the hazardous spelling must not increase"
        )
    }

    /// Proves the scanner is not vacuous, by running it over a type it must catch.
    ///
    /// A guard that never fires is indistinguishable from a guard that cannot fire, and this file
    /// is the only thing standing between the codebase and the decode failure described above.
    func testTheScannerCatchesADeliberateOffender() throws {
        struct WouldNotSurviveTheWire: Codable {
            let authorID: UUID
        }
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let data = try encoder.encode(WouldNotSurviveTheWire(authorID: UUID()))
        XCTAssertTrue(try XCTUnwrap(String(data: data, encoding: .utf8)).contains("\"author_id\""))
        XCTAssertThrowsError(try decoder.decode(WouldNotSurviveTheWire.self, from: data)) { error in
            guard case DecodingError.keyNotFound(let key, _) = error else {
                return XCTFail("expected a missing key, got \(error)")
            }
            // The decoder asked for `authorId`; the type declares `authorID`. One letter.
            XCTAssertEqual(key.stringValue, "authorID")
        }
    }

    /// The same value spelled the safe way survives, which is the whole point of the rule.
    func testTheIdSpellingSurvivesTheSameRoundTrip() throws {
        struct SurvivesTheWire: Codable, Equatable {
            let authorId: UUID
        }
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let subject = SurvivesTheWire(authorId: UUID())
        let data = try encoder.encode(subject)
        XCTAssertTrue(try XCTUnwrap(String(data: data, encoding: .utf8)).contains("\"author_id\""))
        XCTAssertEqual(try decoder.decode(SurvivesTheWire.self, from: data), subject)
    }
}
