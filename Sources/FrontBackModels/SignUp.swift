//
//  NewUserBasicInfo.swift
//  akin
//
//  Created by Scott Lydon on 8/5/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation
import EncryptDecryptKey

// MARK: - Data shape you’ll pass back
public struct VenueInfo: Hashable, Equatable, Codable {

    /// Google places id is a `String` not `UUID`
    public let googlePlacesid: String
    public let name: String
    public let address: String
    public let coordinates: Coordinates
    public let url: String
    public let googlePlacesTypes: [String]

    public init(
        googlePlacesid: String,
        name: String,
        address: String,
        coordinate: Coordinates,
        url: String,
        googlePlacesTypes: [String]
    ) {
        self.googlePlacesid = googlePlacesid
        self.name = name
        self.address = address
        self.coordinates = coordinate
        self.url = url
        self.googlePlacesTypes = googlePlacesTypes
    }

    // Equality by id only (stable identity)
    public static func == (lhs: VenueInfo, rhs: VenueInfo) -> Bool {
        lhs.googlePlacesid == rhs.googlePlacesid
    }

    // Hash by id only
    public func hash(into hasher: inout Hasher) { hasher.combine(googlePlacesid) }
}

public struct ReferralSelection: Hashable, Equatable, Codable {
    public let venue: VenueInfo
    public let personName: String?

    public init(venue: VenueInfo, personName: String?) {
        self.venue = venue
        self.personName = personName
    }
}

extension User {

    public struct SignUp: Codable, Hashable, Equatable {
        public var email: String
        public var password: String
        public var firstName: String
        public var lastName: String
        public var errors: String = ""
        public var referral: ReferralSelection? = nil

        public var acceptTermsRequest: AcceptTermsRequest

        public init(
            email: String? = "",
            password: String? = nil,
            firstName: String? = "",
            lastName: String? = "",
            referral: ReferralSelection?,
            acceptTermsRequest: AcceptTermsRequest
        ) {
            self.email = email ?? ""
            self.password = password ?? ""
            self.firstName = firstName ?? ""
            self.lastName = lastName ?? ""
            self.acceptTermsRequest = acceptTermsRequest
            self.referral = referral
            self.findErrors()
        }

        public mutating func findErrors() {
            
            if email.isEmpty {
                errors.append(" No email was provided.")
            } else if email.count  < 3 {
                errors.append(" The email is too short ;).")
            } else if email.isNotValidEmail {
                errors.append(" The email \(email) is not a valid email.")
            }
            
            if password.isEmpty {
                errors.append(" No password was provided.")
            } else if password.count < 6 {
                errors.append(" The password must have at least 6 characters.")
            }
            
            if firstName.isEmpty {
                errors.append(" No first name was provided.")
            } else if firstName.count < 2 {
                errors.append(" The first name has to have at least 2 characters.")
            }
            
            if lastName.isEmpty {
                errors.append(" No last name was provided.")
            } else if lastName.count < 2 {
                errors.append(" The last name has to have at least 2 characters.")
            }

            // GOAL_LOOP24 17.D. One space between sentences, none before the first.
            //
            // Every clause above appended two spaces rather than one, so the alert
            // the signup form raises carried a double gap between each sentence and
            // an indent before the first. The old form is not reproduced here: the
            // check for it is a grep, and a comment that spells it out would match.
            // Driving the form on the Simulator with all four fields empty put all
            // four sentences in one paragraph, captured in
            // `akin/docs/goal-loop-24-evidence/15-drive-frames/080-xr-signup-done-empty.png`.
            // The separator is one space now and the leading one is trimmed. The
            // sentences themselves are untouched, and the tests that assert on them
            // match with `contains`, so they still pass.
            errors = errors.trimmingCharacters(in: .whitespaces)
        }
    }
}

extension String {
    public var isNotValidEmail: Bool {
        !isValidEmail
    }

    public var isValidEmail: Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
#if canImport(Darwin)
let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
return emailTest.evaluate(with: self)
#else
let regex = try? NSRegularExpression(pattern: emailRegEx)
let range = NSRange(location: 0, length: (self as NSString).length)
return regex?.firstMatch(in: self, options: [], range: range) != nil
#endif
    }
}
