//
//  EarlyAdopterTierTests.swift
//  FrontBackModelsTests
//
//  TestFlight feedback note B17-15: "I want the early adopter emojis to show on the profile
//  pictures of different users."
//

import XCTest
@testable import AkinFrontBackModels

final class EarlyAdopterTierTests: XCTestCase {

    // MARK: - Banding

    /// The four bands are the ones the app has always drawn, and the boundaries are inclusive at
    /// the top, which is how the client's own `medalDescription` has always read them.
    func testEachBandClaimsItsOwnBoundary() {
        XCTAssertEqual(EarlyAdopterTier.from(joinRank: 1), .diamond)
        XCTAssertEqual(EarlyAdopterTier.from(joinRank: 10), .diamond)
        XCTAssertEqual(EarlyAdopterTier.from(joinRank: 11), .gold)
        XCTAssertEqual(EarlyAdopterTier.from(joinRank: 100), .gold)
        XCTAssertEqual(EarlyAdopterTier.from(joinRank: 101), .silver)
        XCTAssertEqual(EarlyAdopterTier.from(joinRank: 1_000), .silver)
        XCTAssertEqual(EarlyAdopterTier.from(joinRank: 1_001), .bronze)
        XCTAssertEqual(EarlyAdopterTier.from(joinRank: 10_000), .bronze)
    }

    /// Outside the window there is no badge, which is most members.
    func testOutsideTheRankedWindowThereIsNoTier() {
        XCTAssertNil(EarlyAdopterTier.from(joinRank: 10_001))
        XCTAssertNil(EarlyAdopterTier.from(joinRank: 1_000_000))
        XCTAssertNil(EarlyAdopterTier.from(joinRank: nil))
    }

    /// A join rank is 1 based, so zero or a negative is a not-set sentinel arriving where a value
    /// was expected. Banding it would award the TOP badge to a member who has no rank at all.
    ///
    /// This is not hypothetical. The client's `Int.medalDescription` reads `self <= 10`, so a
    /// server sentinel of -1 has already rendered as "Diamond" in this product once.
    func testANotSetSentinelIsNotTheTopBand() {
        XCTAssertNil(EarlyAdopterTier.from(joinRank: 0))
        XCTAssertNil(EarlyAdopterTier.from(joinRank: -1))
        XCTAssertNil(EarlyAdopterTier.from(joinRank: Int.min))
    }

    /// `allCases` has to stay in ascending order of `highestRank`, because `from(joinRank:)`
    /// takes the FIRST band the rank fits in. Reordering the cases would silently reband
    /// everybody.
    func testTheCasesAreOrderedByTheirBoundary() {
        XCTAssertEqual(
            EarlyAdopterTier.allCases.map(\.highestRank),
            EarlyAdopterTier.allCases.map(\.highestRank).sorted()
        )
    }

    // MARK: - What it draws

    func testEveryBandHasItsOwnGlyphAndName() {
        let glyphs = Set(EarlyAdopterTier.allCases.map(\.medalEmoji))
        let names = Set(EarlyAdopterTier.allCases.map(\.name))
        XCTAssertEqual(glyphs.count, EarlyAdopterTier.allCases.count, "Two bands share a glyph.")
        XCTAssertEqual(names.count, EarlyAdopterTier.allCases.count, "Two bands share a name.")
        for tier in EarlyAdopterTier.allCases {
            XCTAssertFalse(tier.medalEmoji.isEmpty)
            XCTAssertFalse(tier.name.isEmpty)
        }
    }

    // MARK: - The wire

    func testTheTierRoundTrips() throws {
        for tier in EarlyAdopterTier.allCases {
            let data = try JSONEncoder().encode(tier)
            XCTAssertEqual(try JSONDecoder().decode(EarlyAdopterTier.self, from: data), tier)
        }
    }

    /// The field is absent from every response an older deployment sends, and the whole
    /// TestFlight window has the app newer than the server. Absent must mean no badge, not a
    /// failed decode that takes the member's photograph off the list with it.
    func testANearbyUserFromAnOlderServerDecodesWithNoTier() throws {
        let json = Data("""
        {
          "id": "\(UUID().uuidString)",
          "name": "Tom",
          "profileImage": "https://example.test/tom.jpg",
          "imageMetaData": {
            "width": 300,
            "height": 300,
            "format": "jpeg",
            "assessment": { "entries": [] },
            "id": "\(UUID().uuidString)"
          }
        }
        """.utf8)
        let user = try JSONDecoder().decode(NearbyUser.self, from: json)
        XCTAssertNil(user.earlyAdopterTier)
    }

    /// And an UNKNOWN band from a FUTURE server is the same answer rather than a thrown error,
    /// which is the direction nobody tests and the one that takes a whole list down.
    func testANearbyUserFromAFutureServerWithAnUnknownBandStillDecodes() throws {
        // Bound once and read twice, so the payload and the assertion cannot drift apart. The
        // name is not the thing under test here; surviving an unknown band is.
        let name = "Tom-\(UUID().uuidString.prefix(8))"
        let json = Data("""
        {
          "id": "\(UUID().uuidString)",
          "name": "\(name)",
          "profileImage": "https://example.test/tom.jpg",
          "imageMetaData": {
            "width": 300,
            "height": 300,
            "format": "jpeg",
            "assessment": { "entries": [] },
            "id": "\(UUID().uuidString)"
          },
          "earlyAdopterTier": "unobtanium"
        }
        """.utf8)
        let user = try JSONDecoder().decode(NearbyUser.self, from: json)
        XCTAssertNil(user.earlyAdopterTier)
        XCTAssertEqual(user.name, name, "The rest of the member must survive an unknown band.")
    }

    func testANearbyUserCarriesTheTierAcrossTheWire() throws {
        let user = NearbyUser(
            id: UUID(),
            name: "Tom",
            profileImage: "https://example.test/tom.jpg",
            imageMetaData: ImageMetadata(
                width: 300, height: 300, format: "jpeg",
                assessment: ModerationAssessment(entries: []), id: UUID()
            ),
            earlyAdopterTier: .gold
        )
        let decoded = try JSONDecoder().decode(
            NearbyUser.self, from: try JSONEncoder().encode(user)
        )
        XCTAssertEqual(decoded.earlyAdopterTier, .gold)
    }

    /// The ordinal must not be reachable from the wire type. This is the disclosure constraint
    /// stated as a test rather than only as a comment on the field.
    func testTheWireCarriesNoJoinRank() {
        let mirror = Mirror(reflecting: EarlyAdopterTier.gold)
        XCTAssertTrue(
            mirror.children.isEmpty,
            "The tier is a band. An associated rank would put the ordinal back on the wire."
        )
    }
}
