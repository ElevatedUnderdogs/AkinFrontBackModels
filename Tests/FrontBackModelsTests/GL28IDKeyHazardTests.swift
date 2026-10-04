//
//  GL28IDKeyHazardTests.swift
//  FrontBackModelsTests
//
//  GOAL_LOOP28 item 1.7, found by the round trip guard it asked for.
//
//  A property whose name ends in a capital `ID` CANNOT round trip through the shared wire
//  coders. `userID` encodes to `user_id` under `.convertToSnakeCase`, and `.convertFromSnakeCase`
//  turns `user_id` back into `userId`, which is not `userID`. The decode then throws
//  `keyNotFound`.
//
//  This is NOT new and it is not something this loop introduced: the server has used these two
//  strategies since long before this loop, and ARCHITECTURE.md already records one instance of
//  exactly this defect, `CreateQuestionnaireRequest.contextID`, which was found the hard way
//  when the app could not create a questionnaire at all. What is new is knowing how many more
//  share the shape: 59 properties across 21 files in this package, on the 43 types that
//  guard's scanner reports, and 42 of those 43 declare no CodingKeys at all. Counted with the
//  scanner in `IdentifierSpellingGuardTests` rather than with a second one, so the number here
//  and the number the ratchet enforces cannot drift apart.
//
//  One of those 43 is a false positive and it is worth knowing which, because the number looks
//  wrong against any hand count: `NearbyUserMessage` has no `userID` STORED property. It has a
//  `CodingKeys` case of that name and a local `let userID` inside its `init(from:)`, and the
//  scanner's property pattern matches a local binding in a function body. Harmless, because a
//  false positive only makes the ratchet stricter, and left alone here because changing a guard's
//  scanner changes what every other number in it means.
//
//  The test below PASSES, and it passes by asserting the broken behaviour. That is deliberate.
//  It is a characterisation test: it pins the hazard so it cannot be rediscovered by accident,
//  and the day somebody fixes the strategy or adds CodingKeys across the package, this test
//  fails, which is the signal to go and read why.
//
//  The full account lives in GOAL_LOOP28's evidence ledger, which is NOT in this repository and
//  is NOT committed in the other one: `docs/` is gitignored in the app repository, so a reader
//  of this file alone cannot follow a pointer to it. The parts that outlive the loop are
//  therefore stated HERE rather than referenced: the types carrying the `*ID` spelling are
//  listed by name in `IdentifierSpellingGuardTests`, which is committed beside this file and is
//  a ratchet, and the behaviour itself is pinned by the two cases below.
//

import XCTest
@testable import AkinFrontBackModels

final class GL28IDKeyHazardTests: XCTestCase {

    private struct IDSuffixed: Codable, Equatable {
        let userID: String
        let plainName: String
    }

    func testGL28_1_7_aCapitalIDSuffixDoesNotSurviveTheSnakeCaseRoundTrip() throws {
        let original = IDSuffixed(userID: "u", plainName: "n")
        let wire = try JSONEncoder.akinWire.encode(original)

        // The encode direction is fine, and it is worth seeing the bytes: the key really does
        // go out as `user_id`, which is what the server reads.
        let text = String(decoding: wire, as: UTF8.self)
        XCTAssertTrue(text.contains("\"user_id\""), "encoded as: \(text)")
        XCTAssertTrue(text.contains("\"plain_name\""), "encoded as: \(text)")

        // The decode direction is where it breaks, and only for the ID suffix.
        XCTAssertThrowsError(try JSONDecoder.akinWire.decode(IDSuffixed.self, from: wire)) { error in
            guard case DecodingError.keyNotFound(let key, _) = error else {
                return XCTFail("expected keyNotFound, got \(error)")
            }
            XCTAssertEqual(
                key.stringValue, "userID",
                "the round trip fails on the ID suffixed key, which is the whole hazard"
            )
        }
    }

    /// The same shape with a lowercase `Id` is fine, which is what makes the hazard easy to miss.
    func testGL28_1_7_aLowercaseIdSuffixRoundTripsCleanly() throws {
        struct IdSuffixed: Codable, Equatable {
            let userId: String
            let plainName: String
        }
        let original = IdSuffixed(userId: "u", plainName: "n")
        let wire = try JSONEncoder.akinWire.encode(original)
        XCTAssertEqual(try JSONDecoder.akinWire.decode(IdSuffixed.self, from: wire), original)
    }
}
