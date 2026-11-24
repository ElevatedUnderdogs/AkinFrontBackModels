//
//  PathParameterRoutes.swift
//  AkinFrontBackModels
//
//  2026-11-23. Thirteen server routes were registered by string (`routes.post("api", "user",
//  ":id", ...)`), so the path lived only in the server and in a hand written copy in the app.
//  Each one is declared here instead, with the SAME method and path it already answers on, so
//  no shipped or TestFlight build is affected. A `:name` component is a path parameter: the
//  server turns it into a Vapor parameter, exactly as the string form did.
//
//  The server registers each with `Request.<name>.register(app:use:)`, which takes its method
//  and path from this file. Response is `Data` because each of these answers with a status code
//  (or a body the caller reads raw) rather than a JSON type the client decodes.
//

import Foundation
import StrongContractClient

// MARK: - Payloads

/// What the app posts when a member types the six digit code from their verification email.
public struct VerifyEmailCodePayload: Codable, Hashable, Sendable {
    public let email: String
    public let code: String

    public init(email: String, code: String) {
        self.email = email
        self.code = code
    }
}

/// Debug deployments only: put a member's subscription into a chosen tier.
public struct SubscriptionDebugSetTierPayload: Codable, Hashable, Sendable {
    /// Sent as `"userID"`, the key the server's debug route has always read. The property is
    /// spelled `userId` so this type does not join the `...ID` spelling hazard list.
    public let userId: UUID
    /// "free", "plus", or "pro". "free" revokes every subscription row the member has.
    public let tier: String
    /// Defaults to a year out on the server when absent.
    public let expiresAt: Date?

    private enum CodingKeys: String, CodingKey {
        case userId = "userID"
        case tier
        case expiresAt
    }

    public init(userId: UUID, tier: String, expiresAt: Date? = nil) {
        self.userId = userId
        self.tier = tier
        self.expiresAt = expiresAt
    }
}

// MARK: - No body

public typealias PathOnlyRequest = Request<Empty, Data>
extension PathOnlyRequest {

    /// DELETE. Permanently removes the caller's answers to a WITHDRAWN questionnaire.
    public static var deleteMyQuestionnaireAnswers: Self {
        .init(path: "api/user/:id/questionnaires/:questionnaireID/my-answers", method: .delete)
    }

    /// POST. The caller subscribes to another member.
    public static var subscribeToMember: Self {
        .init(path: "api/user/:id/members/:memberID/subscription", method: .post)
    }

    /// POST. The pre build 29 spelling of `subscribeToMember`, kept for builds still installed.
    public static var subscribeToMemberLegacyFollowing: Self {
        .init(path: "api/user/:id/following/:memberID", method: .post)
    }

    /// DELETE. The caller unsubscribes from another member.
    public static var unsubscribeFromMember: Self {
        .init(path: "api/user/:id/members/:memberID/subscription", method: .delete)
    }

    /// DELETE. The pre build 29 spelling of `unsubscribeFromMember`.
    public static var unsubscribeFromMemberLegacyFollowing: Self {
        .init(path: "api/user/:id/following/:memberID", method: .delete)
    }

    /// GET. Debug deployments only: the member's subscription rows (`?userID=`).
    public static var subscriptionDebugState: Self {
        .init(path: "debug/subscription/state", method: .get)
    }
}

// MARK: - JSON body

public typealias SetMemberSubscriptionMutedRequest = Request<SetMutedRequest, Data>
extension SetMemberSubscriptionMutedRequest {

    /// PUT. Silence, or un-silence, a subscription to a member without giving it up.
    public static var setMemberSubscriptionMuted: Self {
        .init(path: "api/user/:id/members/:memberID/subscription/muted", method: .put)
    }

    /// PUT. The pre build 29 spelling of `setMemberSubscriptionMuted`.
    public static var setMemberSubscriptionMutedLegacyFollowing: Self {
        .init(path: "api/user/:id/following/:memberID/muted", method: .put)
    }
}

public typealias VerifyEmailCodeRequest = Request<VerifyEmailCodePayload, Data>
extension VerifyEmailCodeRequest {

    /// POST, unauthenticated and rate limited. Verify an address with the typed six digit code.
    public static var verifyEmailCode: Self {
        .init(path: "api/verifyEmailCode", method: .post, assertHasAccessToken: false)
    }
}

public typealias SubscriptionDebugSetTierContract = Request<SubscriptionDebugSetTierPayload, Data>
extension SubscriptionDebugSetTierContract {

    /// POST. Debug deployments only: set a member's subscription tier.
    public static var subscriptionDebugSetTier: Self {
        .init(path: "debug/subscription/setTier", method: .post)
    }
}

// MARK: - Raw file body

public typealias PublicFileUploadRequest = Request<Data, Data>
extension PublicFileUploadRequest {

    /// POST. Writes the body bytes to the public directory under `:filename`.
    public static var uploadPublicFile: Self {
        .init(path: "api/upload/public/:filename", method: .post)
    }

    /// POST. Replaces the public terms of service file with the body bytes.
    public static var uploadTermsOfService: Self {
        .init(path: "api/upload/public/termsOfService", method: .post)
    }

    /// POST. Replaces the public contact info file with the body bytes.
    public static var uploadContactInfo: Self {
        .init(path: "api/upload/public/contactInfo", method: .post)
    }
}
