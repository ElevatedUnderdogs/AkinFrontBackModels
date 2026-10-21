//
//  GL34QuestionnaireCreatorPictureTests.swift
//  FrontBackModelsTests
//
//  GOAL_LOOP34 Q15. The picture a questionnaire row may show, and the one it may not.
//

import XCTest

@testable import AkinFrontBackModels

/// What `QuestionnaireRowSummary.creatorImageURL` carries.
///
/// Scott, 2026-10-20 10:40 PDT: "this should show the user's picture in the profile circle". A
/// picture names somebody as surely as a name does, so the case that refuses to name them cannot
/// carry one, and the type enforces that rather than trusting each caller.
final class GL34QuestionnaireCreatorPictureTests: XCTestCase {

    private let url = "https://imagedelivery.net/abc/def/public"

    /// A named creator's picture is carried.
    func test_aNamedCreatorKeepsTheirPicture() {
        let row = QuestionnaireRowSummary(
            id: UUID(),
            title: "Weekend plans",
            creator: .member(id: UUID(), name: "Alex"),
            questionCount: 3,
            answeredSomeCount: 2,
            answeredAllCount: 1,
            creatorImageURL: url
        )
        XCTAssertEqual(row.creatorImageURL, url)
    }

    /// The viewer's own row keeps theirs too.
    func test_yourOwnRowKeepsYourPicture() {
        let row = QuestionnaireRowSummary(
            id: UUID(), title: "Weekend plans", creator: .you,
            questionCount: 3, answeredSomeCount: 2, answeredAllCount: 1, creatorImageURL: url
        )
        XCTAssertEqual(row.creatorImageURL, url)
    }

    /// An anonymous creator's is dropped, whatever the caller passed.
    func test_anAnonymousCreatorCarriesNoPicture() {
        let row = QuestionnaireRowSummary(
            id: UUID(), title: "Weekend plans", creator: .anonymous,
            questionCount: 3, answeredSomeCount: 2, answeredAllCount: 1, creatorImageURL: url
        )
        XCTAssertNil(
            row.creatorImageURL,
            "a row that refuses to name its creator carried their picture, which names them"
        )
    }

    /// A row from a server that predates the field decodes with none.
    func test_aRowWithoutTheKeyDecodes() throws {
        let json = """
        {"id":"\(UUID().uuidString)","title":"Weekend plans","normalisedTitleKey":"weekend plans",
         "creator":{"you":{}},"questionCount":3,"answeredSomeCount":2,"answeredAllCount":1}
        """
        let row = try JSONDecoder().decode(
            QuestionnaireRowSummary.self, from: Data(json.utf8)
        )
        XCTAssertNil(row.creatorImageURL)
        XCTAssertEqual(row.questionCount, 3)
    }
}
