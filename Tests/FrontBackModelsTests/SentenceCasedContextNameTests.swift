//
//  SentenceCasedContextNameTests.swift
//  AkinFrontBackModelsTests
//
//  Build 27, B27-01. The rule both the app and the server import, so a context name cannot be
//  stored one way by one side and another way by the other.
//
//  The screenshots that produced this are the cases below: the catalog in `B27-03.jpg` and
//  `B27-06.jpg` holds "social" and "romance" beside "Board games" and "Climbing", on one screen.
//

import XCTest
@testable import AkinFrontBackModels

final class SentenceCasedContextNameTests: XCTestCase {

    // MARK: - The rule itself

    func testLowercaseNameGetsOneCapital() {
        XCTAssertEqual(ContextName.sentenceCasedContextName("rock climbing"), "Rock climbing")
    }

    func testShoutedNameIsLowered() {
        XCTAssertEqual(ContextName.sentenceCasedContextName("ROCK CLIMBING"), "Rock climbing")
    }

    /// Title case is NOT the rule. This is the case that tells the two apart.
    func testTitleCasedNameLosesItsSecondCapital() {
        XCTAssertEqual(ContextName.sentenceCasedContextName("Rock Climbing"), "Rock climbing")
    }

    func testAlreadySentenceCasedNameIsUnchanged() {
        XCTAssertEqual(ContextName.sentenceCasedContextName("Board games"), "Board games")
    }

    /// The two names that are actually in the catalog, from `B27-03.jpg` and `B27-06.jpg`.
    func testTheTwoNamesBuild27ShowedLowercased() {
        XCTAssertEqual(ContextName.sentenceCasedContextName("social"), "Social")
        XCTAssertEqual(ContextName.sentenceCasedContextName("romance"), "Romance")
    }

    // MARK: - It composes with the display fold rather than replacing it

    func testSurroundingAndInternalWhitespaceIsStillCollapsed() {
        XCTAssertEqual(ContextName.sentenceCasedContextName("  rock   climbing "), "Rock climbing")
    }

    func testEmptyAndWhitespaceOnlyNamesStayEmpty() {
        XCTAssertEqual(ContextName.sentenceCasedContextName(""), "")
        XCTAssertEqual(ContextName.sentenceCasedContextName("   "), "")
    }

    // MARK: - It never changes which context a name IS

    /// Casing is a display decision. Uniqueness is enforced on the folded key, and this must not
    /// move that key, or applying the rule to a live catalog could split one context into two.
    func testTheNormalisedKeyIsUnchangedByTheCasing() {
        for raw in ["rock climbing", "ROCK CLIMBING", "Rock Climbing", "  rock   climbing "] {
            XCTAssertEqual(
                ContextName.normalisedKey(ContextName.sentenceCasedContextName(raw)),
                ContextName.normalisedKey(raw),
                "casing moved the key for \(raw)"
            )
        }
    }

    func testApplyingTheRuleTwiceChangesNothingFurther() {
        let once = ContextName.sentenceCasedContextName("ROCK CLIMBING")
        XCTAssertEqual(ContextName.sentenceCasedContextName(once), once)
    }

    // MARK: - A name whose first character cannot be raised

    /// A digit has no uppercase form, so the first character must survive rather than vanish.
    func testNameStartingWithADigitKeepsEveryCharacter() {
        XCTAssertEqual(ContextName.sentenceCasedContextName("5k running"), "5k running")
    }

    /// The fold is locale independent, for the reason `NormalisedName` records: a Turkish device
    /// and an English one must store the same spelling.
    func testTurkishCapitalIFoldsTheSameEverywhere() {
        XCTAssertEqual(ContextName.sentenceCasedContextName("ISTANBUL"), "Istanbul")
    }
}
