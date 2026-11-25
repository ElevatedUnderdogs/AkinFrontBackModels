//
//  B27ModelsContractTests.swift
//  FrontBackModelsTests
//
//  Restores the questionnaire-detail picture field dropped after 142.93.1, and names the
//  member-profile count `subscriberCount` (never follower) because the endpoint never shipped
//  under the old spelling.
//

import XCTest
@testable import AkinFrontBackModels

final class B27ModelsContractTests: XCTestCase {

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

    private func sampleDetail(
        imageURL: String? = "https://example.com/sarah.jpg"
    ) -> QuestionnaireDetail {
        QuestionnaireDetail(
            questionnaireId: UUID(uuidString: "50C1A1C0-C0DE-57C0-ACDE-EC7EC7EC7EC7")!,
            title: "Example",
            creatorId: UUID(uuidString: "60C1A1C0-C0DE-57C0-ACDE-EC7EC7EC7EC7")!,
            authorVisibility: "attributed",
            questionIds: [],
            questions: [],
            importanceBreakdown: [],
            creatorName: "Sarah",
            creatorImageUrl: imageURL,
            respondentCount: 0,
            completionCount: 0,
            derivedImportance: nil,
            isRated: false
        )
    }

    /// Existing construction sites omit the new argument and still compile, with a nil picture.
    func testDetailDefaultsThePictureToNilWhenOmitted() {
        let detail = QuestionnaireDetail(
            questionnaireId: UUID(uuidString: "50C1A1C0-C0DE-57C0-ACDE-EC7EC7EC7EC7")!,
            title: "Example",
            creatorId: nil,
            authorVisibility: "anonymized",
            questionIds: [],
            questions: [],
            importanceBreakdown: [],
            creatorName: nil,
            respondentCount: 0,
            completionCount: 0,
            derivedImportance: nil,
            isRated: false
        )
        XCTAssertNil(detail.creatorImageUrl)
        XCTAssertNil(detail.creatorName)
    }

    /// The picture travels on the wire as `creator_image_url`, the same key the 142.93.0
    /// contract used, so a client that already reads it keeps working.
    func testDetailEncodesAndDecodesThePicture() throws {
        let encoded = try wireEncoder().encode(sampleDetail())
        let wire = try JSONDecoder().decode(QuestionnaireDetailWireProbe.self, from: encoded)
        XCTAssertEqual(wire.creatorImageURL, "https://example.com/sarah.jpg")
        XCTAssertEqual(wire.creatorName, "Sarah")
        let decoded = try wireDecoder().decode(QuestionnaireDetail.self, from: encoded)
        XCTAssertEqual(decoded.creatorImageUrl, "https://example.com/sarah.jpg")
        XCTAssertEqual(decoded.creatorName, "Sarah")
    }

    /// A payload written before this field existed still decodes, with a nil picture.
    func testDetailDecodesAPayloadThatOmitsThePicture() throws {
        let raw = """
        {"questionnaire_id":"50C1A1C0-C0DE-57C0-ACDE-EC7EC7EC7EC7","title":"Example",
         "creator_id":null,"author_visibility":"anonymized","question_ids":[],
         "questions":[],"importance_breakdown":[],"creator_name":null,
         "respondent_count":0,"completion_count":0,"derived_importance":null,"is_rated":false}
        """
        let decoded = try wireDecoder().decode(QuestionnaireDetail.self, from: Data(raw.utf8))
        XCTAssertNil(decoded.creatorImageUrl)
    }

    /// The count's Swift name and the snake-case wire key are both subscriber, never follower.
    func testProfileSummaryUsesSubscriberCountOnTheWire() throws {
        let id = UUID(uuidString: "70C1A1C0-C0DE-57C0-ACDE-EC7EC7EC7EC7")!
        let summary = MemberProfileSummary(memberId: id, subscriberCount: 4)
        XCTAssertEqual(summary.subscriberCount, 4)
        let encoded = try wireEncoder().encode(summary)
        let wire = try JSONDecoder().decode(MemberProfileSummaryWireProbe.self, from: encoded)
        XCTAssertEqual(wire.subscriberCount, 4)
        XCTAssertNil(wire.followerCount)
        let decoded = try wireDecoder().decode(MemberProfileSummary.self, from: encoded)
        XCTAssertEqual(decoded.subscriberCount, 4)
        XCTAssertEqual(decoded.memberId, id)
    }
}
