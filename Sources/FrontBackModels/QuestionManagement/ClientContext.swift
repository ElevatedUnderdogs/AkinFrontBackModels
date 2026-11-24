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
    /// The member who created the context, or nil once they have deleted their account.
    ///
    /// Optional on purpose. When a creator deletes their account and all its data, a context
    /// other members have answered in is kept, so their answers survive, but it must not keep a
    /// strong reference to the deleted member. The server clears the creator instead, and a
    /// client shows "Deleted member" and offers no creator-only actions when this is nil.
    public let creatorID: UUID?

    public init(
        id: UUID,
        context: Context,
        description: String?,
        createdAt: Date,
        creatorID: UUID?
    ) {
        self.id = id
        self.context = context
        self.description = description
        self.createdAt = createdAt
        self.creatorID = creatorID
    }
}
