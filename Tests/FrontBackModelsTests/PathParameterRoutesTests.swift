//
//  PathParameterRoutesTests.swift
//  2026-11-23. These contracts replace string routes on the server, so a changed path or method
//  here is a 404 or 405 for every installed build. Pin both.
//

import XCTest
import StrongContractClient
@testable import AkinFrontBackModels

final class PathParameterRoutesTests: XCTestCase {

    func testPathsAndMethodsMatchTheRoutesTheyReplaced() {
        let expected: [(String, StrongContractClient.HTTPMethod, String)] = [
            (PathOnlyRequest.deleteMyQuestionnaireAnswers.path, PathOnlyRequest.deleteMyQuestionnaireAnswers.method,
             "DELETE api/user/:id/questionnaires/:questionnaireID/my-answers"),
            (PathOnlyRequest.subscribeToMember.path, PathOnlyRequest.subscribeToMember.method,
             "POST api/user/:id/members/:memberID/subscription"),
            (PathOnlyRequest.subscribeToMemberLegacyFollowing.path, PathOnlyRequest.subscribeToMemberLegacyFollowing.method,
             "POST api/user/:id/following/:memberID"),
            (PathOnlyRequest.unsubscribeFromMember.path, PathOnlyRequest.unsubscribeFromMember.method,
             "DELETE api/user/:id/members/:memberID/subscription"),
            (PathOnlyRequest.unsubscribeFromMemberLegacyFollowing.path, PathOnlyRequest.unsubscribeFromMemberLegacyFollowing.method,
             "DELETE api/user/:id/following/:memberID"),
            (PathOnlyRequest.subscriptionDebugState.path, PathOnlyRequest.subscriptionDebugState.method,
             "GET debug/subscription/state"),
            (SetMemberSubscriptionMutedRequest.setMemberSubscriptionMuted.path, SetMemberSubscriptionMutedRequest.setMemberSubscriptionMuted.method,
             "PUT api/user/:id/members/:memberID/subscription/muted"),
            (SetMemberSubscriptionMutedRequest.setMemberSubscriptionMutedLegacyFollowing.path,
             SetMemberSubscriptionMutedRequest.setMemberSubscriptionMutedLegacyFollowing.method,
             "PUT api/user/:id/following/:memberID/muted"),
            (VerifyEmailCodeRequest.verifyEmailCode.path, VerifyEmailCodeRequest.verifyEmailCode.method,
             "POST api/verifyEmailCode"),
            (SubscriptionDebugSetTierContract.subscriptionDebugSetTier.path, SubscriptionDebugSetTierContract.subscriptionDebugSetTier.method,
             "POST debug/subscription/setTier"),
            (PublicFileUploadRequest.uploadPublicFile.path, PublicFileUploadRequest.uploadPublicFile.method,
             "POST api/upload/public/:filename"),
            (PublicFileUploadRequest.uploadTermsOfService.path, PublicFileUploadRequest.uploadTermsOfService.method,
             "POST api/upload/public/termsOfService"),
            (PublicFileUploadRequest.uploadContactInfo.path, PublicFileUploadRequest.uploadContactInfo.method,
             "POST api/upload/public/contactInfo"),
        ]
        XCTAssertEqual(expected.count, 13)
        for (path, method, want) in expected {
            // literal-ok: the wire format fixes this string; these are the paths installed builds call
            XCTAssertEqual("\(method.rawValue) \(path)", want)
        }
    }

    func testVerifyEmailCodePayloadMatchesTheBodyTheAppSends() throws {
        let data = try JSONEncoder().encode(VerifyEmailCodePayload(email: "a@b.c", code: "123456"))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: String])
        XCTAssertEqual(object, ["email": "a@b.c", "code": "123456"])
    }
}

final class SubscriptionDebugSetTierPayloadWireTests: XCTestCase {
    func testUserIdTravelsUnderTheKeyTheServerReads() throws {
        let id = UUID()
        let data = try JSONEncoder().encode(SubscriptionDebugSetTierPayload(userId: id, tier: "plus"))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["userID"] as? String, id.uuidString)
        // literal-ok: the wire format fixes this string
        XCTAssertEqual(object["tier"] as? String, "plus")
    }
}
