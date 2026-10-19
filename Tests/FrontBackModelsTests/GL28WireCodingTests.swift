//
//  GL28WireCodingTests.swift
//  FrontBackModelsTests
//
//  GOAL_LOOP28 item 1.3. The wire date convention is the single point of truth, and it is
//  pinned to the BYTES the server actually produced rather than to a hand written sample.
//

import XCTest
@testable import AkinFrontBackModels

final class GL28WireCodingTests: XCTestCase {

    /// Captured from `GET api/user/:id/contexts/:contextID/profiles` against
    /// map-mates-api-production on 2026-10-04. Demo review account data only.
    private let capturedProductionBody = Data("""
    [{"created_at":"2026-10-04T01:11:37.866Z","is_active":true,"is_default":true,\
    "id":"178BFD79-3EFA-45A0-9D9C-1C367D812CB0","name":"My answers",\
    "context_id":"50C1A1C0-C0DE-57C0-ACDE-EC7EC7EC7EC7",\
    "owner_id":"D39E4C89-A527-4083-90C2-76C1F0BF1193"}]
    """.utf8)

    func testGL28_theCapturedProductionBodyDecodes() throws {
        let rows = try JSONDecoder.akinWire.decode(
            [MatchmakingProfileSummary].self, from: capturedProductionBody
        )
        // literal-ok: 1 is the number of profiles in the captured production body, which is the specification here.
        XCTAssertEqual(rows.count, 1, "the captured body carries one profile; an empty result "
                       + "would pass every assertion below while proving nothing")
        // literal-ok: the captured production body is frozen bytes; this name is what it contains.
        XCTAssertEqual(rows[0].name, "My answers")
        XCTAssertNotNil(rows[0].ownerId)
        XCTAssertTrue(rows[0].isDefault)
    }

    /// The defect itself, kept as a test so it cannot come back silently.
    func testGL28_fractionalSecondsAreAcceptedAndPlainSecondsStillAre() throws {
        XCTAssertNotNil(
            WireDate.date(from: "2026-10-04T01:11:37.866Z"),
            "the fractional form is what the server writes; refusing it is note B17-01"
        )
        XCTAssertNotNil(
            WireDate.date(from: "2026-10-04T01:11:37Z"),
            "the plain form is what an older build may send; refusing it turns a version "
                + "skew into a black screen"
        )
    }

    func testGL28_anInstantSurvivesTheRoundTripToTheMillisecond() throws {
        let original = MatchmakingProfileSummary(
            id: UUID(), ownerId: UUID(), contextId: UUID(), name: "Weeknights",
            isActive: true, isDefault: false,
            // A whole number of milliseconds, because the format carries three decimal places
            // and nothing more. Asserting a finer instant would be asserting against the
            // format rather than against the code.
            createdAt: Date(timeIntervalSince1970: 1_791_000_000.123)
        )
        let wire = try JSONEncoder.akinWire.encode(original)
        let back = try JSONDecoder.akinWire.decode(MatchmakingProfileSummary.self, from: wire)
        XCTAssertEqual(back, original)
    }

    /// What the server writes has to be what this package writes, or the contract moved to one
    /// side again.
    func testGL28_theEncoderProducesTheServersExactSpelling() throws {
        let when = Date(timeIntervalSince1970: 1_791_000_000.123)
        // literal-ok: this string IS the wire format's specification, byte for byte.
        XCTAssertEqual(WireDate.string(from: when), "2026-10-03T04:00:00.123Z")
        // literal-ok: this string IS the wire format's specification, byte for byte.
        XCTAssertEqual(WireDate.format, "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX")
    }
}
