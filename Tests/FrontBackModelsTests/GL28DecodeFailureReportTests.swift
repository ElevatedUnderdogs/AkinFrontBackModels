//
//  GL28DecodeFailureReportTests.swift
//  FrontBackModelsTests
//
//  GOAL_LOOP28 item 1.6. The bound and the redaction are the whole point of the type, so they
//  are tested against the shapes that actually defeat a naive implementation.
//

import XCTest
@testable import AkinFrontBackModels

final class GL28DecodeFailureReportTests: XCTestCase {

    private func report(_ body: String) -> DecodeFailureReport {
        DecodeFailureReport(
            endpoint: "GET api/user/:id/contexts/:contextID/profiles",
            codingKey: "created_at",
            expectedType: "MatchmakingProfileSummary",
            appBuild: "18",
            rawBody: body,
            bodyBytes: body.utf8.count
        )
    }

    func testGL28_1_6_theExcerptCannotExceedTheCeiling() {
        let huge = String(repeating: "a", count: 50_000)
        let r = report(huge)
        XCTAssertLessThanOrEqual(r.excerpt.utf8.count, DecodeFailureReport.maxExcerptBytes)
        // literal-ok: the ceiling is the specification, and 50000 is the body it had to cut.
        XCTAssertEqual(r.bodyBytes, 50_000, "the original size must survive the truncation, or "
                       + "a truncated excerpt reads as a short body")
    }

    func testGL28_1_6_personalValuesAreRedactedAndTheirKeysAreNot() {
        let body = #"{"email":"someone@example.com","name":"A Person","is_active":true}"#
        let r = report(body)
        XCTAssertFalse(r.excerpt.contains("someone@example.com"), "an address was reported")
        XCTAssertFalse(r.excerpt.contains("A Person"), "a name was reported")
        XCTAssertTrue(r.excerpt.contains("email"), "the KEY should survive; the shape is the "
                      + "diagnostic and only the value is private")
        XCTAssertTrue(r.excerpt.contains("is_active"), "a non personal field was lost")
    }

    /// The case a JSON-parsing redaction gets wrong: the excerpt is usually truncated mid
    /// structure, so it does not parse, and a redaction that needs valid JSON fails exactly
    /// when the body is malformed, which is the case this type exists for.
    func testGL28_1_6_redactionWorksOnAMalformedTruncatedBody() {
        let body = #"{"id":"x","email":"someone@example.com","first_name":"Ada"#
        let r = report(body)
        XCTAssertFalse(r.excerpt.contains("someone@example.com"))
        XCTAssertFalse(r.excerpt.contains("Ada"))
    }

    func testGL28_1_6_noMemberIdentifierTravels() throws {
        let r = report(#"{"ok":true}"#)
        let wire = try JSONEncoder.akinWire.encode(r)
        let text = String(decoding: wire, as: UTF8.self)
        for forbidden in ["user_id", "userId", "member_id", "memberId", "account_id"] {
            XCTAssertFalse(text.contains(forbidden),
                           "a decode failure is a property of a build and an endpoint, not of a "
                               + "person; \(forbidden) must not travel")
        }
    }

    func testGL28_1_6_theReportRoundTripsThroughTheWireCoders() throws {
        let r = report(#"{"created_at":"2026-10-04T01:11:37.866Z"}"#)
        let back = try JSONDecoder.akinWire.decode(
            DecodeFailureReport.self, from: JSONEncoder.akinWire.encode(r)
        )
        XCTAssertEqual(back, r)
    }
}
