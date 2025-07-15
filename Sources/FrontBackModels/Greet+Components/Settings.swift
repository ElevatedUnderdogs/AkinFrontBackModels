//
//  Settings.swift
//  akin
//
//  Created by Scott Lydon on 8/4/19.
//  Copyright © 2019 ElevatedUnderdogs. All rights reserved.
//

import Foundation

public struct Settings: Codable {

    /// Set this 
    static var shared: Self?

    // MARK - properties
    
    public var vibrate: Bool = false
    public var ring: Bool = false
    public var cloudflareProfileImageURL: String?
    public var emailPrimary: String?
    public var userID: UUID = .init()
    public var phone: String?
    public var contextPreferences: [ContextPreferences] = []
    public var firstName: String? = nil
    public var lastName: String? = nil
    public var dob: Date?
    public var birthday: DateComponents?
    
    public var isSocialEnabled: Bool {
        contextPreferences.first { $0.context.case == .social }?.isMeetEnabled == true
    }
    
    public var isRomanceEnabled: Bool {
        contextPreferences.first { $0.context.case == .romance }?.isMeetEnabled == true
    }
    
    public mutating func add(
        greetingMethod: Greet.Method,
        shouldAdd: Bool,
        for context: Context.Case
    ) {
        guard shouldAdd,
        let indexOfPReference = contextPreferences.firstIndex(where: { $0.context.case == context }) else { return
        }
        self.contextPreferences[indexOfPReference].allowedGreetingMethods.append(greetingMethod)
    }

    private func greetingMethods(for context: Context.Case) -> [Greet.Method] {
        contextPreferences.first(where: { $0.context.case == context })?.allowedGreetingMethods ?? []
    }

    public func greetingMethodText(for context: Context.Case) -> String {
        let allowedGreetingMethods = greetingMethods(for: context)
        return allowedGreetingMethods.isEmpty ? "wave" :
            allowedGreetingMethods.hasExactlyOne ? allowedGreetingMethods.first?.rawValue ?? "" :
            "Multiple"
    }

    public func has(_ context: Context) -> Bool {
        contextPreferences.contains { $0.context == context }
    }
    
    public func has(method greetingMethod: Greet.Method, for context: Context.Case) -> Bool {
        greetingMethods(for: context).contains(greetingMethod)
    }
    
    public var contextText: String {
        let enabledContexts: [Context.Case] = contextPreferences.filter(\.isMeetEnabled).map(\.context.case)
        return enabledContexts.count == 2 ? "Both on" :
           enabledContexts.first.map { "\($0.rawValue) on" } ?? "Both off"
    }
    
    // MAKR - inits
    
    public init() {}
    
    public init(email: String, cloudflareProfileImageURL: String?, userID: UUID) {
        self.emailPrimary = email
        self.cloudflareProfileImageURL = cloudflareProfileImageURL
        self.vibrate = true
        self.ring = true
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
