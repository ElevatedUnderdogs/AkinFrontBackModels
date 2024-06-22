//
//  File.swift
//  
//
//  Created by Scott Lydon on 6/21/24.
//

import Foundation

/// A struct to hold details for users to see details about the creator of content such as a `Response`
public struct Creator: Codable, Hashable, Equatable {
    public let profileImageURL: String
    public let displayName: String
    public let contextCompatibility: [ContextID: Decimal]

    public init(
        profileImageURL: String,
        displayName: String,
        contextCompatibility: [ContextID : Decimal]
    ) {
        self.profileImageURL = profileImageURL
        self.displayName = displayName
        self.contextCompatibility = contextCompatibility
    }

    static var placeholder: Self {
        .init(profileImageURL: "", displayName: "", contextCompatibility: [:])
    }
}
