import XCTest
@testable import AkinFrontBackModels

// Swath N2 (item 5.1). The round trip test exists because this exact defect was shipped twice in
// this expansion already: a Codable property whose name ends in a capitalised acronym encodes to
// `foo_id` under `.convertToSnakeCase` and then decodes back as `fooId`, which is a different
// property, so the decode fails. Both strategies are installed process wide in the server's
// `configure.swift`, so every payload crossing the wire meets them.
final class FollowNotificationsTests: XCTestCase {

    private func wireEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }

    private func wireDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    func testPayloadSurvivesTheSnakeCaseRoundTrip() throws {
        let payload = FollowNotificationPayload(
            reason: .questionAddedToFollowedQuestionnaire,
            questionId: UUID(),
            questionText: "what does the round trip prove",
            questionnaireId: UUID(),
            authorId: UUID()
        )
        let data = try wireEncoder().encode(payload)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        // The keys the client will actually see.
        XCTAssertTrue(json.contains("\"question_id\""), json)
        XCTAssertTrue(json.contains("\"questionnaire_id\""), json)
        XCTAssertTrue(json.contains("\"author_id\""), json)
        let decoded = try wireDecoder().decode(FollowNotificationPayload.self, from: data)
        XCTAssertEqual(decoded, payload)
    }

    func testPayloadWithoutAnAuthorSurvivesTheRoundTrip() throws {
        // The `.silent` and `.unattributedAnnounced` shape: no author disclosed.
        let payload = FollowNotificationPayload(
            reason: .questionAddedByFollowedMember,
            questionId: UUID(),
            questionText: "written by someone who chose not to be named",
            questionnaireId: nil,
            authorId: nil
        )
        let decoded = try wireDecoder().decode(
            FollowNotificationPayload.self, from: try wireEncoder().encode(payload)
        )
        XCTAssertEqual(decoded, payload)
        XCTAssertNil(decoded.authorId)
    }

    func testTargetSurvivesTheRoundTripAsEitherKind() throws {
        for target in [SubscriptionTarget.questionnaire(UUID()), .member(UUID())] {
            let decoded = try wireDecoder().decode(
                SubscriptionTarget.self, from: try wireEncoder().encode(target)
            )
            XCTAssertEqual(decoded, target)
            XCTAssertEqual(decoded.targetID, target.targetID)
            XCTAssertEqual(decoded.kind, target.kind)
        }
    }

    /// Proves the round trip tests above are not vacuous.
    ///
    /// A local struct spelled the way the payload was spelled first. It encodes without complaint
    /// and then cannot be read back, which is the failure the `Id` spelling avoids. If Foundation
    /// ever makes the two strategies inverse, this test fails and the comments above become
    /// obsolete, which is the right way to find that out.
    func testTheAcronymSpellingIsWhatBreaks() throws {
        struct SpelledTheBrokenWay: Codable, Equatable {
            let questionID: UUID
        }
        let subject = SpelledTheBrokenWay(questionID: UUID())
        let data = try wireEncoder().encode(subject)
        XCTAssertTrue(try XCTUnwrap(String(data: data, encoding: .utf8)).contains("\"question_id\""))
        XCTAssertThrowsError(try wireDecoder().decode(SpelledTheBrokenWay.self, from: data)) { error in
            guard case DecodingError.keyNotFound(let key, _) = error else {
                return XCTFail("expected a missing key, got \(error)")
            }
            // The reported key is the one the type declares, not the one the JSON carried:
            // `.convertFromSnakeCase` turned `question_id` into `questionId`, found no such coding
            // key, and named the key it wanted. That is exactly the one-letter mismatch.
            XCTAssertEqual(key.stringValue, "questionID")
        }
    }

    func testEveryReasonCarriesAnExplanation() {
        for reason in NotificationReason.allCases {
            XCTAssertFalse(reason.explanation.isEmpty, "\(reason) has no explanation")
        }
    }
}

// Swath N3 (item 6.3). The compatibility claim the optional makes is worth a test rather than a
// comment: a client that predates the field must still be able to post a question.
final class QuestionAuthorVisibilityContractTests: XCTestCase {

    func testAQuestionWithoutTheFieldStillDecodes() throws {
        // The legacy payload is produced by encoding a real Question and deleting the one key,
        // rather than by hand written JSON. Hand written JSON gets the shape of the other fields
        // wrong (`requirementsFor` is keyed by Context, so it encodes as an array, not an object)
        // and then the test fails for a reason that has nothing to do with what it is checking.
        let question = Question(
            text: "posted by a client that predates the field",
            id: UUID(),
            creatorID: UUID(),
            originalContext: Context(id: UUID(), case: .social),
            defaultCompatibilityRule: .weighted,
            assessment: ModerationAssessment(entries: []),
            authorVisibility: .attributed
        )
        var object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: try JSONEncoder().encode(question)) as? [String: Any]
        )
        XCTAssertNotNil(object["authorVisibility"], "the key must be there before it is removed")
        object.removeValue(forKey: "authorVisibility")

        let decoded = try JSONDecoder().decode(
            Question.self, from: try JSONSerialization.data(withJSONObject: object)
        )
        XCTAssertNil(
            decoded.authorVisibility,
            "absent must mean the creator did not choose, not a decode failure"
        )
        XCTAssertEqual(decoded.id, question.id, "the rest of the payload must survive untouched")
    }

    func testAQuestionCarryingTheFieldRoundTrips() throws {
        for visibility in AuthorVisibility.allCases {
            let question = Question(
                text: "a question at \(visibility.rawValue)",
                id: UUID(),
                creatorID: UUID(),
                originalContext: Context(id: UUID(), case: .social),
                defaultCompatibilityRule: .weighted,
                assessment: ModerationAssessment(entries: []),
                authorVisibility: visibility
            )
            let decoded = try JSONDecoder().decode(
                Question.self, from: try JSONEncoder().encode(question)
            )
            XCTAssertEqual(decoded.authorVisibility, visibility)
        }
    }
}

// Swath N3 item 6.5. The contract half of the disclosure rule: the type must be able to say
// "no author", or every serializer has to invent a value for the undisclosed case.
final class UndisclosedAuthorContractTests: XCTestCase {

    private func question(creator: UUID?) -> Question {
        Question(
            text: "a question \(UUID())",
            id: UUID(),
            creatorID: creator,
            originalContext: Context(id: UUID(), case: .social),
            defaultCompatibilityRule: .weighted,
            assessment: ModerationAssessment(entries: [])
        )
    }

    func testAQuestionWithNoDisclosedAuthorOmitsTheKeyEntirely() throws {
        let data = try JSONEncoder().encode(question(creator: nil))
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        // Absent, not null and not an empty string. Item 6.6 asks for "no author field at all,
        // not an empty one", and a client distinguishing null from absent is a client that has
        // been handed a distinction it should never have needed.
        XCTAssertFalse(json.contains("creatorID"), "an undisclosed author must not appear: \(json)")
        let decoded = try JSONDecoder().decode(Question.self, from: data)
        XCTAssertNil(decoded.creatorID)
    }

    func testAQuestionWithADisclosedAuthorCarriesIt() throws {
        let creator = UUID()
        let data = try JSONEncoder().encode(question(creator: creator))
        XCTAssertTrue(try XCTUnwrap(String(data: data, encoding: .utf8)).contains(creator.uuidString))
        XCTAssertEqual(try JSONDecoder().decode(Question.self, from: data).creatorID, creator)
    }
}
