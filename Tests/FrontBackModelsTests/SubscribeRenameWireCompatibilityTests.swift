//
//  SubscribeRenameWireCompatibilityTests.swift
//  FrontBackModelsTests
//
//  Build 29 feedback, GOAL_LOOP37 box 31 and its decision D5. Scott's rule is that members
//  subscribe to each other rather than follow each other, so every Swift name in this package
//  moved from follow to subscribe. The WIRE did not move with it: a binary is already on members'
//  phones that sends and reads the follow spellings, and it cannot be recompiled.
//
//  These tests are the proof that the rename is a rename of names only. Each one names the thing
//  that breaks in front of a member if the string under test ever moves.
//

import XCTest
import StrongContractClient
@testable import AkinFrontBackModels

final class SubscribeRenameWireCompatibilityTests: XCTestCase {

    // MARK: - Helpers

    /// The process wide pair this app installs in `configure.swift`.
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

    /// Decode one bare JSON string as a reason.
    private func decodeReason(_ raw: String) throws -> NotificationReason {
        try JSONDecoder().decode(NotificationReason.self, from: Data("\"\(raw)\"".utf8))
    }

    // MARK: - A reason decodes under either spelling

    /// What the shipped App Store app sends, and what every row written before today holds.
    func testEveryReasonDecodesFromItsRetiredFollowSpelling() throws {
        XCTAssertEqual(NotificationReason.allCases.count, 4)
        for reason in NotificationReason.allCases {
            XCTAssertTrue(
                reason.rawValue.contains("Followed"),
                "\(reason) no longer writes a follow spelling, so a build in the field that reads "
                    + "this value has nothing to match: \(reason.rawValue)"
            )
            XCTAssertEqual(try decodeReason(reason.rawValue), reason)
        }
    }

    /// What a sender that has already moved to the new vocabulary says.
    func testEveryReasonDecodesFromItsSubscribeSpelling() throws {
        for reason in NotificationReason.allCases {
            XCTAssertTrue(reason.subscribeSpelling.contains("Subscribed"), reason.subscribeSpelling)
            XCTAssertNotEqual(reason.subscribeSpelling, reason.rawValue)
            XCTAssertEqual(try decodeReason(reason.subscribeSpelling), reason)
        }
    }

    /// The two spellings are distinct sets, so neither test above can be passing by accident.
    func testTheTwoSpellingsNeverCollide() {
        let retired = Set(NotificationReason.allCases.map(\.rawValue))
        let current = Set(NotificationReason.allCases.map(\.subscribeSpelling))
        XCTAssertEqual(retired.count, 4)
        XCTAssertEqual(current.count, 4)
        XCTAssertTrue(retired.isDisjoint(with: current))
    }

    /// A WIDENED contract, not a silent default: a value that is neither spelling still throws.
    func testAReasonThatIsNeitherSpellingStillFails() {
        XCTAssertThrowsError(try decodeReason("questionAddedByAMemberYouLike"))
        XCTAssertThrowsError(try decodeReason(""))
        XCTAssertThrowsError(try decodeReason("subscribed"))
    }

    /// Encoding writes the retired spelling, because the reader may be the shipped app.
    ///
    /// This assertion is the one to change on the day the old build is gone, and nothing else
    /// here has to change with it.
    func testEncodingStillWritesTheRetiredSpelling() throws {
        let data = try JSONEncoder().encode(NotificationReason.responseAddedBySubscribedMember)
        // This assertion is the one to change on the day the old build is gone.
        // literal-ok: the wire format fixes this string
        XCTAssertEqual(String(decoding: data, as: UTF8.self), "\"responseAddedByFollowedMember\"")
    }

    // MARK: - The payload a push carries

    /// A push body written by the shipped app's server decodes into the renamed type.
    func testAPushBodyWithTheRetiredReasonDecodes() throws {
        let text = "a question"
        let body = """
        {"reason":"questionAddedByFollowedMember",
         "subject":{"question":{"id":"50C1A1C0-C0DE-57C0-ACDE-EC7EC7EC7EC7","text":"\(text)"}},
         "questionnaire_id":null,"author_id":null}
        """
        let payload = try wireDecoder().decode(
            SubscribeNotificationPayload.self, from: Data(body.utf8)
        )
        XCTAssertEqual(payload.reason, .questionAddedBySubscribedMember)
        XCTAssertEqual(payload.subject.text, text)
    }

    /// And the same body under the new spelling, so the contract reads both.
    func testAPushBodyWithTheSubscribeReasonDecodes() throws {
        let body = """
        {"reason":"questionAddedBySubscribedMember",
         "subject":{"question":{"id":"50C1A1C0-C0DE-57C0-ACDE-EC7EC7EC7EC7","text":"a question"}},
         "questionnaire_id":null,"author_id":null}
        """
        let payload = try wireDecoder().decode(
            SubscribeNotificationPayload.self, from: Data(body.utf8)
        )
        XCTAssertEqual(payload.reason, .questionAddedBySubscribedMember)
    }

    func testAPushBodyWithNeitherSpellingStillFails() {
        let body = """
        {"reason":"questionAddedByNobody",
         "subject":{"question":{"id":"50C1A1C0-C0DE-57C0-ACDE-EC7EC7EC7EC7","text":"a question"}},
         "questionnaire_id":null,"author_id":null}
        """
        XCTAssertThrowsError(
            try wireDecoder().decode(SubscribeNotificationPayload.self, from: Data(body.utf8))
        )
    }

    /// A payload still survives the round trip it survived before the rename.
    func testThePayloadStillRoundTrips() throws {
        let payload = SubscribeNotificationPayload(
            reason: .questionAddedToSubscribedQuestionnaire,
            subject: .question(id: UUID(), text: "what does the round trip prove"),
            questionnaireId: UUID(),
            author: DisclosedAuthor(author: UUID(), visibility: .attributed)
        )
        let data = try wireEncoder().encode(payload)
        XCTAssertEqual(
            try wireDecoder().decode(SubscribeNotificationPayload.self, from: data), payload
        )
    }

    // MARK: - The preferences list a member's screen draws

    func testPreferencesDecodeDisabledReasonsInEitherSpelling() throws {
        let retired = """
        {"disabled_reasons":["questionAddedByFollowedMember","responseAddedByFollowedMember"]}
        """
        let current = """
        {"disabled_reasons":["questionAddedBySubscribedMember","responseAddedBySubscribedMember"]}
        """
        let expected: [NotificationReason] = [
            .questionAddedBySubscribedMember, .responseAddedBySubscribedMember
        ]
        for body in [retired, current] {
            let prefs = try wireDecoder().decode(
                SubscribeNotificationPreferences.self, from: Data(body.utf8)
            )
            XCTAssertEqual(prefs.disabledReasons, expected, body)
            XCTAssertFalse(prefs.isEnabled(.questionAddedBySubscribedMember), body)
            XCTAssertTrue(prefs.isEnabled(.questionnaireAddedBySubscribedMember), body)
        }
    }

    func testPreferencesRejectAReasonInNeitherSpelling() {
        let body = """
        {"disabled_reasons":["questionAddedByFollowingMember"]}
        """
        XCTAssertThrowsError(
            try wireDecoder().decode(
                SubscribeNotificationPreferences.self, from: Data(body.utf8)
            )
        )
    }

    // MARK: - The push categories both ends register

    /// The server sets these on the push and the shipped app registers its categories under them.
    /// A mismatch is a notification drawn as a bare alert with no summary and no action.
    func testThePushCategoryAndActionIdentifiersDidNotMove() {
        XCTAssertEqual(
            NotificationReason.questionAddedToSubscribedQuestionnaire
                .notificationCategoryIdentifier,
            "follow.questionnaire.questions"
        )
        XCTAssertEqual(
            NotificationReason.questionAddedBySubscribedMember.notificationCategoryIdentifier,
            "follow.member.content"
        )
        XCTAssertEqual(
            NotificationReason.questionnaireAddedBySubscribedMember.notificationCategoryIdentifier,
            "follow.member.content"
        )
        XCTAssertEqual(
            NotificationReason.responseAddedBySubscribedMember.notificationCategoryIdentifier,
            "follow.member.responses"
        )
        XCTAssertEqual(
            NotificationReason.notificationActionIdentifier, "follow.choose-what-arrives"
        )
    }

    // MARK: - The routes the shipped app calls

    /// A path in this package IS the static accessor's own name, so the rename moved two live
    /// routes. Both spellings exist and both resolve to the same request.
    func testBothSpellingsOfTheNotificationPreferenceRoutesAreServed() {
        let readNew = SubscribeNotificationPreferencesRequest.subscribeNotificationPreferences
        let readOld = SubscribeNotificationPreferencesRequest.followNotificationPreferences
        // A path here IS the accessor's own name, so each string below is the route path
        // itself. The follow spellings are what the shipped App Store app asks for.
        // literal-ok: the route path fixes this string
        XCTAssertEqual(readNew.path, "subscribeNotificationPreferences")
        // literal-ok: the route path fixes this string
        XCTAssertEqual(readOld.path, "followNotificationPreferences")
        XCTAssertEqual(readNew.method, readOld.method)

        let setNew = SetSubscribeNotificationPreferenceRequest.setSubscribeNotificationPreference
        let setOld = SetSubscribeNotificationPreferenceRequest.setFollowNotificationPreference
        // literal-ok: the route path fixes this string
        XCTAssertEqual(setNew.path, "setSubscribeNotificationPreference")
        // literal-ok: the route path fixes this string
        XCTAssertEqual(setOld.path, "setFollowNotificationPreference")
        XCTAssertEqual(setNew.method, setOld.method)
    }
}

/// The stored keys the server's `reviewed_flag_settings` rows are keyed on.
///
/// GOAL_LOOP34 item 0.F1 shipped the GL29 features OFF in production by writing one fact in two
/// places. This is the same hazard from the other side: the Swift declarations were renamed to
/// subscribe and these keys were not, because a key that changes is a flag whose stored value and
/// whose per member override stop being found.
final class ReviewedFeatureFlagStoredKeyTests: XCTestCase {

    func testTheTwoRenamedFlagsKeepTheirRetiredStoredKeys() {
        XCTAssertEqual(
            ReviewedFeatureFlag.Feature.subscribedMembers.propertyName,
            "isFollowingMembersEnabled"
        )
        XCTAssertEqual(
            ReviewedFeatureFlag.Feature.subscribedQuestionnaires.propertyName,
            "isFollowingQuestionnairesEnabled"
        )
    }

    /// No stored key anywhere picked up the new vocabulary, which is what a later rename run over
    /// this file would do to them.
    func testNoStoredKeyNamesSubscribe() {
        for feature in ReviewedFeatureFlag.Feature.allCases {
            XCTAssertFalse(
                feature.propertyName.lowercased().contains("subscri"),
                "\(feature.rawValue)'s stored key moved to \(feature.propertyName), so every row "
                    + "already written under its old key is now unreachable"
            )
        }
    }

    /// The declaration and the stored key differ for exactly the two flags that were renamed, and
    /// agree everywhere else. Without this, a third flag could drift apart unnoticed.
    func testTheDeclarationAndTheStoredKeyDifferForExactlyTheTwoRenamedFlags() {
        let differing = ReviewedFeatureFlag.Feature.allCases.filter {
            $0.declaredPropertyName != $0.propertyName
        }
        XCTAssertEqual(
            Set(differing), [.subscribedMembers, .subscribedQuestionnaires],
            "\(differing.map(\.rawValue))"
        )
        XCTAssertEqual(
            ReviewedFeatureFlag.Feature.subscribedMembers.declaredPropertyName,
            "isSubscribedMembersEnabled"
        )
        XCTAssertEqual(
            ReviewedFeatureFlag.Feature.subscribedQuestionnaires.declaredPropertyName,
            "isSubscribedQuestionnairesEnabled"
        )
    }
}
