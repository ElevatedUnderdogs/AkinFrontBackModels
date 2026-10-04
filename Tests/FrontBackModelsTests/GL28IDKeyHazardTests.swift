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
//  share the shape: 62 properties across 21 files in this package, 17 of which declare no
//  CodingKeys at all.
//
//  The test below PASSES, and it passes by asserting the broken behaviour. That is deliberate.
//  It is a characterisation test: it pins the hazard so it cannot be rediscovered by accident,
//  and the day somebody fixes the strategy or adds CodingKeys across the package, this test
//  fails and points at the entry in DISCOVERED.md that explains what changed and why.
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
