//
//  NearbyAvailability.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 8/10/26.
//

import Foundation

/// Whether a nearby member can be greeted right now, and if not, why not.
///
/// Before this existed the nearby list carried only a PRESENCE signal, computed
/// on the client from `NearbyUser.lastLocationUpdate`. Presence answers "have we
/// heard from them lately". It cannot answer "can I meet them", and the two came
/// apart the moment two viewers wanted the same person: the member stayed
/// present, was already mid greet with somebody else, and the list said nothing.
///
/// The four cases are ordered by how reachable the member is, most reachable
/// first, so `<` can be used directly as the refresh sort's primary key.
public enum NearbyAvailability: String, Codable, Hashable, CaseIterable, Comparable, Sendable {

    /// Greetable right now.
    case available

    /// Present and reachable by the app, but not open to a new meet up. Either
    /// they are inside a greet flow with somebody else, or they have raised
    /// their own availability pause. The viewer may join their reservation
    /// queue.
    case unavailable

    /// Their last known position is beyond the nearby radius. They are not a
    /// candidate until they come back.
    case outOfRange

    /// No live socket. They have left the app, so nothing can be delivered to
    /// them in the moment a greet needs.
    case offline

    /// Rank used both by `Comparable` and by the refresh sort. Lower sorts
    /// earlier, which is to say nearer the top of the list.
    public var reachabilityRank: Int {
        switch self {
        case .available: return 0
        case .unavailable: return 1
        case .offline: return 2
        case .outOfRange: return 3
        }
    }

    /// Whether tapping the member's cell can open a greet at all. `false` means
    /// the cell offers a reservation instead of a greet.
    public var acceptsGreetNow: Bool {
        self == .available
    }

    /// Whether a reservation queue makes sense for this member.
    ///
    /// Only `unavailable` qualifies, per the round 4 design specification:
    /// "a reservation is a queue to meet someone who is here; queuing for
    /// someone who left the area would manufacture a meeting neither party can
    /// complete." The same argument disposes of `offline`, where the app cannot
    /// even deliver the invitation when the queue moves. `available` is excluded
    /// for the opposite reason: there is nothing to wait for, so the answer is
    /// to tap, not to queue.
    public var acceptsReservation: Bool {
        self == .unavailable
    }

    public static func < (lhs: NearbyAvailability, rhs: NearbyAvailability) -> Bool {
        lhs.reachabilityRank < rhs.reachabilityRank
    }
}

/// The live, viewer-relative state of one nearby member.
///
/// Viewer-relative is the important half. Two viewers looking at the same member
/// at the same instant legitimately see different things: the one who placed a
/// freeze may still greet, everybody else may not. Rather than ship one global
/// blob and make each client work out which parts apply to it, the server
/// resolves the viewer's perspective and sends the answer.
public struct NearbyInteractionState: Codable, Hashable, Equatable, Sendable {

    /// Whether this member accepts a greet right now, from the viewer's side.
    public var availability: NearbyAvailability

    /// When the current freeze lapses, or `nil` when nobody holds one.
    ///
    /// A freeze is a short exclusive hold. While it stands, this member keeps a
    /// fixed position in the holder's list and refuses greets from everybody
    /// except the holder.
    public var frozenUntil: Date?

    /// `true` when the freeze in `frozenUntil` belongs to the viewer.
    ///
    /// This is the whole point of the freeze: the holder still gets to tap, and
    /// everybody else is held off. A client must never infer this from
    /// `frozenUntil` alone, because that field is non nil for both parties.
    public var frozenByViewer: Bool

    /// How many people are queued to meet this member.
    public var reservationQueueLength: Int

    /// The viewer's own one based place in that queue, or `nil` when the viewer
    /// has not reserved. `1` means next.
    public var viewerReservationPosition: Int?

    /// Straight line distance from the viewer, in metres, when the server could
    /// compute it. Drives the refresh sort's secondary key and the out of range
    /// determination.
    public var distanceMeters: Double?

    public init(
        availability: NearbyAvailability = .available,
        frozenUntil: Date? = nil,
        frozenByViewer: Bool = false,
        reservationQueueLength: Int = 0,
        viewerReservationPosition: Int? = nil,
        distanceMeters: Double? = nil
    ) {
        self.availability = availability
        self.frozenUntil = frozenUntil
        self.frozenByViewer = frozenByViewer
        self.reservationQueueLength = reservationQueueLength
        self.viewerReservationPosition = viewerReservationPosition
        self.distanceMeters = distanceMeters
    }

    /// The state a member is assumed to be in when the server predates this type
    /// entirely. Everybody is greetable, nobody is frozen, no queues exist, which
    /// is exactly how the app behaved before this feature.
    public static var legacyDefault: NearbyInteractionState {
        NearbyInteractionState()
    }

    /// Whether a freeze is standing AS OF a given instant.
    ///
    /// Takes `now` rather than reading the clock so the caller can be tested and
    /// so a countdown and a gate can be evaluated against the same instant.
    /// `frozenUntil` in the past is treated as no freeze at all, which lets a
    /// client keep rendering correctly through the gap between expiry and the
    /// socket message that announces it.
    public func isFrozen(asOf now: Date) -> Bool {
        guard let frozenUntil else { return false }
        return frozenUntil > now
    }

    /// Whether the VIEWER may open a greet with this member as of `now`.
    ///
    /// One place decides this, deliberately. The rule reads simply, and it has
    /// three separate ways to say no, so spreading it across call sites is how
    /// two of them end up disagreeing.
    public func viewerMayGreet(asOf now: Date) -> Bool {
        guard availability.acceptsGreetNow else { return false }
        guard isFrozen(asOf: now) else { return true }
        return frozenByViewer
    }

    /// Seconds left on the standing freeze, floored at zero, or `nil` when no
    /// freeze stands. Countdown copy reads from here so it can never show a
    /// negative interval.
    public func freezeSecondsRemaining(asOf now: Date) -> Int? {
        guard let frozenUntil, frozenUntil > now else { return nil }
        return Int(frozenUntil.timeIntervalSince(now).rounded(.up))
    }
}

/// The viewer's OWN status, returned alongside the nearby list.
///
/// The availability pause (the chip the user raises on themselves after a greet)
/// lives here rather than on a `NearbyUser`, because the viewer never appears in
/// their own nearby list. It has no cell to hang off.
public struct NearbySelfStatus: Codable, Hashable, Equatable, Sendable {

    /// When the viewer's self imposed pause lapses, or `nil` when they are open
    /// to meet ups.
    public var pausedUntil: Date?

    /// How long a freshly raised pause lasts, in seconds. The server owns the
    /// default so it can be retuned without an app release.
    public var pauseDefaultSeconds: Int

    /// Freezes the viewer has left today, and the daily ceiling.
    public var freezesRemainingToday: Int
    public var freezeAllowancePerDay: Int

    /// Reservations the viewer currently holds, and the ceiling on them.
    public var outstandingReservations: Int
    public var reservationAllowance: Int

    public init(
        pausedUntil: Date? = nil,
        pauseDefaultSeconds: Int = 3600,
        freezesRemainingToday: Int = 0,
        freezeAllowancePerDay: Int = 0,
        outstandingReservations: Int = 0,
        reservationAllowance: Int = 0
    ) {
        self.pausedUntil = pausedUntil
        self.pauseDefaultSeconds = pauseDefaultSeconds
        self.freezesRemainingToday = freezesRemainingToday
        self.freezeAllowancePerDay = freezeAllowancePerDay
        self.outstandingReservations = outstandingReservations
        self.reservationAllowance = reservationAllowance
    }

    /// Whether the viewer's pause stands as of `now`.
    public func isPaused(asOf now: Date) -> Bool {
        guard let pausedUntil else { return false }
        return pausedUntil > now
    }

    /// Seconds left on the pause, floored at zero, or `nil` when none stands.
    public func pauseSecondsRemaining(asOf now: Date) -> Int? {
        guard let pausedUntil, pausedUntil > now else { return nil }
        return Int(pausedUntil.timeIntervalSince(now).rounded(.up))
    }
}
