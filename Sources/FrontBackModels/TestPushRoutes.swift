//
//  TestPushRoutes.swift
//  AkinFrontBackModels
//
//  Moved from the server's ApiController so the app and the server share them.
//

import Foundation
import StrongContractClient

/// A push the caller sends to their own device to check delivery.
public struct TestPushPayload<T: Codable>: Codable {
    public var title: String
    public var body: String
    public var payload: T

    public init(title: String, body: String, payload: T) {
        self.title = title
        self.body = body
        self.payload = payload
    }
}

public typealias TestPushRequest = Request<TestPushPayload<String>, StandardPostResponse>
extension TestPushRequest {
    /// Sends a regular push to the caller's device.
    public static var testPushRequest: Self {
        .init(method: .post)
    }
}

public typealias TestPushKitRequest = Request<TestPushPayload<String>, StandardPostResponse>
extension TestPushKitRequest {
    /// Sends a VoIP push to the caller's device.
    public static var testPushKitRequest: Self {
        .init(method: .post)
    }
}

/// The advertiser dashboard's sign-in body.
public struct AdvertiserLoginPayload: Codable, Sendable {
    public let email: String
    public let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

/// The bearer token an advertiser signs in for.
public struct AdvertiserTokenResponse: Codable, Sendable {
    public let token: String

    public init(token: String) {
        self.token = token
    }
}

/// Who the advertiser token belongs to.
public struct AdvertiserMeResponse: Codable, Equatable, Sendable {
    public let email: String

    public init(email: String) {
        self.email = email
    }
}

public typealias AdvertiserLoginRequest = Request<AdvertiserLoginPayload, AdvertiserTokenResponse>
extension AdvertiserLoginRequest {
    /// Signs an advertiser in.
    public static var advertiserLogin: Self { .init(method: .post, assertHasAccessToken: false) }
}

public typealias AdvertiserMeRequest = Request<Empty, AdvertiserMeResponse>
extension AdvertiserMeRequest {
    /// The signed-in advertiser.
    public static var advertiserMe: Self { .init(method: .get) }
}
