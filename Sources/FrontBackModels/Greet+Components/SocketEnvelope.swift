//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 9/19/25.
//

import Foundation

public enum SocketPayload: Codable {
    case greetUpdate(Greet.Notification)
    case nearbyUserUpdate
}
