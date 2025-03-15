//
//  NewUserBasicInfo.swift
//  akin
//
//  Created by Scott Lydon on 8/5/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation


#if canImport(CryptoKit) // ✅ Covers iOS & macOS
import CryptoKit

@available(iOS 13.0, macOS 10.15, *)
extension Data {
    var sha256digest: Data { Data(SHA256.hash(data: self)) }
    var sha384digest: Data { Data(SHA384.hash(data: self)) }
    var sha512digest: Data { Data(SHA512.hash(data: self)) }
}

@available(iOS 13.0, macOS 10.15, *)
extension StringProtocol {
    var data: Data { .init(utf8) }
    var sha256hexa: String { data.sha256digest.map { String(format: "%02x", $0) }.joined() }
    var sha384hexa: String { data.sha384digest.map { String(format: "%02x", $0) }.joined() }
    var sha512hexa: String { data.sha512digest.map { String(format: "%02x", $0) }.joined() }
}
#endif


extension User {
    
    public struct SignUp: Codable, Hashable, Equatable {
        public var email: String
        public var password: String
        public var firstName: String
        public var lastName: String
        public var errors: String = ""

        public init(
            email: String? = "",
            password: String? = nil,
            firstName: String? = "" ,
            lastName: String? = ""
        ) {
            self.email = email ?? ""
            self.password = password?.sha512hexa ?? ""
            self.firstName = firstName ?? ""
            self.lastName = lastName ?? ""
            self.findErrors()
        }
        
        public mutating func findErrors() {
            
            if email.isEmpty {
                errors.append("  No email was provided.")
            } else if email.count  < 3 {
                errors.append("  The email is too short ;).")
            } else if email.isNotValidEmail {
                errors.append("  The email \(email) is not a valid email.")
            }
            
            if password.isEmpty {
                errors.append("  No password was provided.")
            } else if password.count < 6 {
                errors.append("  The password must have at least 6 characters.")
            }
            
            if firstName.isEmpty {
                errors.append("  No first name was provided.")
            } else if firstName.count < 2 {
                errors.append("  The first name has to have at least 2 characters.")
            }
            
            if lastName.isEmpty {
                errors.append("  No last name was provided.")
            } else if lastName.count < 2 {
                errors.append("  The last name has to have at least 2 characters.")
            }
        }
    }
}

extension String {
    public var isNotValidEmail: Bool {
        !isValidEmail
    }

    public var isValidEmail: Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
