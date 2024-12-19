//
//  Settings.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

// MARK - TODO after figuring out the user structure, put settings nested in this user/viewing user.

public struct Settings: Codable {

    /// Set this 
    static var shared: Self?

    // MARK - properties
    
    public var vibrate: Bool = false
    public var ring: Bool = false
    public var displayPic: String?
    public var emailPrimary: String?
    public var userID: UUID = .init()
    public var phone: String?
    public var contexts: [Context] = []
    public var username: String? = nil
    public var allowedGreetingMethods: [Greet.Method] = [.wave]
    public var profileImg: Data? = nil
    public var metersWillingToTravel: Int = 150
    public var dob: String?

    public var profilePicAlternator: TypeAlternator<Data, String>? {
        TypeAlternator(profileImg, displayPic)
    }
    
    public var isOnSocial: Bool {
        contexts.contains(.social)
    }
    
    public var isOnRomance: Bool {
        contexts.contains(.romance)
    }
    
    public mutating func add(greetingMethod: Greet.Method, shouldAdd: Bool) {
        if !shouldAdd {return}
        allowedGreetingMethods.append(greetingMethod)
    }
    
    public var greetingMethodText: String {
        if allowedGreetingMethods.isEmpty {
            return "wave"
        }
        if allowedGreetingMethods.hasExactlyOne {
            return allowedGreetingMethods.first?.rawValue ?? ""
        }
        return "Multiple"
    }
    
    public func has(_ context: Context) -> Bool {
        contexts.contains(context)
    }
    
    public func has(method greetingMethod: Greet.Method) -> Bool {
        allowedGreetingMethods.contains(greetingMethod)
    }
    
    public func has(_ greetingMethod: Greet.Method) -> String {
        has(method: greetingMethod).strInt
    }
    
    public var contextText: String {
        contexts.count == 2 ? "Both on" :
        contexts.first.map { "\($0.rawValue) on" } ?? "Both off"
    }
    
    // MAKR - inits
    
    public init() {}
    
    public init(email: String, profilePic: String, userID: UUID) {
        self.emailPrimary = email
        self.displayPic = profilePic
        self.vibrate = true
        self.ring = true

        self.displayPic = profilePic
        self.emailPrimary = email
        self.userID = userID
    }
}

extension Array where Element == Greet.Method {
    public mutating func update(with greetingMethod: Greet.Method) {
        if contains(greetingMethod) {
            remove(greetingMethod: greetingMethod)
        } else {
            append(greetingMethod)
        }
    }
}
