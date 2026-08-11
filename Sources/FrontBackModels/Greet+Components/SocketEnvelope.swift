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

    /// One nearby member's availability, freeze, or queue state
    /// changed while the recipient was looking at them.
    ///
    /// This is what `nearbyUserUpdate` above could not be. That
    /// case carries no payload, so the only thing a client can do
    /// with it is refetch the whole list, which is precisely the
    /// wholesale reshuffle the freeze feature exists to prevent.
    /// This one names the single member who changed and what they
    /// changed to, so the client can redraw one cell in place.
    case nearbyStateUpdate(NearbyStateUpdate)

    /// A reservation the recipient placed has come due: the member
    /// they were queued for is greetable, and the recipient is at
    /// the front of the queue.
    case reservationMatured(ReservationMatured)
}

/// A single member's live state, addressed to one recipient.
///
/// The recipient matters. `frozenByViewer` and
/// `viewerReservationPosition` inside `interaction` are answers to
/// "what does THIS person see", so the server resolves them per
/// recipient before sending rather than broadcasting one shared blob.
public struct NearbyStateUpdate: Codable, Hashable, Equatable, Sendable {

    /// The member whose state changed.
    public let userID: UUID

    /// Their new state, from the recipient's perspective.
    public let interaction: NearbyInteractionState

    /// When the server produced this update. A client that receives
    /// two updates out of order keeps the later one, which happens
    /// often enough at the end of a freeze, where the expiry sweep
    /// and a fresh greet can land within the same second.
    public let observedAt: Date

    public init(userID: UUID, interaction: NearbyInteractionState, observedAt: Date = Date()) {
        self.userID = userID
        self.interaction = interaction
        self.observedAt = observedAt
    }
}

/// A matured reservation, delivered to the person who placed it.
///
/// Both sides get one of these, so both are carried into the greet
/// screen and can still decline in the moment. The product brief is
/// explicit about that: "the UI should take them to the greetView
/// (choice cells structure) so that user A and B can still decide
/// whether to opt in on that moment."
public struct ReservationMatured: Codable, Hashable, Equatable, Sendable {

    /// The other party.
    public let otherUserID: UUID

    /// Their display name, so the arriving screen can name them
    /// without a lookup round trip.
    public let otherUserName: String

    /// `true` when the recipient is the one who placed the
    /// reservation, `false` when the recipient is the person who was
    /// reserved. The two sides need different opening copy.
    public let recipientPlacedTheReservation: Bool

    public init(otherUserID: UUID, otherUserName: String, recipientPlacedTheReservation: Bool) {
        self.otherUserID = otherUserID
        self.otherUserName = otherUserName
        self.recipientPlacedTheReservation = recipientPlacedTheReservation
    }
}
