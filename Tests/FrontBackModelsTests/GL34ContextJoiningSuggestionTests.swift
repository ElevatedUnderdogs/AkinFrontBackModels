//
//  GL34ContextJoiningSuggestionTests.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP34 item A5.Pg: the case gl29.html draws and the contract could not return.
//

import Foundation
import XCTest

@testable import AkinFrontBackModels

/// Typing an existing context's name in another spelling is JOINING it, not creating it.
///
/// WHY THIS IS ITS OWN CASE. gl29.html draws two states for a name that folds onto an existing
/// context: `exact-match` says "Bouldering already exists." and `case-collapse` says "You are
/// joining Bouldering" over "This context is already here under that spelling, so you join the
/// members in it and see their spelling of the name." The second sentence is the one that
/// matters: the member is about to see a name they did not type. The copy for both has been in
/// the contract since GOAL_LOOP31 and only the first was ever returned.
final class GL34ContextJoiningSuggestionTests: XCTestCase {

    private func entry(_ name: String, members: Int = 412) -> ContextCatalogEntry {
        ContextCatalogEntry(
            id: UUID(), displayName: name, memberCount: members, isMemberCreated: true
        )
    }

    func test_theSameSpellingAlreadyExists() {
        let catalog = [entry("Bouldering")]

        let suggestion = ContextNameSuggestions.suggestion(for: "Bouldering", in: catalog)

        guard case .alreadyExists(let existing) = suggestion else {
            return XCTFail("typing the name exactly is not a joining case: \(suggestion)")
        }
        // literal-ok: the catalog in this test is built from this name.
        XCTAssertEqual(existing.displayName, "Bouldering")
    }

    func test_anotherSpellingIsJoining() {
        let catalog = [entry("Bouldering")]

        let suggestion = ContextNameSuggestions.suggestion(for: "bouldering", in: catalog)

        guard case .joining(let existing) = suggestion else {
            return XCTFail(
                "typing another spelling of an existing context says it already exists rather "
                    + "than that the member is joining it: \(suggestion)"
            )
        }
        XCTAssertEqual(
            existing.displayName, "Bouldering",
            "the member sees the spelling that is already there, which is what the sentence is "
                + "about"
        )
    }

    func test_surroundingSpaceIsNotASpellingDifference() {
        let catalog = [entry("Bouldering")]

        let suggestion = ContextNameSuggestions.suggestion(for: "  Bouldering  ", in: catalog)

        guard case .alreadyExists = suggestion else {
            return XCTFail("whitespace around the name is not a different spelling: \(suggestion)")
        }
    }

    func test_bothCasesCarryTheContextTheyAreAbout() {
        let catalog = [entry("Bouldering")]

        XCTAssertEqual(
            ContextNameSuggestions.suggestion(for: "bouldering", in: catalog).existing?.displayName,
            "Bouldering"
        )
        XCTAssertEqual(
            ContextNameSuggestions.suggestion(for: "Bouldering", in: catalog).existing?.displayName,
            "Bouldering"
        )
    }

    func test_neitherCaseBlocksCreation() {
        let catalog = [entry("Bouldering")]

        // Item 2.13: the sheet WARNS and never blocks, and a new case must not quietly become a
        // refusal.
        XCTAssertFalse(
            ContextNameSuggestions.suggestion(for: "bouldering", in: catalog).blocksCreation
        )
    }

    func test_theJoiningCopyIsTheCompsOwn() {
        // literal-ok: gl29.html fixes these two sentences, and this is where they are held to
        // the comp's words rather than to whatever the function happens to return.
        XCTAssertEqual(
            ContextCreateCopy.joiningHeadline("Bouldering"), "You are joining Bouldering"
        )
        // literal-ok: gl29.html fixes this action's words.
        XCTAssertEqual(ContextCreateCopy.joinAction("Bouldering"), "Join Bouldering")
    }
}
