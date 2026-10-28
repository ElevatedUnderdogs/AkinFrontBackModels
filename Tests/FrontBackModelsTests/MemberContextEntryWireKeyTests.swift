//
//  MemberContextEntryWireKeyTests.swift
//  FrontBackModelsTests
//
//  Build 29 feedback, B29-05: "This should show the list of contexts." The screen said "The
//  contexts did not arrive" on a request the server answered 200, because the deployment it was
//  talking to is pinned to an older copy of this package and still writes the answered count
//  under its old name.
//

import XCTest
@testable import AkinFrontBackModels

final class MemberContextEntryWireKeyTests: XCTestCase {

    /// The debug deployment's own body, copied from one authenticated read on 2026-10-28.
    private let oldKeyBody = """
    [{"memberCount":1,"id":"50C1A1C0-C0DE-57C0-ACDE-EC7EC7EC7EC7","isParticipating":true,\
    "answeredQuestionCount":2,"displayName":"Social","isMemberCreated":false,\
    "normalisedKey":"social"}]
    """

    /// The release deployment's body, from the same read against production.
    private let newKeyBody = """
    [{"displayName":"social","normalisedKey":"social","isParticipating":false,\
    "id":"50C1A1C0-C0DE-57C0-ACDE-EC7EC7EC7EC7","memberCount":13,"isMemberCreated":false,\
    "yourAnsweredQuestionCount":12}]
    """

    func testARowWrittenWithTheRetiredKeyStillDecodes() throws {
        let rows = try JSONDecoder().decode([MemberContextEntry].self, from: Data(oldKeyBody.utf8))
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].yourAnsweredQuestionCount, 2)
        // literal-ok: the body above is the deployment's own, copied from one read
        XCTAssertEqual(rows[0].displayName, "Social")
    }

    func testARowWrittenWithTheCurrentKeyStillDecodes() throws {
        let rows = try JSONDecoder().decode([MemberContextEntry].self, from: Data(newKeyBody.utf8))
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].yourAnsweredQuestionCount, 12)
    }

    /// Encoding writes the current key and only the current key, so a row this package produces
    /// is never ambiguous about which number it is carrying.
    func testEncodingWritesOnlyTheCurrentKey() throws {
        let entry = MemberContextEntry(
            id: UUID(), displayName: "Social", memberCount: 3,
            yourAnsweredQuestionCount: 7, isParticipating: true, isMemberCreated: false
        )
        let data = try JSONEncoder().encode(entry)
        let text = String(decoding: data, as: UTF8.self)
        XCTAssertTrue(text.contains("yourAnsweredQuestionCount"))
        XCTAssertFalse(text.contains("\"answeredQuestionCount\""))
        let back = try JSONDecoder().decode(MemberContextEntry.self, from: data)
        XCTAssertEqual(back, entry)
    }

    /// A row missing BOTH spellings is still a failure, so this is a widened contract rather
    /// than a silent default.
    func testARowCarryingNeitherKeyStillFails() {
        let body = """
        [{"memberCount":1,"id":"50C1A1C0-C0DE-57C0-ACDE-EC7EC7EC7EC7","isParticipating":true,\
        "displayName":"Social","isMemberCreated":false,"normalisedKey":"social"}]
        """
        XCTAssertThrowsError(
            try JSONDecoder().decode([MemberContextEntry].self, from: Data(body.utf8))
        )
    }
}
