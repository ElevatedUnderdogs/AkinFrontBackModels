import XCTest
@testable import AkinFrontBackModels

// Swath N4 item 7.1. The contracts, and the wire format they have to survive.
final class MatchmakingProfileTests: XCTestCase {

    private func wireEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private func wireDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private func profile(name: String = "badminton", isActive: Bool = false) -> MatchmakingProfile {
        MatchmakingProfile(
            id: UUID(),
            ownerId: UUID(),
            contextId: UUID(),
            name: name,
            isActive: isActive,
            createdAt: Date(timeIntervalSince1970: 1_770_000_000)
        )
    }

    /// The round trip, under the coders the server actually installs.
    ///
    /// This is the fourth type in this expansion to need this test, because the same acronym-tail
    /// defect has been shipped three times: a property ending `ID` encodes to `..._id` and decodes
    /// back as `...Id`, a different coding key, so the payload is unreadable by a client using the
    /// same coders. Asserting the key names is what makes the spelling non-negotiable.
    func testTheProfileSurvivesTheSnakeCaseRoundTrip() throws {
        let subject = profile()
        let data = try wireEncoder().encode(subject)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        for key in ["owner_id", "context_id", "is_active", "created_at"] {
            XCTAssertTrue(json.contains("\"\(key)\""), "expected \(key) in \(json)")
        }
        XCTAssertEqual(try wireDecoder().decode(MatchmakingProfile.self, from: data), subject)
    }

    func testASelectionSurvivesTheSnakeCaseRoundTrip() throws {
        let subject = ProfileSelection(
            profileId: UUID(), questionId: UUID(), responseId: UUID(),
            side: .their, selection: "YES", importance: 7
        )
        let data = try wireEncoder().encode(subject)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        for key in ["profile_id", "question_id", "response_id", "side"] {
            XCTAssertTrue(json.contains("\"\(key)\""), "expected \(key) in \(json)")
        }
        XCTAssertEqual(try wireDecoder().decode(ProfileSelection.self, from: data), subject)
    }

    /// A selection with no importance override omits the key rather than sending a number.
    ///
    /// An override that defaults to a value cannot be told from one the member chose. Item 7.6
    /// makes duplication the cheapest way to build a profile, so most selections carry no
    /// override and the absent case is the common one, not the edge one.
    func testAnAbsentImportanceOverrideIsAbsentOnTheWire() throws {
        let subject = ProfileSelection(
            profileId: UUID(), questionId: UUID(), responseId: UUID(), side: .my, selection: "NO"
        )
        let data = try wireEncoder().encode(subject)
        XCTAssertFalse(
            try XCTUnwrap(String(data: data, encoding: .utf8)).contains("importance"),
            "an absent override must not appear at all"
        )
        let decoded = try wireDecoder().decode(ProfileSelection.self, from: data)
        XCTAssertNil(decoded.importance)
        XCTAssertEqual(decoded, subject)
    }

    /// Two profiles differing only in name are different values.
    ///
    /// Guards the equality the tests above rely on: a Hashable synthesised over a subset of fields
    /// would make the round trip assertions pass while dropping data.
    func testProfilesAreDistinguishedByEveryField() {
        let base = profile()
        for altered in [
            MatchmakingProfile(id: base.id, ownerId: base.ownerId, contextId: base.contextId,
                               name: "other", isActive: base.isActive, createdAt: base.createdAt),
            MatchmakingProfile(id: base.id, ownerId: base.ownerId, contextId: base.contextId,
                               name: base.name, isActive: !base.isActive, createdAt: base.createdAt),
            MatchmakingProfile(id: base.id, ownerId: UUID(), contextId: base.contextId,
                               name: base.name, isActive: base.isActive, createdAt: base.createdAt)
        ] {
            XCTAssertNotEqual(altered, base)
        }
    }
}

// Swath N3 finding B1. A response can say it has no disclosed author.
final class UndisclosedResponseAuthorTests: XCTestCase {

    private func response(creator: UUID?) -> Question.Response {
        Question.Response(
            text: "an answer",
            timeStamp: Date(timeIntervalSince1970: 1_770_000_000),
            id: UUID(),
            creator: creator,
            questionID: UUID(),
            originalContextID: UUID(),
            assessment: ModerationAssessment(entries: [])
        )
    }

    func testAnUndisclosedResponseAuthorIsAbsentRatherThanInvented() throws {
        let data = try JSONEncoder().encode(response(creator: nil))
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertFalse(json.contains("\"creator\""), "an undisclosed author must not appear: \(json)")
        XCTAssertNil(try JSONDecoder().decode(Question.Response.self, from: data).creator)
    }

    func testADisclosedResponseAuthorSurvives() throws {
        let creator = UUID()
        let decoded = try JSONDecoder().decode(
            Question.Response.self, from: try JSONEncoder().encode(response(creator: creator))
        )
        XCTAssertEqual(decoded.creator, creator)
    }
}
