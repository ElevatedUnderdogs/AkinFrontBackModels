//
//  AuthorSummaryContractTests.swift
//  AkinFrontBackModelsTests
//
//  GOAL_LOOP14 F1.2. Looking at a question there was no way to see who wrote it,
//  and the same was true of every response. The reason was not the views: the
//  wire types carried a creator's UUID and nothing a person could read, so a
//  client wanting a name had a round trip per row and drew nothing instead.
//
//  All three content kinds now carry the same optional `AuthorSummary`. These
//  tests assert the contract that makes it safe: present means disclosed,
//  absent means not, and the two can never disagree with the id field beside
//  them.
//

import XCTest

@testable import AkinFrontBackModels

final class AuthorSummaryContractTests: XCTestCase {

    private let author = AuthorSummary(
        id: UUID(),
        displayName: "Jeff Crypto",
        profileImageURL: "https://imagedelivery.net/x/y/public"
    )

    private func question(author: AuthorSummary?, creatorID: UUID?) -> Question {
        Question(
            text: "How do you define success?",
            id: UUID(),
            creatorID: creatorID,
            originalContext: Context(id: UUID(), case: .social),
            defaultCompatibilityRule: .weighted,
            assessment: ModerationAssessment(entries: []),
            authorVisibility: author == nil ? .anonymized : .attributed,
            author: author
        )
    }

    private func response(author: AuthorSummary?, creator: UUID?) -> Question.Response {
        Question.Response(
            text: "By whether I would do it again",
            timeStamp: Date(),
            id: UUID(),
            creator: creator,
            questionID: UUID(),
            originalContextID: UUID(),
            assessment: ModerationAssessment(entries: []),
            author: author
        )
    }

    private func questionnaire(author: AuthorSummary?) -> Questionnaire {
        Questionnaire(
            id: UUID(),
            title: "First date questions",
            creatorID: UUID(),
            contextID: UUID(),
            createdAt: Date(),
            questionIDs: [UUID()],
            authorVisibility: author == nil ? .anonymized : .attributed,
            author: author
        )
    }

    // MARK: - All three carry a displayable author

    /// The F1.2 verification: a non-nil, displayable author survives a round
    /// trip on each of the three content kinds.
    func testAllThreeContentKindsRoundTripADisclosedAuthor() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let decodedQuestion = try decoder.decode(
            Question.self, from: try encoder.encode(question(author: author, creatorID: author.id))
        )
        let decodedResponse = try decoder.decode(
            Question.Response.self, from: try encoder.encode(response(author: author, creator: author.id))
        )
        let decodedQuestionnaire = try decoder.decode(
            Questionnaire.self, from: try encoder.encode(questionnaire(author: author))
        )

        for summary in [decodedQuestion.author, decodedResponse.author, decodedQuestionnaire.author] {
            let unwrapped = try XCTUnwrap(summary, "an author that was sent did not survive decoding")
            XCTAssertEqual(unwrapped.id, author.id)
            XCTAssertEqual(unwrapped.displayName, "Jeff Crypto")
            XCTAssertFalse(
                unwrapped.resolvedDisplayName.isEmpty,
                "a chip drawn from this would have no text"
            )
        }
    }

    // MARK: - Absent is a meaning, not a gap

    /// An undisclosed author is absent, and decoding must not invent one.
    ///
    /// The two serializers that previously had to produce something for the
    /// undisclosed case produced different things: one published the real
    /// author, the other a fresh random UUID. The first was a leak and the
    /// second was fabricated data presented as an identifier.
    func testAnUndisclosedAuthorDecodesAsAbsentRatherThanInvented() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let decodedQuestion = try decoder.decode(
            Question.self, from: try encoder.encode(question(author: nil, creatorID: nil))
        )
        let decodedResponse = try decoder.decode(
            Question.Response.self, from: try encoder.encode(response(author: nil, creator: nil))
        )
        let decodedQuestionnaire = try decoder.decode(
            Questionnaire.self, from: try encoder.encode(questionnaire(author: nil))
        )

        XCTAssertNil(decodedQuestion.author)
        XCTAssertNil(decodedResponse.author)
        XCTAssertNil(decodedQuestionnaire.author)
    }

    /// A payload written by a client that predates this field still decodes.
    ///
    /// Every already-shipped client sends no such key. A non-optional field
    /// here would have made all of them fail to post at all, which is the same
    /// trap `authorVisibility`'s own doc comment records.
    func testAPayloadWithoutTheFieldStillDecodes() throws {
        let json = """
            {
              "text": "How do you define success?",
              "responses": [],
              "id": "\(UUID().uuidString)",
              "originalContext": {"id": "\(UUID().uuidString)", "case": "social", "rawValue": "social"},
              "defaultCompatibilityRule": "weighted",
              "assessment": {"entries": []},
              "requirementsFor": [],
              "importanceFor": {},
              "contextPopularity": {}
            }
            """
        let decoded = try JSONDecoder().decode(Question.self, from: Data(json.utf8))
        XCTAssertNil(decoded.author, "absent must mean absent, not a default that names somebody")
        XCTAssertNil(decoded.creatorID)
    }

    // MARK: - A chip never renders as a broken control

    /// F1.8's contract at the model level: a member with no name still reads as
    /// a person rather than as an avatar beside nothing.
    func testABlankDisplayNameFallsBackRatherThanRenderingEmpty() {
        for blank in ["", "   ", "\n\t "] {
            let summary = AuthorSummary(id: UUID(), displayName: blank)
            XCTAssertEqual(
                summary.resolvedDisplayName, AuthorSummary.unnamedFallback,
                "a blank name would draw an avatar beside nothing, which reads as a bug"
            )
        }
    }

    func testARealNameIsTrimmedButOtherwiseUntouched() {
        let summary = AuthorSummary(id: UUID(), displayName: "  Scott Lydon  ")
        XCTAssertEqual(summary.resolvedDisplayName, "Scott Lydon")
    }

    /// The picture is optional, because plenty of members do not have one, and
    /// its absence must not stop the name being drawn.
    func testAnAuthorWithoutAPictureIsStillDrawable() {
        let summary = AuthorSummary(id: UUID(), displayName: "Priya")
        XCTAssertNil(summary.profileImageURL)
        XCTAssertEqual(summary.resolvedDisplayName, "Priya")
    }

    /// A malformed image URL is carried rather than rejected, so one bad row
    /// cannot fail the decode of the content it belongs to.
    func testAMalformedImageURLDoesNotBreakDecoding() throws {
        let summary = AuthorSummary(id: UUID(), displayName: "Marcus", profileImageURL: "not a url")
        let decoded = try JSONDecoder().decode(
            AuthorSummary.self, from: try JSONEncoder().encode(summary)
        )
        XCTAssertEqual(decoded.profileImageURL, "not a url")
        XCTAssertEqual(decoded.resolvedDisplayName, "Marcus")
    }
}
