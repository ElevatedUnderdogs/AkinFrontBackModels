//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 12/20/24.
//

import Foundation

public struct ClientContext: Codable, Hashable, Equatable {

    public let id: UUID
    public let context: Context
    public let description: String?
    public let createdAt: Date
    public let creatorID: UUID

    public init(
        id: UUID,
        context: Context,
        description: String?,
        createdAt: Date,
        creatorID: UUID
    ) {
        self.id = id
        self.context = context
        self.description = description
        self.createdAt = createdAt
        self.creatorID = creatorID
    }
}
