//
//  NearbyDispatchRequests.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 8/10/26.
//
//  The request contracts for the nearby list's meet up dispatch features:
//  freeze, availability pause, reservations, and choose for me. They live in
//  their own file rather than at the end of `StrongContractClient.Request.swift`
//  because that file is already nine hundred lines of unrelated endpoints, and
//  these five belong together.
//
//  Every `Request` here takes its path from `#function`, which is the static
//  property's own name, so the client's call site and the server's
//  `register(app:handler:)` cannot drift apart without failing to compile.
//

import Foundation
import StrongContractClient

// MARK: - Freeze

/// Ask the server to place, extend, or release a short exclusive hold on one
/// nearby member.
public struct FreezeNearbyUserPayload: Codable, Hashable, Equatable, Sendable {

    /// The member being frozen.
    public let targetUserID: UUID

    /// Requested hold in seconds. The server clamps this to
    /// ``NearbyDispatchDefaults/freezeMaximumSeconds``, so a client cannot buy
    /// itself an hour of exclusivity by sending a large number.
    public let seconds: Int

    /// `true` ends the viewer's own standing freeze early. `seconds` is ignored
    /// when this is set.
    public let release: Bool

    public init(targetUserID: UUID, seconds: Int = NearbyDispatchDefaults.freezeSeconds, release: Bool = false) {
        self.targetUserID = targetUserID
        self.seconds = seconds
        self.release = release
    }
}

/// What actually happened to a freeze request. A refusal is a normal outcome
/// here, not an error, because every refusal has its own thing to say to the
/// user and an HTTP error code cannot carry the remaining allowance back.
public enum FreezeOutcome: String, Codable, Hashable, Sendable {

    /// The hold is now the viewer's.
    case frozen

    /// The viewer's own hold was ended early at their request.
    case released

    /// The viewer has used every freeze in today's allowance.
    case allowanceExhausted

    /// Somebody else already holds this member. First tap wins, and the loser is
    /// told plainly rather than being handed a hold that does nothing.
    case heldByAnother

    /// The member cannot be held because they are not reachable at all.
    case targetUnreachable
}

public struct FreezeNearbyUserResponse: Codable, Hashable, Equatable, Sendable {

    public let targetUserID: UUID
    public let outcome: FreezeOutcome

    /// The resulting state of that member from the viewer's side, so the cell
    /// can be updated from the response alone without a refetch.
    public let interaction: NearbyInteractionState

    /// The viewer's own counters after this request settled.
    public let selfStatus: NearbySelfStatus

    public init(
        targetUserID: UUID,
        outcome: FreezeOutcome,
        interaction: NearbyInteractionState,
        selfStatus: NearbySelfStatus
    ) {
        self.targetUserID = targetUserID
        self.outcome = outcome
        self.interaction = interaction
        self.selfStatus = selfStatus
    }
}

public typealias FreezeNearbyUserRequest = Request<FreezeNearbyUserPayload, FreezeNearbyUserResponse>

extension FreezeNearbyUserRequest {

    /// Places or releases a short exclusive hold on a nearby member, which pins
    /// their position in the caller's list and keeps other viewers from opening
    /// a greet with them until it lapses.
    public static var freezeNearbyUser: Self {
        .init(method: .post)
    }
}

// MARK: - Availability pause

/// Raise or clear the caller's own availability pause, the status that tells
/// everyone else "I am busy, do not send me a new meet up yet".
public struct AvailabilityPausePayload: Codable, Hashable, Equatable, Sendable {

    /// `true` raises the pause, `false` clears it.
    public let engage: Bool

    /// How long to hold it, in seconds. `nil` takes the server's own default,
    /// which is the normal case: the app raises this automatically when a greet
    /// flow ends and has no opinion about the duration.
    public let seconds: Int?

    public init(engage: Bool, seconds: Int? = nil) {
        self.engage = engage
        self.seconds = seconds
    }
}

public struct AvailabilityPauseResponse: Codable, Hashable, Equatable, Sendable {

    /// The caller's status after the change.
    public let selfStatus: NearbySelfStatus

    public init(selfStatus: NearbySelfStatus) {
        self.selfStatus = selfStatus
    }
}

public typealias AvailabilityPauseRequest = Request<AvailabilityPausePayload, AvailabilityPauseResponse>

extension AvailabilityPauseRequest {

    /// Raises or clears the caller's own availability pause. While it stands the
    /// caller reads as unavailable in everybody else's nearby list, and the
    /// caller alone decides when it comes down.
    public static var availabilityPause: Self {
        .init(method: .post)
    }
}

// MARK: - Reservations

/// Join or leave the queue of people waiting to meet one member.
public struct ReserveNearbyUserPayload: Codable, Hashable, Equatable, Sendable {

    public let targetUserID: UUID

    /// `true` leaves the queue instead of joining it.
    public let cancel: Bool

    public init(targetUserID: UUID, cancel: Bool = false) {
        self.targetUserID = targetUserID
        self.cancel = cancel
    }
}

public enum ReserveOutcome: String, Codable, Hashable, Sendable {

    /// The caller is now in the queue. Their place is in `interaction`.
    case reserved

    /// The caller left the queue at their own request.
    case cancelled

    /// The caller already holds as many reservations as they are allowed.
    case allowanceExhausted

    /// The caller was already in this queue. Idempotent, and the existing place
    /// is returned unchanged rather than the caller being moved to the back for
    /// tapping twice.
    case alreadyQueued

    /// The member became greetable between the cell rendering and the tap
    /// landing, so there is nothing to queue for. The client opens the greet
    /// instead.
    case targetAvailableNow

    /// A reservation cannot be held for this member: they are out of range, or
    /// they are no longer a candidate at all.
    case targetNotReservable
}

public struct ReserveNearbyUserResponse: Codable, Hashable, Equatable, Sendable {

    public let targetUserID: UUID
    public let outcome: ReserveOutcome

    /// That member's resulting state from the caller's side, carrying the
    /// caller's own place in the queue.
    public let interaction: NearbyInteractionState

    /// The caller's counters after this request settled.
    public let selfStatus: NearbySelfStatus

    public init(
        targetUserID: UUID,
        outcome: ReserveOutcome,
        interaction: NearbyInteractionState,
        selfStatus: NearbySelfStatus
    ) {
        self.targetUserID = targetUserID
        self.outcome = outcome
        self.interaction = interaction
        self.selfStatus = selfStatus
    }
}

public typealias ReserveNearbyUserRequest = Request<ReserveNearbyUserPayload, ReserveNearbyUserResponse>

extension ReserveNearbyUserRequest {

    /// Appends the caller to the end of one member's reservation queue, or
    /// removes them from it.
    public static var reserveNearbyUser: Self {
        .init(method: .post)
    }
}

/// The caller's whole reservation book, for the surface that lists what they
/// are waiting on and lets them let one go.
public struct ReservationSummary: Codable, Hashable, Equatable, Sendable {

    public let targetUserID: UUID
    public let targetName: String
    public let targetProfileImage: String
    public let position: Int
    public let queueLength: Int
    public let reservedAt: Date
    public let expiresAt: Date

    public init(
        targetUserID: UUID,
        targetName: String,
        targetProfileImage: String,
        position: Int,
        queueLength: Int,
        reservedAt: Date,
        expiresAt: Date
    ) {
        self.targetUserID = targetUserID
        self.targetName = targetName
        self.targetProfileImage = targetProfileImage
        self.position = position
        self.queueLength = queueLength
        self.reservedAt = reservedAt
        self.expiresAt = expiresAt
    }
}

public struct MyReservationsResponse: Codable, Hashable, Equatable, Sendable {

    public let reservations: [ReservationSummary]
    public let selfStatus: NearbySelfStatus

    public init(reservations: [ReservationSummary], selfStatus: NearbySelfStatus) {
        self.reservations = reservations
        self.selfStatus = selfStatus
    }
}

public typealias MyReservationsRequest = Request<Empty, MyReservationsResponse>

extension MyReservationsRequest {

    /// Every reservation the caller currently holds, with their place in each
    /// queue.
    public static var myReservations: Self {
        .init(method: .post)
    }
}

// MARK: - Choose for me

public struct ChooseForMePayload: Codable, Hashable, Equatable, Sendable {

    /// The caller's position at the moment they tapped. The server measures
    /// candidates from here rather than from the caller's last stored fix, for
    /// the same reason the nearby fetch does.
    public let coordinates: Coordinates

    public init(coordinates: Coordinates) {
        self.coordinates = coordinates
    }
}

public enum ChooseForMeOutcome: String, Codable, Hashable, Sendable {

    /// A candidate was chosen. `chosen` carries them.
    case chose

    /// Nobody is nearby at all.
    case noCandidates

    /// People are nearby, but not one of them is greetable at this moment.
    case allUnavailable
}

/// Deliberately NOT `Sendable`, unlike its siblings in this file.
///
/// It carries a `NearbyUser`, which reaches `ImageMetadata` and from there
/// `ModerationAssessment`, none of which are `Sendable` today. Claiming
/// conformance here would be a promise made on behalf of three types this file
/// does not own, and retrofitting the whole chain is a change to shared model
/// code that nothing in this feature needs.
public struct ChooseForMeResponse: Codable, Hashable, Equatable {

    public let outcome: ChooseForMeOutcome

    /// The chosen member, or `nil` when `outcome` is not `.chose`.
    public let chosen: NearbyUser?

    /// A short, honest sentence about WHY this person was chosen, shown to the
    /// user at the moment of reveal. The user is trusting an algorithm here, so
    /// the algorithm says something for itself.
    public let rationale: String?

    /// How many members were considered. Lets the reveal say "chosen from
    /// eleven nearby" rather than presenting a bare face.
    public let candidatesConsidered: Int

    public init(
        outcome: ChooseForMeOutcome,
        chosen: NearbyUser? = nil,
        rationale: String? = nil,
        candidatesConsidered: Int = 0
    ) {
        self.outcome = outcome
        self.chosen = chosen
        self.rationale = rationale
        self.candidatesConsidered = candidatesConsidered
    }
}

public typealias ChooseForMeRequest = Request<ChooseForMePayload, ChooseForMeResponse>

extension ChooseForMeRequest {

    /// Picks the best greetable member near the caller and reports who, and
    /// why. Choosing does NOT start the greet: the client opens the greet flow
    /// itself once the user has seen and accepted the choice.
    public static var chooseForMe: Self {
        .init(method: .post)
    }
}
