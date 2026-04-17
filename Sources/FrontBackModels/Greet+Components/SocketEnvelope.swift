//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 9/19/25.
//

import Foundation

public enum SocketPayload: Codable {
    case greetUpdate(Greet.Notification)
    case greetEvent(GreetEvent)
    case nearbyUserUpdate
    case pong

    /// A Web Real Time Communication (WebRTC) signalling
    /// message being relayed from one Greet participant to
    /// the other.  Carries the Session Description Protocol
    /// offer/answer or Interactive Connectivity
    /// Establishment candidate for the active VoIP call.
    case voipSignal(VoipSignalPayload)
}
