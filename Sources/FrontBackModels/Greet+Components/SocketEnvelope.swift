//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 9/19/25.
//

import Foundation

public enum MessageName: String, Codable {
    case greetUpdate
    case nearbyUserUpdate
}

public struct SocketEnvelope<Payload: Codable>: Encodable {
    let name: MessageName
    let payload: Payload

    public init(name: MessageName, payload: Payload) {
        self.name = name
        self.payload = payload
    }
}
