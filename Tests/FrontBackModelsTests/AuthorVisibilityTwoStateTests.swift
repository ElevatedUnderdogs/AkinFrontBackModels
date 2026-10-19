//
//  AuthorVisibilityTwoStateTests.swift
//  AkinFrontBackModelsTests
//
//  GOAL_LOOP14 F5.2 and F5.5.
//
//  The contract is two states, and every raw value the storage has ever held has to decode to one
//  of them without throwing. A decode that throws turns a row written by an older build into a
//  500, which is a worse outcome than a slightly stale label.
//
//  The full contract, including why an unknown value decodes closed, is in
//  `akin/docs/GOAL_LOOP14_AUTHORSHIP_CONTRACT.md`.
//

import XCTest

@testable import AkinFrontBackModels

final class AuthorVisibilityTwoStateTests: XCTestCase {

    private func decode(_ rawValue: String) throws -> AuthorVisibility {
        try JSONDecoder().decode(AuthorVisibility.self, from: Data("\"\(rawValue)\"".utf8))
    }

    // MARK: - The contract is two states

    /// If a third case ever reappears in `allCases`, the single switch silently becomes a list
    /// again and F5 has been undone without anyone saying so.
    func testThereAreExactlyTwoStates() {
        XCTAssertEqual(AuthorVisibility.allCases.count, 2, "\(AuthorVisibility.allCases)")
        XCTAssertEqual(Set(AuthorVisibility.allCases), [.attributed, .anonymized])
    }

    // MARK: - Every legacy raw value decodes, to the documented target

    func testAttributedDecodesUnchanged() throws {
        XCTAssertEqual(try decode("attributed"), .attributed)
    }

    /// `silent` said nothing about authorship and let nobody follow the author from the content.
    /// That is exactly what `anonymized` means.
    func testSilentDecodesToAnonymized() throws {
        XCTAssertEqual(try decode(AuthorVisibility.Legacy.silent), .anonymized)
    }

    /// `unattributedAnnounced` claimed a member wrote it without naming them. After GOAL_LOOP13
    /// R21.12 it disclosed the author to nobody, including followers, which is what left it
    /// behaviourally identical to `silent` and made the middle option removable.
    func testUnattributedAnnouncedDecodesToAnonymized() throws {
        XCTAssertEqual(try decode(AuthorVisibility.Legacy.unattributedAnnounced), .anonymized)
    }

    /// An unrecognised value decodes closed, not open.
    ///
    /// The two guesses are not symmetric. Guessing `attributed` publishes a name the stored value
    /// might have been withholding, and the member cannot take that back from anyone who saw it.
    /// Guessing `anonymized` withholds a name it might have published, which is visible,
    /// reportable and fixable.
    func testAnUnknownValueDecodesClosed() throws {
        XCTAssertEqual(try decode("someValueFromAFutureBuild"), .anonymized)
        XCTAssertEqual(try decode(""), .anonymized)
        XCTAssertEqual(try decode("ATTRIBUTED"), .anonymized, "the match is exact, not case folded")
    }

    /// Nothing above may accidentally make a current value decode to the other one.
    func testTheTwoCurrentValuesRoundTripThroughCoding() throws {
        for value in AuthorVisibility.allCases {
            let data = try JSONEncoder().encode(value)
            XCTAssertEqual(try JSONDecoder().decode(AuthorVisibility.self, from: data), value)
        }
    }

    /// The set the database CHECK constraint has to admit is every value ever written, not just
    /// the two current ones. A constraint narrower than the data is a failed write, not a clean
    /// migration.
    func testLegacyRawValuesCoverBothCurrentCasesAndBothRetiredOnes() {
        let stored = Set(AuthorVisibility.Legacy.allStoredRawValues)
        XCTAssertTrue(
            stored.isSuperset(of: Set(AuthorVisibility.allCases.map(\.rawValue))),
            "a current case is missing from the stored set: \(stored)"
        )
        XCTAssertTrue(stored.contains("silent"))
        XCTAssertTrue(stored.contains("unattributedAnnounced"))
        XCTAssertEqual(stored.count, 4, "\(stored)")
    }

    /// The retired raw values are reachable as strings and NOT as cases, which is the whole point
    /// of the `Legacy` namespace: a switch cannot handle them, so no reader has to rediscover that
    /// a third option is dead.
    func testRetiredValuesAreNotCases() {
        XCTAssertFalse(AuthorVisibility.allCases.map(\.rawValue).contains(AuthorVisibility.Legacy.silent))
        XCTAssertFalse(
            AuthorVisibility.allCases.map(\.rawValue)
                .contains(AuthorVisibility.Legacy.unattributedAnnounced)
        )
    }

    // MARK: - F5.5, the switch defaults to off

    func testTheDefaultIsAttributed() {
        XCTAssertEqual(AuthorVisibility.default, .attributed)
        XCTAssertFalse(AuthorVisibility.default.isAnonymized, "the switch starts off")
    }

    /// F7.5. One conversion, lossless in both directions, so authorship cannot mean two different
    /// things depending on which sheet the member used.
    func testTheSwitchStateMapsBothWays() {
        XCTAssertEqual(AuthorVisibility.from(isAnonymized: false), .attributed)
        XCTAssertEqual(AuthorVisibility.from(isAnonymized: true), .anonymized)
        for value in AuthorVisibility.allCases {
            XCTAssertEqual(
                AuthorVisibility.from(isAnonymized: value.isAnonymized), value,
                "the conversion has to be lossless in both directions"
            )
        }
    }

    // MARK: - Disclosure follows the two states

    /// Exactly one state discloses. Asserted over `allCases` rather than by naming the two, so a
    /// third case added later cannot inherit "disclose" without failing here.
    func testOnlyAttributedDiscloses() {
        let author = UUID()
        let disclosing = AuthorVisibility.allCases.filter {
            DisclosedAuthor(author: author, visibility: $0).id != nil
        }
        XCTAssertEqual(disclosing, [.attributed])
        XCTAssertEqual(DisclosedAuthor(author: author, visibility: .attributed).id, author)
        XCTAssertNil(DisclosedAuthor(author: author, visibility: .anonymized).id)
    }

    /// A value that arrived as a legacy string still redacts, which is the case that matters: a
    /// row the backfill has not reached must not start naming its author because the build no
    /// longer recognises the string it holds.
    func testALegacyValueStillRedactsAfterDecoding() throws {
        let author = UUID()
        for rawValue in [AuthorVisibility.Legacy.silent, AuthorVisibility.Legacy.unattributedAnnounced] {
            let decoded = try decode(rawValue)
            XCTAssertNil(
                DisclosedAuthor(author: author, visibility: decoded).id,
                "\(rawValue) decoded to \(decoded), which discloses"
            )
        }
    }
}
