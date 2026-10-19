//
//  GoalLoop14InboundVisibilityTests.swift
//  FrontBackModelsTests
//
//  GOAL_LOOP14 F5.7.
//
//  `init(from:)` fails closed, mapping anything it does not recognise to
//  `anonymized`, because it has to read rows that still hold the retired raw
//  values. Applied to an inbound request that same tolerance means a client
//  typo returns 200 and silently switches a member's content to anonymous.
//
//  These two behaviours are both correct and they are not the same behaviour,
//  so they are tested against each other here rather than one at a time.
//

import XCTest

@testable import AkinFrontBackModels

final class GoalLoop14InboundVisibilityTests: XCTestCase {

    // MARK: - What is accepted

    func testEveryCurrentValueIsAccepted() throws {
        for expected in AuthorVisibility.allCases {
            XCTAssertEqual(try AuthorVisibility.requireKnown(expected.rawValue), expected)
        }
    }

    // MARK: - What is refused

    /// Including the retired values. They are readable history, not something a
    /// client may still send.
    func testRetiredAndUnknownValuesAreRefused() {
        let refused = [
            AuthorVisibility.Legacy.silent,
            AuthorVisibility.Legacy.unattributedAnnounced,
            "banana",
            "",
            "Attributed",
            "attributed ",
        ]
        for raw in refused {
            XCTAssertThrowsError(
                try AuthorVisibility.requireKnown(raw),
                "\(raw.debugDescription) was accepted as an inbound value"
            )
        }
    }

    /// The refusal names what arrived and what is accepted, which is the half of
    /// F5.7 that makes the error usable rather than merely correct.
    func testTheRefusalNamesTheAcceptedSet() throws {
        let error = try XCTUnwrap(
            {
                do {
                    _ = try AuthorVisibility.requireKnown("banana")
                    return nil as AuthorVisibility.UnknownValue?
                } catch let unknown as AuthorVisibility.UnknownValue {
                    return unknown
                } catch {
                    return nil
                }
            }()
        )
        let message = error.description
        XCTAssertTrue(message.contains("banana"), "the message does not say what arrived: \(message)")
        for accepted in AuthorVisibility.allCases {
            XCTAssertTrue(
                message.contains(accepted.rawValue),
                "the message does not name \(accepted.rawValue): \(message)"
            )
        }
    }

    /// The accepted set is derived, so a third case would appear in the message
    /// without anyone editing it. Asserting the count is what makes that claim
    /// testable rather than aspirational.
    func testTheAcceptedSetIsDerivedFromTheCases() {
        let error = AuthorVisibility.UnknownValue(received: "banana")
        XCTAssertEqual(error.accepted.count, AuthorVisibility.allCases.count)
        XCTAssertEqual(error.accepted, AuthorVisibility.allCases.map(\.rawValue))
    }

    // MARK: - And the stored-value decode still tolerates history

    /// The guard against "fixing" F5.7 by making the decoder strict too, which
    /// would make every row holding a retired value unreadable.
    func testTheStoredValueDecodeStillReadsRetiredValues() throws {
        for raw in AuthorVisibility.Legacy.allStoredRawValues {
            let json = Data("\"\(raw)\"".utf8)
            XCTAssertNoThrow(
                try JSONDecoder().decode(AuthorVisibility.self, from: json),
                "\(raw) is a stored value and must stay decodable"
            )
        }
    }

    /// And still fails closed on something it has never seen, which is the
    /// property that keeps an uninterpretable row from resolving to "show this
    /// person's name".
    func testTheStoredValueDecodeStillFailsClosed() throws {
        let decoded = try JSONDecoder().decode(
            AuthorVisibility.self, from: Data("\"banana\"".utf8)
        )
        XCTAssertEqual(decoded, .anonymized)
    }
}
