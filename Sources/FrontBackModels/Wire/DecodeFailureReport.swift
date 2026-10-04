//
//  DecodeFailureReport.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP28 item 1.6. What the app tells the server when it cannot read a reply.
//
//  Note B17-01 was diagnosed from a SCREENSHOT of a red box, because the only record of the
//  failure was `Logger.default` on the member's own phone, which a TestFlight build keeps to
//  itself. The endpoint, the coding key and what was actually on the wire all existed at the
//  moment of failure and all died there.
//
//  PRIVACY, which decides this type's shape rather than being bolted onto it:
//
//  * The excerpt is BOUNDED, hard, at `maxExcerptBytes`. Not "usually short": the type cannot
//    represent a longer one, because `init` truncates.
//  * Every field the product treats as personal is REDACTED out of the excerpt before it is
//    stored, by key, so a body that carries an email reports the key and not the address.
//  * No member identifier travels with the report. A decode failure is a property of a BUILD
//    and an ENDPOINT, not of a person, and knowing who hit it does not help fix it.
//

import Foundation

/// One decode failure, as the app reports it.
public struct DecodeFailureReport: Codable, Hashable, Sendable {

    /// The hard ceiling on the excerpt, in bytes. An unbounded excerpt is the whole body.
    public static let maxExcerptBytes = 512

    /// Keys whose VALUES are never reported, whatever a body happens to contain.
    ///
    /// Spelled in both the camelCase the app uses and the snake_case the server writes, because
    /// the excerpt is raw bytes off the wire and has not been through a key strategy.
    public static let redactedKeys: [String] = [
        "email", "e_mail",
        "firstName", "first_name", "lastName", "last_name", "fullName", "full_name",
        "name", "displayName", "display_name",
        "phone", "phone_number", "phoneNumber",
        "password", "token", "authToken", "auth_token", "refreshToken", "refresh_token",
        "deviceToken", "device_token",
        "latitude", "longitude", "address", "street", "postcode", "zip",
        "birthday", "dateOfBirth", "date_of_birth",
    ]

    /// `GET api/user/:id/contexts/:contextID/profiles`, with ids already replaced by their
    /// route parameter names so one member's identifier never travels.
    public let endpoint: String

    /// The coding key the decode tripped on, when the error names one.
    public let codingKey: String?

    /// The type the app expected.
    public let expectedType: String

    /// The app build that could not read it. This is what makes a report actionable: the
    /// question is always "which builds are broken against today's server".
    public let appBuild: String

    /// A bounded, redacted excerpt of what was actually on the wire.
    public let excerpt: String

    /// Bytes the whole body had, so a truncated excerpt is not mistaken for a short body.
    public let bodyBytes: Int

    public init(
        endpoint: String,
        codingKey: String?,
        expectedType: String,
        appBuild: String,
        rawBody: String,
        bodyBytes: Int
    ) {
        self.endpoint = endpoint
        self.codingKey = codingKey
        self.expectedType = expectedType
        self.appBuild = appBuild
        self.bodyBytes = bodyBytes
        self.excerpt = Self.redact(Self.bound(rawBody))
    }

    /// Truncate FIRST, so a long body cannot cost more than the ceiling to process.
    public static func bound(_ body: String) -> String {
        let bytes = Array(body.utf8)
        guard bytes.count > maxExcerptBytes else { return body }
        return String(decoding: bytes.prefix(maxExcerptBytes), as: UTF8.self)
    }

    /// Replace the VALUE after any redacted key, leaving the key so the shape is still legible.
    ///
    /// Deliberately a blunt textual pass rather than a JSON parse: the excerpt is usually
    /// truncated mid structure and therefore not parseable, and a redaction that only works on
    /// well formed input is a redaction that fails exactly when the body is malformed, which is
    /// the case this type exists for.
    public static func redact(_ excerpt: String) -> String {
        var out = excerpt
        for key in redactedKeys {
            for quote in ["\"\(key)\":", "\"\(key)\" :"] {
                while let range = out.range(of: quote) {
                    let after = out[range.upperBound...]
                    let stop = after.firstIndex { $0 == "," || $0 == "}" } ?? after.endIndex
                    out.replaceSubrange(range.lowerBound..<stop, with: "\"\(key)\":\"[redacted]\"")
                    if out.range(of: quote) != nil && out.contains("\"\(key)\":\"[redacted]\"") {
                        break
                    }
                }
            }
        }
        return out
    }
}
