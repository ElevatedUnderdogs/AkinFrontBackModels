//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 5/27/25.
//

import Foundation

/// A web socket message used for real time Nearby User updates.
public enum NearbyUserMessage: Codable {
    case addUser(Greet.User)
    case removeUser(UUID)
    case updateUser(Greet.User)
    case resetAll([Greet.User])

    public enum CodingKeys: String, CodingKey {
        case type, user, userID, users
    }

    public enum MessageType: String, Codable {
        case addUser
        case removeUser
        case updateUser
        case resetAll
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)

        switch type {
        case .addUser:
            let user = try container.decode(Greet.User.self, forKey: .user)
            self = .addUser(user)
        case .removeUser:
            let userID = try container.decode(UUID.self, forKey: .userID)
            self = .removeUser(userID)
        case .updateUser:
            let user = try container.decode(Greet.User.self, forKey: .user)
            self = .updateUser(user)
        case .resetAll:
            let users = try container.decode([Greet.User].self, forKey: .users)
            self = .resetAll(users)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .addUser(let user):
            try container.encode(MessageType.addUser, forKey: .type)
            try container.encode(user, forKey: .user)
        case .removeUser(let userID):
            try container.encode(MessageType.removeUser, forKey: .type)
            try container.encode(userID, forKey: .userID)
        case .updateUser(let user):
            try container.encode(MessageType.updateUser, forKey: .type)
            try container.encode(user, forKey: .user)
        case .resetAll(let users):
            try container.encode(MessageType.resetAll, forKey: .type)
            try container.encode(users, forKey: .users)
        }
    }
}
