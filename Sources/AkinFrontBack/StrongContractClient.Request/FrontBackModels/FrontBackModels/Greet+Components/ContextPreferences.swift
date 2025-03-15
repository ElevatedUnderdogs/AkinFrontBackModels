//
//  File.swift
//  AkinFrontBack
//
//  Created by Scott Lydon on 1/13/25.
//

import Foundation

public struct ContextPreferences: Codable, Hashable, Equatable {

    public let context: Context
    public var metersWillingToTravel: Int
    public var allowedGreetingMethods: [Greet.Method]
    public var isMeetEnabled: Bool

    public init(
        context: Context,
        metersWillingToTravel: Int,
        allowedGreetingMethods: [Greet.Method],
        isMeetEnabled: Bool
    ) {
        self.context = context
        self.metersWillingToTravel = metersWillingToTravel
        self.allowedGreetingMethods = allowedGreetingMethods
        self.isMeetEnabled = isMeetEnabled
    }
}
