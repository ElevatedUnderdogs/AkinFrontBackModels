//
//  UserImage.swift
//  AkinFrontBackModels
//
//  Created by Leonardo Dabus on 12/01/25.
//

import Foundation

/// Provide UserImage with User ID and Image Name.
public struct UserImage: Codable, Equatable {
    public let id: UUID
    public let name: String
    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}
