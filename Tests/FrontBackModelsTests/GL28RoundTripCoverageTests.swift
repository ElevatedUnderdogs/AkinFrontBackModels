//
//  GL28RoundTripCoverageTests.swift
//  FrontBackModelsTests
//
//  GOAL_LOOP28 item 1.7. The guard this loop owes the next one.
//
//  Note B17-01 was two sides disagreeing about one convention with nothing to notice it. The
//  fix put the convention in this package; this makes the fix enforceable rather than
//  remembered, by round tripping through the SAME coders both sides now use.
//

import XCTest
@testable import AkinFrontBackModels

final class GL28RoundTripCoverageTests: XCTestCase {

    /// Encode with the wire encoder, decode with the wire decoder, compare.
    private func roundTrip<T: Codable & Equatable>(_ value: T, _ label: String) throws {
        let wire = try JSONEncoder.akinWire.encode(value)
        XCTAssertGreaterThan(wire.count, 0, "\(label) encoded to nothing")
        let back = try JSONDecoder.akinWire.decode(T.self, from: wire)
        XCTAssertEqual(back, value, "\(label) did not survive the round trip")
    }

    func testGL28_1_7_matchmakingProfileSummaryRoundTrips() throws {
        try roundTrip(
            MatchmakingProfileSummary(
                id: UUID(), ownerId: UUID(), contextId: UUID(), name: "Weeknights",
                isActive: true, isDefault: false,
                createdAt: Date(timeIntervalSince1970: 1_791_000_000.123)
            ),
            "MatchmakingProfileSummary"
        )
    }

    /// The owner-withheld shape, which is the one a non-owner reader gets.
    func testGL28_1_7_anAbsentOwnerSurvivesTheRoundTrip() throws {
        try roundTrip(
            MatchmakingProfileSummary(
                id: UUID(), ownerId: nil, contextId: UUID(), name: "Someone else's",
                isActive: false, isDefault: false,
                createdAt: Date(timeIntervalSince1970: 1_791_000_000.456)
            ),
            "MatchmakingProfileSummary with a withheld owner"
        )
    }

    func testGL28_1_7_subscriptionTargetRoundTrips() throws {
        try roundTrip(SubscriptionTarget.questionnaire(UUID()), "SubscriptionTarget.questionnaire")
        try roundTrip(SubscriptionTarget.member(UUID()), "SubscriptionTarget.member")
    }

    func testGL28_1_7_everyAuthorVisibilityCaseRoundTrips() throws {
        for value in AuthorVisibility.allCases {
            try roundTrip(value, "AuthorVisibility.\(value)")
        }
        for value in AuthoredContentKind.allCases {
            try roundTrip(value, "AuthoredContentKind.\(value)")
        }
    }

    /// The whole point: a `Date` is the field that broke, so it is asserted at the precision
    /// the format actually carries rather than at whatever a sample happened to be.
    func testGL28_1_7_aDateRoundTripsToTheMillisecondAndNoFurther() throws {
        struct Box: Codable, Equatable { let when: Date }
        // The format carries three decimal places. Asserting a finer instant would assert
        // against the format rather than against the code.
        let when = Date(timeIntervalSince1970: 1_791_000_000.123)
        try roundTrip(Box(when: when), "a bare Date")

        // And the shape a server that predates the fractional form sends is still understood.
        // literal-ok: this string IS the non-fractional wire spelling being accepted.
        let legacy = Data(#"{"when":"2026-10-04T01:11:37Z"}"#.utf8)
        XCTAssertNoThrow(
            try JSONDecoder.akinWire.decode(Box.self, from: legacy),
            "refusing the older spelling turns a version skew into a black screen"
        )
    }
}
