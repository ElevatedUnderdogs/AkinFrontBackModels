//
//  DisplayNameTests.swift
//  AkinFrontBackModelsTests
//
//  GOAL_LOOP27 item 14.2. The cases that actually happened, not a sweep of the obvious ones.
//
//  Every case below except the two ordinary ones is a defect that was live in production or that the
//  old composition would have produced the moment note 2 landed. `firstName + " " + lastName` passes
//  the ordinary case and fails all of them, which is why the ordinary case alone was never enough.
//

import XCTest
@testable import AkinFrontBackModels

final class DisplayNameTests: XCTestCase {

    // MARK: - The ordinary case, so the change is not a regression

    func testBothPartsPresentReadAsTwoWords() {
        XCTAssertEqual(DisplayName.compose(firstName: "Scott", lastName: "Lydon"), "Scott Lydon")
    }

    // MARK: - The case that was live in production

    /// Measured 2026-10-01: one of fourteen production rows had an empty `last_name`, so every surface
    /// reading that member's name rendered it with a space stuck on the end.
    func testAnEmptyLastNameLeavesNoTrailingSpace() {
        let composed = DisplayName.compose(firstName: "Tom", lastName: "")
        XCTAssertEqual(composed, "Tom")
        XCTAssertFalse(composed.hasSuffix(" "), "a trailing space was the production defect")
    }

    /// The same defect in the other direction, which the old composition also had.
    func testAnEmptyFirstNameLeavesNoLeadingSpace() {
        let composed = DisplayName.compose(firstName: "", lastName: "Meyers")
        XCTAssertEqual(composed, "Meyers")
        XCTAssertFalse(composed.hasPrefix(" "), "a leading space is the same defect mirrored")
    }

    /// Whitespace-only is not a name. A row holding a single space would otherwise compose to a name
    /// that looks present and renders as nothing.
    func testWhitespaceOnlyPartsAreDroppedRatherThanJoined() {
        XCTAssertEqual(DisplayName.compose(firstName: "   ", lastName: "Lydon"), "Lydon")
        XCTAssertEqual(DisplayName.compose(firstName: "Scott", lastName: "\t\n"), "Scott")
        XCTAssertEqual(DisplayName.compose(firstName: " ", lastName: " "), "")
    }

    func testNilPartsCompose() {
        XCTAssertEqual(DisplayName.compose(firstName: nil, lastName: "Lydon"), "Lydon")
        XCTAssertEqual(DisplayName.compose(firstName: "Scott", lastName: nil), "Scott")
        XCTAssertEqual(DisplayName.compose(firstName: nil, lastName: nil), "")
    }

    /// Interior whitespace belongs to the name. Someone called "Mary Jane" in one field keeps both
    /// words, so the trim is of the EDGES rather than a collapse of everything.
    func testInteriorSpacingIsLeftAlone() {
        XCTAssertEqual(DisplayName.compose(firstName: "Mary Jane", lastName: "Watson"), "Mary Jane Watson")
        XCTAssertEqual(DisplayName.compose(firstName: "  Mary Jane  ", lastName: "Watson"), "Mary Jane Watson")
    }

    // MARK: - The sentence form, which is the one the refusal uses

    /// `GreetDemoAvailability.availability(counterpartName:)` interpolates its argument into sentences.
    /// An empty name there produces " has already opened this greet.", which reads as a bug.
    func testASentenceNeverBeginsWithAnEmptyName() {
        XCTAssertEqual(
            DisplayName.forSentence(firstName: "", lastName: ""),
            "This person"
        )
        XCTAssertEqual(
            DisplayName.forSentence(firstName: nil, lastName: nil, fallback: "The other member"),
            "The other member"
        )
    }

    func testASentenceUsesTheRealNameWhenThereIsOne() {
        XCTAssertEqual(DisplayName.forSentence(firstName: "Sarah", lastName: ""), "Sarah")
        XCTAssertEqual(DisplayName.forSentence(firstName: "Tom", lastName: "Lydon"), "Tom Lydon")
    }

    /// The whole point of putting this in the shared package: a refusal sentence built on the server
    /// and the same sentence built in the app name the same person identically. This asserts the
    /// composition is what `availability` actually receives, by building one of its sentences from it.
    func testTheRefusalSentenceNamesTheCounterpartTheSameWayBothSidesWould() {
        let name = DisplayName.forSentence(firstName: "Sarah", lastName: "")
        // A greet the counterpart has already opened cannot be opened again, so "they opened the
        // greet" is unavailable and its reason names the counterpart. That is the sentence GOAL_LOOP26
        // caught the server and the app wording differently.
        let context = GreetDemoContext(
            phase: .awaitingAgreement,
            call: .none,
            counterpartHasViewed: true,
            viewerAgreedMinutes: [],
            counterpartAgreedMinutes: [],
            counterpartRejectedMinutes: []
        )
        let availability = GreetDemoRules.availability(
            of: .viewedGreetScreen,
            in: context,
            counterpartName: name
        )
        guard case .unavailable(let reason) = availability else {
            return XCTFail("a greet already opened cannot be opened again, so this must be unavailable")
        }
        XCTAssertTrue(
            reason.hasPrefix("Sarah "),
            "the sentence must open with the composed name, got: \(reason)"
        )
        XCTAssertFalse(reason.hasPrefix(" "), "a leading space is the defect this type removes")
    }
}
