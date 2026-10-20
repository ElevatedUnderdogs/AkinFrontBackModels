//
//  GL34MeetMarkControlCopyTests.swift
//  FrontBackModelsTests
//
//  GOAL_LOOP34 D1.Ca and B2.Cd. The want to meet control's words, in both of its states.
//

import XCTest

@testable import AkinFrontBackModels

/// What the control says, which gl29.html draws in two places and this contract holds once.
///
/// The marked label used to read "Undo I want to meet". gl29.html draws "You want to meet": a
/// pressed toggle that states what is true, `aria-pressed="true"`, and undoes it when tapped. The
/// copy check could not see it, because the comp writes it beside a glyph element and the
/// extractor read leaf elements only, so the app said one thing and every copy box passed.
final class GL34MeetMarkControlCopyTests: XCTestCase {

    /// The two labels, as the comp draws them with no name to add.
    func test_theListRowsWords() {
        // literal-ok: gl29.html fixes both of these.
        XCTAssertEqual(MeetMarkCopy.markControl, "I want to meet")
        // literal-ok: as above.
        XCTAssertEqual(MeetMarkCopy.rescindControl, "You want to meet")
    }

    /// The profile's, which names the member after the words.
    func test_theProfilesWords() {
        // literal-ok: gl29.html's SingleGreetedUserView draws both of these.
        XCTAssertEqual(MeetMarkCopy.markControl(for: "June"), "I want to meet June")
        // literal-ok: as above.
        XCTAssertEqual(MeetMarkCopy.rescindControl(for: "June"), "You want to meet June")
    }

    /// No name, no trailing space: a surface with no single subject says the words alone.
    func test_withoutANameTheWordsStandAlone() {
        for name in [nil, "", "   "] as [String?] {
            XCTAssertEqual(MeetMarkCopy.markControl(for: name), MeetMarkCopy.markControl)
            XCTAssertEqual(MeetMarkCopy.rescindControl(for: name), MeetMarkCopy.rescindControl)
        }
    }
}
